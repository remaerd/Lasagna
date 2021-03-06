//
//  ViewController.swift
//  Lasagna-Demo
//
//  Created by Sean Cheng on 3/19/16.
//  Copyright © 2016 Sean Cheng. All rights reserved.
//

import UIKit
import Lasagna


class ViewController: UIViewController, UIScrollViewDelegate {

  var numberOfCards : Int = 10
  
  
  override func loadView() {
    super.loadView()
    self.view.backgroundColor = UIColor.whiteColor()
    let layout = CardCollectionViewLayout()
    layout.edgeInsets = UIEdgeInsets(top: 40, left: 0, bottom: 40, right: 0)
    layout.cardSize = CGSize(width: 320, height: 480)
    let cardView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
    cardView.registerClass(CardCell.self, forCellWithReuseIdentifier: "Cell")
    cardView.backgroundColor = UIColor.whiteColor()
    cardView.dataSource = self
    cardView.delegate = self
    self.view.addSubview(cardView)
  }

  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
}


extension ViewController : CardCollectionViewDelegate, UICollectionViewDataSource {
  
  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
  
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.numberOfCards
  }
  
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! CardCell
    cell.label.text = "CARD \(indexPath.item + 1)"
    return cell
  }
}
