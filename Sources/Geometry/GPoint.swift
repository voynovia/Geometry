//
//  GPoint.swift
//  Geometry
//
//  Created by Igor Voynov on 10.04.2018.
//

import Foundation

public class GPoint {
  public var x: Float
  public var y: Float
  
  public init(x: Float, y: Float) {
    self.x = x
    self.y = y
  }
  
  public init(coord: [Float]) {
    self.x = coord[0]
    self.y = coord[1]
  }
}

extension GPoint: Equatable {
  public static func == (lhs: GPoint, rhs: GPoint) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
  }
}
