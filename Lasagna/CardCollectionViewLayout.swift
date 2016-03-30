//
//  CardCollectionViewLayout.swift
//  Lasagna
//
//  Created by Sean Cheng on 3/24/16.
//  Copyright © 2016 Sean Cheng. All rights reserved.
//

import UIKit


@objc public protocol CardCollectionViewDelegate : UICollectionViewDelegate {
  optional func collectionView(collectionView:UICollectionView, didSwipeTo: UISwipeGestureRecognizerDirection, atIndex:Int)
  optional func collectionView(collectionView:UICollectionView, didDragTo:CGPoint, atIndex:Int)
  optional func collectionView(collectionView: UICollectionView, isDraggingTo:CGPoint, atIndex:Int)
}


@objc public protocol CardCollectionViewDataSource : UICollectionViewDataSource {
  optional func collectionView(collectionView: UICollectionView, visibleHeightForCardAtIndexPath indexPath: NSIndexPath) -> CGFloat
}


extension CGFloat {
  static var CardHeight :CGFloat = 120
}


public class CardCollectionViewLayout: UICollectionViewLayout {
  
  public enum CardFadingEffect {
    case Alpha(max:CGFloat)
    case Black(max:CGFloat)
  }
  
  
  public var cardSize                 : CGSize  = CGSizeZero { didSet { self.invalidateLayout() } }
  public var cardHeight               : CGFloat = 0 { didSet { self.invalidateLayout() } }
  public var cardFadingEffect         : CardFadingEffect? = .Black(max: 0.5)
  public var estimatedCardHeight      : CGFloat = 0 { didSet { self.invalidateLayout() } }
  public var edgeInsets               : UIEdgeInsets = UIEdgeInsetsZero
  
  private var _topCardIndex           : NSIndexPath?
  private lazy var _shadowView        = UIView()
  private lazy var _cachedAttributes  = NSCache()
  
  
  private func _cardHeight() -> CGFloat {
    if estimatedCardHeight > 0 { return estimatedCardHeight }
    else if cardHeight > 0 { return cardHeight }
    else { return CGFloat.CardHeight }
  }
}


public extension CardCollectionViewLayout {
  
  override func prepareLayout() {
    
    super.prepareLayout()
  }
  
  
  override func collectionViewContentSize() -> CGSize {
  
    guard let numberOfCards = self.collectionView?.dataSource?.collectionView(self.collectionView!, numberOfItemsInSection: 0) else { return CGSizeZero }
    return CGSize(width: self.collectionView!.bounds.width, height: (_cardHeight() * (CGFloat(numberOfCards)) + edgeInsets.top + edgeInsets.bottom))
  }
  
  
  override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    
    var layoutAttributes = [UICollectionViewLayoutAttributes]()
    var topVisibleCardIndex = Int((fabs(self.collectionView!.contentOffset.y)) / _cardHeight())
    var lastVisibleCardIndex = Int((fabs(self.collectionView!.contentOffset.y) + self.collectionView!.bounds.height) / _cardHeight())
    let lastCardIndex = self.collectionView!.dataSource!.collectionView(self.collectionView!, numberOfItemsInSection: 0) - 1
    
    //  如果最后一张卡牌的数值已经超过了真实的卡牌数，则以真实的卡牌数为准
    if lastVisibleCardIndex >= lastCardIndex { lastVisibleCardIndex = lastCardIndex }
    if self.collectionView!.contentOffset.y < 0 { topVisibleCardIndex = 0 }
    
    for index in topVisibleCardIndex...lastVisibleCardIndex {
      let indexPath = NSIndexPath(forItem: index, inSection: 0)
      if var attributes = self.layoutAttributesForItemAtIndexPath(indexPath) {
        layoutAttributes.append(attributes)
        if index == topVisibleCardIndex && self.collectionView!.contentOffset.y > 0 { self.updateLayoutAttributesOfTheTopCard(&attributes) }
        else {
          attributes.transform = CGAffineTransformIdentity
          attributes.alpha = 1
        }
      }
    }
    if self.collectionView!.contentOffset.y < 0 { self.updateLayoutAttributesOfTheTopCards(layoutAttributes) }
    return layoutAttributes
  }
  
  
  override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
    
    guard let attributes = self._cachedAttributes.objectForKey(indexPath) as? UICollectionViewLayoutAttributes else {
      let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
      let x = (self.collectionView!.bounds.size.width / 2) - (self.cardSize.width / 2) - edgeInsets.left - edgeInsets.right
      let y = self.edgeInsets.top + (_cardHeight() * CGFloat(indexPath.item))
      attributes.frame = CGRect(origin:  CGPoint(x:x , y:y), size: self.cardSize)
      attributes.hidden = false
      attributes.zIndex = 1000 + indexPath.item
      self._cachedAttributes.setObject(attributes, forKey: indexPath)
      return attributes
    }
    return attributes
  }
  
  
  override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
    return true
  }
}


private extension CardCollectionViewLayout {
  
  func updateLayoutAttributesOfTheTopCard(inout attributes:UICollectionViewLayoutAttributes) {
    
    if self.cardFadingEffect != nil {
      if let coveredCell = self.collectionView?.cellForItemAtIndexPath(attributes.indexPath), let coverCell = self.collectionView?.cellForItemAtIndexPath(NSIndexPath(forItem: attributes.indexPath.item+1, inSection: 0)) {
        let delta = (coverCell.frame.origin.y - coveredCell.frame.origin.y) / _cardHeight()
        switch self.cardFadingEffect! {
        case .Alpha(let max):
          attributes.alpha = (max * delta) + max
        case .Black(let max):
          if _shadowView.superview != coveredCell {
            _shadowView.removeFromSuperview()
            _shadowView.frame = coveredCell.bounds
            _shadowView.backgroundColor = UIColor.blackColor()
            coveredCell.clipsToBounds = true
            coveredCell.contentView.addSubview(_shadowView)
          }
          _shadowView.alpha = fabs(delta - 1) * max
        }
      }
    }
    
    let y = fabs(self.collectionView!.contentOffset.y) - (_cardHeight() * CGFloat(attributes.indexPath.item))
    attributes.transform = CGAffineTransformMakeTranslation(0, y)
  }
  
  
  func updateLayoutAttributesOfTheTopCards(attributes:[UICollectionViewLayoutAttributes]) {
    for attribute in attributes {
      attribute.transform = CGAffineTransformMakeTranslation(0, (fabs(self.collectionView!.contentOffset.y) * (CGFloat(attribute.indexPath.item) * 0.5)) * 0.5)
    }
  }
}


//public extension CardCollectionViewLayout {
//  
//  public override func initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
//    
//  }
//  
//  
//  public override func finalLayoutAttributesForDisappearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
//    
//  }
//}