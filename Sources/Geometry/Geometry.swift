//
//  Geometry.swift
//  Geometry
//
//  Created by Igor Voynov on 16.03.2018.
//  Copyright © 2018 igyo. All rights reserved.
//

import Foundation

open class Geometry {

  public init() {}

  /// Get the point of of a rectangular triangle
  ///
  /// - Parameters:
  ///   - c: The point with straight angle
  ///   - a: The first point with an acute angle
  ///   - bc: The third side of the triangle between "c" and getting point
  /// - Returns: The second point with an acute angle
  public func getTrianglePoint(c: GPoint, a: GPoint, bc: Float, up: Bool = true) -> GPoint {
    let ac = GSegment(begin: c, end: a).length
    let x = c.x + (((a.y - c.y) / ac) * bc * (up ? 1 : -1))
    let y = c.y + (((a.x - c.x) / ac) * bc * (up ? -1 : 1))
    return GPoint(x: x, y: y)
  }

  /// Get ratio
  ///
  /// - Parameters:
  ///   - between: value on the interval
  ///   - begin: start of interval
  ///   - end: end of interval
  /// - Returns: ratio
  public func getRatio(for between: Float, begin: Float, end: Float) -> Float {
    return (end - begin) / (between - begin) - 1
  }

  /// Get the second coordinate value
  ///
  /// - Parameters:
  ///   - value: The first coordinate value
  ///   - axis: The axis of the second coordinate
  ///   - points: Point of the curve or segment
  /// - Returns: The second coordinate value
  public func getValue(for value: Float, axis: GAxis, points: [[GPoint]]) -> Float? {
    var result: GPoint?
    for points in points {
      switch points.count {
      case 2:
        result <= GSegment(begin: points[0], end: points[1]).getPoint(for: value, by: axis)
      case 2...:
        result <= GCurve().getPoint(for: value, in: axis, points: points)
      default: continue
      }
    }
    switch axis {
    case .x: return result?.y
    case .y: return result?.x
    }
  }

  /// Get twin line
  ///
  /// - Parameters:
  ///   - points: An array of points of a curve or start and end of a segment
  ///   - distance: distance between original line and twin
  /// - Returns: Array of points
//  public func twin(points: [GPoint], with distance: Float) -> [GPoint] {
//    var result: [GPoint] = []
//    switch points.count {
//    case 2: result = twinSegment(points, with: distance)
//    case 2...: result = twinCurve(points, with: distance)
//    default: break
//    }
//    return result
//  }

  /// Get intersect points
  ///
  /// - Parameters:
  ///   - points1: An array of points of a curve or start and end of a segment
  ///   - points2: An array of points of a curve or start and end of a segment
  /// - Returns: Array of intersect points
  public func getIntersectPoints(points1: [GPoint], points2: [GPoint]) -> [GPoint] {
    let cgCurve: GCurve = GCurve()
    var points: [GPoint] = []
    switch (points1.count, points2.count) {
    case let (c1, c2) where c1 > 2 && c2 > 2:
      points = getIntersectPoints(curves1: cgCurve.getCurveSegments(points: points1),
                                  curves2: cgCurve.getCurveSegments(points: points2))
    case let (c1, c2) where c1 == 2 && c2 == 2:
      points = getIntersectPoints(segment1: GSegment(begin: points1[0], end: points1[1]),
                                  segment2: GSegment(begin: points2[0], end: points2[1]))
    case let (c1, c2) where c1 > 2 && c2 == 2:
      points = getIntersectPoints(curves: cgCurve.getCurveSegments(points: points1),
                                  segment: GSegment(begin: points2[0], end: points2[1]))
    case let (c1, c2) where c1 == 2 && c2 > 2:
      points = getIntersectPoints(curves: cgCurve.getCurveSegments(points: points2),
                                  segment: GSegment(begin: points1[0], end: points1[1]))
    default: break
    }
    return points
  }
}
