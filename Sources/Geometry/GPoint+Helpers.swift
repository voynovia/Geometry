//
//  GPoint+Helpers.swift
//  Geometry
//
//  Created by Igor Voynov on 28.03.2018.
//

import Foundation

extension GPoint {

  internal func dot(_ other: GPoint) -> Float {
    return self.x * other.x + self.y * other.y
  }

  internal var length: Float {
    return sqrt(dot(self))
  }

  internal func normalize() -> GPoint {
    return GPoint(x: self.x / self.length, y: self.y / self.length)
  }

  internal static func min(p1: GPoint, p2: GPoint) -> GPoint {
    return GPoint(x: Swift.min(p1.x, p2.x),
                   y: Swift.min(p1.y, p2.y))
  }

  internal static func max(p1: GPoint, p2: GPoint) -> GPoint {
    return GPoint(x: Swift.max(p1.x, p2.x),
                   y: Swift.max(p1.y, p2.y))
  }

  internal static var infinity: GPoint {
    return GPoint(x: Float.infinity, y: Float.infinity)
  }

  internal static var zero: GPoint {
    return GPoint(x: 0, y: 0)
  }
}
