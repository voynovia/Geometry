//
//  Curve.swift
//  Geometry
//
//  Created by Igor Voynov on 16.03.2018.
//  Copyright © 2018 igyo. All rights reserved.
//

import Foundation

public typealias GCurveControlsPoints = (cp1: GPoint, cp2: GPoint)

open class GCurve {

  public init() {}

  internal func getCubicPoint(curve: GCurveSegment, t: Float) -> GPoint {
    switch t {
    case 0:
      return curve.begin
    case 1:
      return curve.end
    default:
      let t1: Float = (1.0 - t)
      let r1 = curve.begin * pow(t1, 3)
      let r2 = curve.cp1 * 3.0 * pow(t1, 2) * t
      let r3 = curve.cp2 * 3.0 * t1 * pow(t, 2)
      let r4 = curve.end * pow(t, 3)
      return r1 + r2 + r3 + r4
    }
  }

  public func getPoint(for value: Float, in axis: GAxis, points: [GPoint]) -> GPoint? {
    let segments = getCurveSegments(dataPoints: points)
    var values: [Float] = []
    switch axis {
    case .x:
      values = points.map {$0.x} + segments.map {$0.cp1.x} + segments.map {$0.cp2.x}
    case .y:
      values = points.map {$0.y} + segments.map {$0.cp1.y} + segments.map {$0.cp2.y}
    }
    guard let min = values.min(), let max = values.max(), value >= min && value <= max else {
      return nil
    }

    var point: GPoint? = nil
    for (index, segment) in segments.enumerated() {
      let startPoint = points[index]
      let endPoint = points[index+1]

      var distance: Float
      switch axis {
      case .x:
        distance = (value - startPoint.x) / (endPoint.x - startPoint.x)
      case .y:
        distance = (value - startPoint.y) / (endPoint.y - startPoint.y)
      }
      distance = abs(distance)
      if distance > 1 {
        continue
      }
      let curveSegment = GCurveSegment(begin: startPoint,
                                        cp1: segment.cp1,
                                        cp2: segment.cp2,
                                        end: endPoint)
      point = getCubicPoint(curve: curveSegment, t: distance)
      break
    }
    return point
  }

  public func getCurveSegments(points: [GPoint]) -> [GCurveSegment] {
    var curveSegments: [GCurveSegment] = []
    let curvesContolPoints = GCurve().getCurveSegments(dataPoints: points)
    for (index, curve) in GSegment.getSegments(from: points).enumerated() {
      let controlpoints = curvesContolPoints[index]
      let curveSegment = GCurveSegment(begin: curve.begin,
                                        cp1: controlpoints.cp1,
                                        cp2: controlpoints.cp2,
                                        end: curve.end)
      curveSegments.append(curveSegment)
    }
    return curveSegments
  }

  typealias CPArrays = (rhs: [GPoint], a: [Float], b: [Float], c: [Float])

  public func getCurveSegments(dataPoints: [GPoint]) -> [GCurveControlsPoints] {

    var firstControlPoints: [GPoint?] = []
    var secondControlPoints: [GPoint?] = []

    let count = dataPoints.count - 1

    if count == 1 {
      let p0 = dataPoints[0]
      let p3 = dataPoints[1]
      let p1 = GPoint(x: (2*p0.x + p3.x) / 3, y: (2*p0.y + p3.y) / 3)
      firstControlPoints.append(p1)
      secondControlPoints.append(GPoint(x: 2*p1.x - p0.x, y: 2*p1.y - p0.y))
    } else {

      firstControlPoints = Array(repeating: nil, count: count)

      let arrays = getArrays(points: dataPoints, count: count)
      var rhsArray: [GPoint] = arrays.rhs
      var a: [Float] = arrays.a, b: [Float] = arrays.b, c: [Float] = arrays.c

      // Solve Ax=B. Use Tridiagonal matrix algorithm a.k.a Thomas Algorithm
      for i in 1..<count {
        let rhsValueX = rhsArray[i].x
        let rhsValueY = rhsArray[i].y
        let prevRhsValueX = rhsArray[i-1].x
        let prevRhsValueY = rhsArray[i-1].y

        let m = a[i]/b[i-1]
        let b1 = b[i] - m * c[i-1]
        b[i] = b1
        let r2x = rhsValueX - m * prevRhsValueX
        let r2y = rhsValueY - m * prevRhsValueY

        rhsArray[i] = GPoint(x: r2x, y: r2y)
      }

      let lastControlPointX = rhsArray[count-1].x/b[count-1]
      let lastControlPointY = rhsArray[count-1].y/b[count-1]

      firstControlPoints[count-1] = GPoint(x: lastControlPointX, y: lastControlPointY)

      var i = count-2
      while i >= 0 {
        if let nextControlPoint = firstControlPoints[i+1] {
          let controlPointX = (rhsArray[i].x - c[i] * nextControlPoint.x)/b[i]
          let controlPointY = (rhsArray[i].y - c[i] * nextControlPoint.y)/b[i]
          firstControlPoints[i] = GPoint(x: controlPointX, y: controlPointY)
        }
        i -= 1
      }

      secondControlPoints += getSecondControlPoints(firstControlPoints: firstControlPoints,
                                                    points: dataPoints,
                                                    count: count)
    }

    var controlPoints: [GCurveControlsPoints] = []

    for i in 0..<count {
      if firstControlPoints.count > i, let firstControlPoint = firstControlPoints[i],
        secondControlPoints.count > i, let secondControlPoint = secondControlPoints[i] {
        controlPoints.append((firstControlPoint, secondControlPoint))
      }
    }

    return controlPoints
  }

  private func getArrays(points: [GPoint], count: Int) -> CPArrays {
    var rhsArray: [GPoint] = []
    var a: [Float] = [], b: [Float] = [], c: [Float] = []
    for i in 0..<count {
      var rhs: GPoint!
      let p0 = points[i], p3 = points[i+1]
      switch i {
      case 0:
        a.append(0)
        b.append(2)
        c.append(1)
        rhs = GPoint(x: p0.x + 2*p3.x, y: p0.y + 2*p3.y)
      case _ where i == count-1:
        a.append(2)
        b.append(7)
        c.append(0)
        rhs = GPoint(x: 8*p0.x + p3.x, y: 8*p0.y + p3.y)
      default:
        a.append(1)
        b.append(4)
        c.append(1)
        rhs = GPoint(x: 4*p0.x + 2*p3.x, y: 4*p0.y + 2*p3.y)
      }
      rhsArray.append(rhs)
    }
    return (rhsArray, a, b, c)
  }

  private func getSecondControlPoints(firstControlPoints: [GPoint?], points: [GPoint], count: Int) -> [GPoint?] {
    var result: [GPoint] = []
    for i in 0..<count {
      if i == count-1 {
        let p3 = points[i+1]
        guard let p1 = firstControlPoints[i] else { continue }

        let controlPointX = (p3.x + p1.x)/2
        let controlPointY = (p3.y + p1.y)/2
        result.append(GPoint(x: controlPointX, y: controlPointY))
      } else {
        let p3 = points[i+1]
        guard let nextP1 = firstControlPoints[i+1] else { continue }

        let controlPointX = 2*p3.x - nextP1.x
        let controlPointY = 2*p3.y - nextP1.y
        result.append(GPoint(x: controlPointX, y: controlPointY))
      }
    }
    return result
  }
}
