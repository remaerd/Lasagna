//
//  Random.swift
//  Lasagna
//
//  Created by Sean Cheng on 3/21/16.
//  Copyright © 2016 Sean Cheng. All rights reserved.
//

import Foundation

func arc4random <T: IntegerLiteralConvertible> (type: T.Type) -> T {
  var r: T = 0
  arc4random_buf(&r, Int(sizeof(T)))
  return r
}


public extension Int {

  public static func random(lower: Int, upper: Int) -> Int {
    let range = UInt32(upper - lower + 1)
    return lower + Int(arc4random_uniform(range))
  }
  
  
  func degreesToRadians() -> Float {
    return Float(Double(self) * M_PI / 180.0)
  }
}


public extension Double {

  public static func random(lower: Double, upper: Double) -> Double {
    let random = Double(arc4random(UInt64)) / Double(UInt64.max)
    return (random * (upper - lower)) + lower
  }
}


public extension Float {

  public static func random(lower: Float, upper: Float) -> Float {
    let random = Float(arc4random(UInt32)) / Float(UInt32.max)
    return (random * (upper - lower)) + lower
  }
}


