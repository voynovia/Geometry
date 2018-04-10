//
//  OptionalOperator.swift
//  Geometry
//
//  Created by Igor Voynov on 30.03.2018.
//

import Foundation

postfix operator <=

internal func <= <T>(left: inout T, right: T?) {
  if let value = right {
    left = value
  }
}

internal func <= <T>(left: inout T?, right: T?) {
  if let value = right {
    left = value
  }
}
