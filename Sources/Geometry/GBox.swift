//
//  GBox.swift
//  Geometry
//
//  Created by Igor Voynov on 29.03.2018.
//

import Foundation

open class GBox {
  public var min: GPoint
  public var max: GPoint

  init() {
    self.min = GPoint.infinity
    self.max = 0 - GPoint.infinity
  }

  public init(min: GPoint, max: GPoint) {
    self.min = min
    self.max = max
  }

  public var size: GPoint {
    return max - min
  }

  public func overlaps(_ other: GBox) -> Bool {
    for i in 0..<GPoint.dimensions {
      if self.min[i] > other.max[i] {
        return false
      }
      if self.max[i] < other.min[i] {
        return false
      }
    }
    return true
  }

}
