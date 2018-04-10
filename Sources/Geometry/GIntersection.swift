//
//  GIntersection.swift
//  Geometry
//
//  Created by Igor Voynov on 28.03.2018.
//

import Foundation

open class GIntersection {
  public var t1: Float
  public var t2: Float
  public init(t1: Float, t2: Float) {
    self.t1 = t1
    self.t2 = t2
  }
}

extension GIntersection: Equatable {
  public static func == (lhs: GIntersection, rhs: GIntersection) -> Bool {
    return lhs.t1 == rhs.t1 && lhs.t2 == rhs.t2
  }
}

extension GIntersection: Comparable {
  public static func < (lhs: GIntersection, rhs: GIntersection ) -> Bool {
    if lhs.t1 < rhs.t1 {
      return true
    } else if lhs.t1 == rhs.t1 {
      return lhs.t2 < rhs.t2
    } else {
      return false
    }
  }
}
