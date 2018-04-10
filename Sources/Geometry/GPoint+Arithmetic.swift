//
//  GPoint+Arithmetic.swift
//  Geometry
//
//  Created by Igor Voynov on 28.03.2018.
//

import Foundation

extension GPoint {

  internal static func + (lhs: GPoint, rhs: GPoint) -> GPoint {
    return GPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
  }

  internal static func - (lhs: GPoint, rhs: GPoint) -> GPoint {
    return GPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
  }
  internal static func - (lhs: Float, rhs: GPoint) -> GPoint {
    return GPoint(x: lhs - rhs.x, y: lhs - rhs.y)
  }

  internal static func * (lhs: Float, rhs: GPoint) -> GPoint {
    return GPoint(x: lhs * rhs.x, y: lhs * rhs.y)
  }
  internal static func / (lhs: Float, rhs: GPoint) -> GPoint {
    return GPoint(x: lhs / rhs.x, y: lhs / rhs.y)
  }

  internal static func * (lhs: GPoint, rhs: Float) -> GPoint {
    return GPoint(x: lhs.x * rhs, y: lhs.y * rhs)
  }
  internal static func / (lhs: GPoint, rhs: Float) -> GPoint {
    return GPoint(x: lhs.x / rhs, y: lhs.y / rhs)
  }

}
