//
//  GPoint+Index.swift
//  Geometry
//
//  Created by Igor Voynov on 29.03.2018.
//

import Foundation

extension GPoint {

  /// x plus y = 2
  internal static var dimensions: Int {
    return 2
  }

  /// Get coordinate by index
  ///
  /// - Parameter index: 0 = x, 1 = y
  internal subscript(index: Int) -> Float {
    get {
      switch index {
      case 0: return self.x
      case 1: return self.y
      default: fatalError("bad subscript (out of bounds)")
      }
    }
    set {
      switch index {
      case 0: self.x = newValue
      case 1: self.y = newValue
      default: fatalError("bad subscript (out of bounds)")
      }
    }
  }
}
