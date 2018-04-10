//
//  GSubCurveSegment.swift
//  Geometry
//
//  Created by Igor Voynov on 30.03.2018.
//

import Foundation

internal class GSubCurveSegment {
  public let t1: Float
  public let t2: Float
  public let curve: GCurveSegment

  internal init(curve: GCurveSegment) {
    self.t1 = 0.0
    self.t2 = 1.0
    self.curve = curve
  }

  internal init(t1: Float, t2: Float, curve: GCurveSegment) {
    self.t1 = t1
    self.t2 = t2
    self.curve = curve
  }

  internal func split(from t1: Float, to t2: Float) -> GSubCurveSegment {
    let curve = self.curve.split(from: t1, to: t2)
    return GSubCurveSegment(t1: Geometry.map(t1, 0, 1, t1, t2),
                             t2: Geometry.map(t2, 0, 1, t1, t2),
                             curve: curve)
  }

  internal func split(at t: Float) -> (left: GSubCurveSegment, right: GSubCurveSegment) {
    let (left, right) = curve.split(at: t)
    let subcurveLeft = GSubCurveSegment(t1: Geometry.map(0, 0, 1, t1, t2),
                                         t2: Geometry.map(t, 0, 1, t1, t2),
                                         curve: left)
    let subcurveRight = GSubCurveSegment(t1: Geometry.map(t, 0, 1, t1, t2),
                                          t2: Geometry.map(1, 0, 1, t1, t2),
                                          curve: right)
    return (left: subcurveLeft, right: subcurveRight)
  }
}
