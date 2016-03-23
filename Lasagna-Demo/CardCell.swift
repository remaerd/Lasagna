//
//  CardCell.swift
//  Lasagna
//
//  Created by Sean Cheng on 3/21/16.
//  Copyright © 2016 Sean Cheng. All rights reserved.
//

import UIKit
import QuartzCore


class CardCell: UICollectionViewCell {
  
  let label : UILabel
  
  
  override init(frame: CGRect) {
    label = UILabel(frame: CGRect(origin: CGPointZero, size: frame.size))
    label.textColor = UIColor.whiteColor()
    label.textAlignment = NSTextAlignment.Center
    label.font = UIFont.systemFontOfSize(40, weight: UIFontWeightThin)
    super.init(frame: frame)
    self.addSubview(label)
    self.layer.cornerRadius = 20
    self.layer.borderColor = UIColor.blackColor().colorWithAlphaComponent(0.3).CGColor
    self.layer.borderWidth = 1
    self.backgroundColor = randomColor(hue: Hue.Random, luminosity: Luminosity.Dark)
  }

  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}