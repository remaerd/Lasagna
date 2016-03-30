//
//  StackView.swift
//  Lasagna
//
//  Created by Sean Cheng on 3/19/16.
//  Copyright © 2016 Sean Cheng. All rights reserved.
//

import UIKit


@objc public protocol StackCollectionViewLayout : UICollectionViewDelegate {
  
  optional func collectionView(collectionView:UICollectionView, atIndex:Int, didSwipeToDirection: UISwipeGestureRecognizerDirection)
  optional func collectionView(collectionView:UICollectionView, atIndex:Int, didDragToPoint:CGPoint)
  optional func collectionView(collectionView: UICollectionView, atIndex:Int, draggingToPoint:CGPoint)
}


public class StackCollectionViewLayoutAttributes : UICollectionViewLayoutAttributes {
  
  public var originAngle : Float = 0
}


public class StackCollectionViewLayout: UICollectionViewLayout, UIGestureRecognizerDelegate {
  
  public enum CardDraggingBehaviorType {
    case Disabled
    case One(edges:UIEdgeInsets)
    case Multiple(maximumCard: Int?)
  }

  
  public enum CardRotatingEffectType {
    case Disabled
    case Random(minimum:Float, maximum:Float)
    case Left(from:Float, to:Float)
    case Right(from:Float, to:Float)
  }
  
  
  public enum CardScalingEffectType {
    case Disabled
    case Stack(marginX: Float, marginY: Float, minimumScale:Float)
  }
  
  
  public enum CardFadingEffectType {
    case Disabled
    case Alpha(minimum:Float)
    case Blur(maximum:Float)
  }
  
  
  public var numberOfVisibleCards   : Int = 3
  
  public var cardDraggingBehavior   : CardDraggingBehaviorType = .One(edges: UIEdgeInsets(top: 80, left: 80, bottom: 80, right: 80)) { didSet { prepareGestureRecognizer() } }
  public var cardRotating           : CardRotatingEffectType = .Disabled { didSet { self.invalidateLayout() }}
  public var cardScaling            : CardScalingEffectType = .Disabled { didSet { self.invalidateLayout() }}
  public var cardFading             : CardFadingEffectType = .Disabled { didSet { self.invalidateLayout() }}
  public var cardSize               : CGSize
  public var cardAnimationSpeed     : Double = 0.5
  
  public var currentCardIndexPath   : NSIndexPath = NSIndexPath(forItem: 0, inSection: 0)
  public var draggingCardIndexPath  : NSIndexPath?
  public var infinite               : Bool = false { didSet { self.invalidateLayout() }}
  
  private var _cachedAttributes     = NSCache()
  
  private lazy var _panGesture  : UIPanGestureRecognizer = {
    let gesture = UIPanGestureRecognizer(target: self, action: #selector(dragHandler(_:)))
    gesture.delegate = self
    return gesture
  }()
  
  
  private lazy var _swipeGesture : UISwipeGestureRecognizer = {
    let gesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeHandler(_:)))
    gesture.delegate = self
    return gesture
  }()
  
  
  public init(cardSize:CGSize) {
    self.cardSize = cardSize
    super.init()
  }

  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}


extension CardCollectionViewLayout {
  
  public func prepareGestureRecognizer() {
    switch self.cardDraggingBehavior {
    case .Disabled:
      self._panGesture.enabled = false
      self.collectionView?.removeGestureRecognizer(self._panGesture)
    case .One, .Multiple:
      self._panGesture.enabled = true
      if self.collectionView?.gestureRecognizers?.indexOf(self._panGesture) < 0 {
        self.collectionView?.addGestureRecognizer(self._panGesture)
      }
    }
  }
  
  
  public override func prepareLayout() {
    super.prepareLayout()
    self.prepareGestureRecognizer()
    self.collectionView?.scrollEnabled = false
  }
}


extension CardCollectionViewLayout {
  
  public override func initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
    return self.layoutAttributesForItemAtIndexPath(itemIndexPath)
  }
  
  
  public override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    var attributesArray = [UICollectionViewLayoutAttributes]()
    if infinite == false {
      var count = (currentCardIndexPath.item + 1) + numberOfVisibleCards
      if count > self.collectionView!.numberOfItemsInSection(0) { count = self.collectionView!.numberOfItemsInSection(0) }
      for i in currentCardIndexPath.item..<count {
        if let attributes = self.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: i, inSection: 0)) { attributesArray.append(attributes) }
      }
    } else {
      
    }
    return attributesArray
  }
  

  public override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
    
    let attributes : CardCollectionViewLayoutAttributes
    
    func updateLayoutAttributes() -> CardCollectionViewLayoutAttributes {
      
      if attributes.indexPath.item >= currentCardIndexPath.item && attributes.indexPath.item < currentCardIndexPath.item + numberOfVisibleCards {
        let x : CGFloat
        let y : CGFloat
        var transforms = [CGAffineTransform]()
        
        // Scale and Set Card Position
        switch self.cardScaling {
        case .Disabled:
          x = self.collectionView!.center.x
          y = self.collectionView!.center.y
        case .Stack(let marginX, let marginY, let minimumScale):
          let layer = CGFloat(attributes.indexPath.item - currentCardIndexPath.item)
          let scale = 1 - CGFloat(1 - minimumScale) * layer
          transforms.append(CGAffineTransformMakeScale(scale, scale))
          x = self.collectionView!.center.x + (CGFloat(marginX) * CGFloat(layer))
          y = self.collectionView!.center.y + (CGFloat(marginY) * CGFloat(layer))
        }
        
        // Rotate Card
        switch self.cardRotating {
        case .Random(let minimum, let maximum):
          if indexPath != currentCardIndexPath {
            if attributes.originAngle == 0 { attributes.originAngle = Float.random(minimum, upper: maximum) }
            transforms.append(CGAffineTransformMakeRotation(CGFloat(attributes.originAngle)))
          }
        default: break
        }
        
        attributes.hidden = false
        attributes.center = CGPoint(x: x, y: y)
        attributes.size = self.cardSize
        if transforms.count > 0 {
          attributes.transform = transforms[0]
          for index in 1..<transforms.count {
            attributes.transform = CGAffineTransformConcat(attributes.transform, transforms[index])
          }
        }
      } else { attributes.hidden = true }
      return attributes
    }
    
    if let cachedAttributes = self._cachedAttributes.objectForKey(indexPath.item) as? CardCollectionViewLayoutAttributes { attributes = cachedAttributes }
    else {
      attributes = CardCollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
      self._cachedAttributes.setObject(attributes, forKey: indexPath.item)
    }
    
    updateLayoutAttributes()
    if indexPath.item == currentCardIndexPath.item { attributes.zIndex = 100000 } else { attributes.zIndex = 1000 - indexPath.item }
    return attributes
  }
}


internal extension CardCollectionViewLayout {
  
  
  internal func dragHandler(gesture:UIPanGestureRecognizer) {
    
    func rotationTransform() -> CGAffineTransform {
      let location = gesture.locationInView(self.collectionView)
      let centerYIncidence = collectionView!.frame.size.height + cardSize.height
      let gamma:Double = Double((location.x -  collectionView!.bounds.size.width / 2) / (centerYIncidence - location.y))
      return CGAffineTransformMakeRotation(CGFloat(atan(gamma) * 0.25))
    }
    
    
    func beganDrag() {
      let location = gesture.locationInView(self.collectionView)
      let indexPath = collectionView?.indexPathForItemAtPoint(location)
      if indexPath == self.currentCardIndexPath { self.draggingCardIndexPath = indexPath }
    }
    
    
    func dragging() {
      guard let indexPath = self.draggingCardIndexPath else { return }
      guard let cell = self.collectionView?.cellForItemAtIndexPath(indexPath) else { return }
      let transition = gesture.translationInView(self.collectionView)
      guard let delegate = self.collectionView!.delegate as? CardCollectionViewDelegate else { return }
      delegate.collectionView?(self.collectionView!, atIndex: self.currentCardIndexPath.item, draggingToPoint: transition)
      cell.transform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(transition.x, transition.y), rotationTransform())
    }
    
    
    func endDrag() {
      let transition = gesture.translationInView(self.collectionView)
      guard let indexPath = self.draggingCardIndexPath else { return }
      guard let cell = self.collectionView?.cellForItemAtIndexPath(indexPath) else { return }
      
      func endDragWithOneCard(edges:UIEdgeInsets) {
        var possibleHorizonTransition : CGAffineTransform?
        var possibleVerticalTransition : CGAffineTransform?
        if transition.x < -(edges.left) { possibleHorizonTransition = CGAffineTransformMakeTranslation(-self.collectionView!.bounds.width, transition.y) }
        if transition.x > edges.right { possibleHorizonTransition = CGAffineTransformMakeTranslation(self.collectionView!.bounds.width, transition.y) }
        if transition.y < -(edges.top) { possibleVerticalTransition = CGAffineTransformMakeTranslation(transition.x, -self.collectionView!.bounds.height) }
        if transition.y > edges.bottom { possibleVerticalTransition = CGAffineTransformMakeTranslation(transition.x, self.collectionView!.bounds.height) }
        var transform : CGAffineTransform?
        if possibleHorizonTransition != nil && possibleVerticalTransition != nil {
          if abs(transition.x) > abs(transition.y) { transform = possibleHorizonTransition } else { transform = possibleVerticalTransition }
        } else if possibleVerticalTransition != nil { transform = possibleVerticalTransition }
        else if possibleHorizonTransition != nil { transform = possibleHorizonTransition }
        let cellSnapshot = cell.snapshotViewAfterScreenUpdates(false)
        cellSnapshot.center = cell.center
        cellSnapshot.transform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(transition.x, transition.y), rotationTransform())
        self.collectionView?.addSubview(cellSnapshot)
        cell.hidden = true
        UIView.animateWithDuration(self.cardAnimationSpeed, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: UIViewAnimationOptions.CurveEaseIn, animations: {
          guard let transitionTransform = transform else { cellSnapshot.transform = CGAffineTransformIdentity; return }
          cellSnapshot.transform = CGAffineTransformConcat(transitionTransform, rotationTransform())
          }, completion: {
            (finished) -> Void in
            cellSnapshot.removeFromSuperview()
            self.draggingCardIndexPath = nil
            if transform == nil {
              cell.transform = CGAffineTransformIdentity
              cell.hidden = false
            }
        })
        
        if transform != nil {
          self.currentCardIndexPath = NSIndexPath(forItem: self.currentCardIndexPath.item + 1, inSection: 0)
          self.collectionView?.performBatchUpdates({
            self.invalidateLayout()
            }, completion: {
              (finished) in
              guard let delegate = self.collectionView!.delegate as? CardCollectionViewDelegate else { return }
              delegate.collectionView?(self.collectionView!, atIndex: self.currentCardIndexPath.item, didDragToPoint: transition)
          })
        }
      }
      
      switch self.cardDraggingBehavior {
      case .One(let edges): endDragWithOneCard(edges)
      case .Multiple(_): print("Unimplemented")
      default: return
      }
    }
    
    switch gesture.state {
    case .Began: beganDrag()
    case .Changed: dragging()
    default: endDrag()
    }
  }
  
  
  internal func swipeHandler(gesture:UISwipeGestureRecognizer) {
    if let delegate = self.collectionView?.delegate as? CardCollectionViewDelegate {
      delegate.collectionView?(self.collectionView!, atIndex: self.currentCardIndexPath.item, didSwipeToDirection: gesture.direction)
    }
  }
}