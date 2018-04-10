//
//  GSegment.swift
//  Geometry
//
//  Created by Igor Voynov on 16.03.2018.
//  Copyright © 2018 igyo. All rights reserved.
//

import Foundation

public protocol GeometrySegment {
  var begin: GPoint { get set }
  var end: GPoint { get set }
}

extension GeometrySegment {

  public var length: Float {
    return sqrt(pow(begin.x - end.x, 2) + pow(begin.y - end.y, 2))
  }

  public var middle: GPoint {
    let x = (begin.x + end.x) / 2
    let y = (begin.y + end.y) / 2
    return GPoint(x: x, y: y)
  }

  public func getPoint(with ratio: Float) -> GPoint {
    let x = (end.x + ratio * begin.x) / (1 + ratio)
    let y = (end.y + ratio * begin.y) / (1 + ratio)
    return GPoint(x: x, y: y)
  }

  public mutating func resize(lenght newLength: Float, toEnd: Bool) {
    if toEnd {
      self.end = GPoint(x: end.x + (end.x - begin.x) / length * newLength,
                         y: end.y + (end.y - begin.y) / length * newLength)
    } else {
      self.begin = GPoint(x: begin.x + (begin.x - end.x) / length * newLength,
                           y: begin.y + (begin.y - end.y) / length * newLength)
    }
  }

  public func getPoint(for value: Float, by axis: GAxis) -> GPoint? {
    switch axis {
    case .x:
      guard let max = [begin.x, end.x].max(), let min = [begin.x, end.x].min(),
        value >= min && value <= max else { return nil }
      var y: Float
      if begin.x == end.x {
        y = (begin.y + end.y) / 2
      } else {
        y = (value-begin.x) * (begin.y-end.y) / (begin.x-end.x) + begin.y
      }
      return GPoint(x: value, y: y)
    case .y:
      guard let max = [begin.y, end.y].max(), let min = [begin.y, end.y].min(),
        value >= min && value <= max else { return nil }
      var x: Float
      if begin.y == end.y {
        x = (begin.x + end.x) / 2
      } else {
        x = (value-begin.y) * (begin.x-end.x) / (begin.y-end.y) + begin.x
      }
      return GPoint(x: x, y: value)
    }
  }

  private static var eps: Float {
    return 1e-5
  }

  public func position(with point: GPoint) -> Int {
    return GSegment.orientation(begin, end, point)
  }
  
  public static func orientation(_ a: GPoint, _ b: GPoint, _ c: GPoint) -> Int {
    let value = (b.y - a.y) * (c.x - b.x) - (b.x - a.x) * (c.y - b.y)
    if abs(value) < eps {
      return 0
    }
    return (value > 0) ? -1 : +1
  }

  public static func pointOnLine(_ a: GPoint, _ b: GPoint, _ c: GPoint) -> Bool {
    return orientation(a, b, c) == 0 &&
      min(a.x, b.x) <= c.x && c.x <= max(a.x, b.x) &&
      min(a.y, b.y) <= c.y && c.y <= max(a.y, b.y)
  }

  public static func intersection(segment1 s1: GeometrySegment, segment2 s2: GeometrySegment) -> Bool {
    let o1 = orientation(s1.begin, s1.end, s2.begin)
    let o2 = orientation(s1.begin, s1.end, s2.end)
    let o3 = orientation(s2.begin, s2.end, s1.begin)
    let o4 = orientation(s2.begin, s2.end, s1.end)
    if o1 != o2 && o3 != o4 {
      return true
    }
    if o1 == 0 && pointOnLine(s1.begin, s1.end, s2.begin) ||
      o2 == 0 && pointOnLine(s1.begin, s1.end, s2.end) ||
      o3 == 0 && pointOnLine(s2.begin, s2.end, s1.begin) ||
      o4 == 0 && pointOnLine(s2.begin, s2.end, s1.end) {
      return true
    }
    return false
  }

  public static func getCommonEndpoints(segment1 s1: GeometrySegment, segment2 s2: GeometrySegment) -> [GPoint] {
    var points: [GPoint] = []
    if s1.begin == s2.begin {
      points.append(s1.begin)
      if s1.end == s2.end { points.append(s1.end) }
    } else if s1.begin == s2.end {
      points.append(s1.begin)
      if s1.end == s2.begin { points.append(s1.end) }
    } else if s1.end == s2.begin {
      points.append(s1.end)
      if s1.begin == s2.end { points.append(s1.begin) }
    } else if s1.end == s2.end {
      points.append(s1.end)
      if s1.begin == s2.begin { points.append(s1.begin) }
    }
    return points
  }

  public static func intersect(segment1 s1: GeometrySegment, segment2 s2: GeometrySegment) -> [GPoint] {
    // No intersection.
    guard intersection(segment1: s1, segment2: s2) else {
      return []
    }
    // Both segments are a single point.
    if s1.begin == s1.end &&
      s1.begin == s2.begin &&
      s2.begin == s2.end {
      return [s1.begin]
    }
    let endpoints = getCommonEndpoints(segment1: s1, segment2: s2)
    if endpoints.count == 1 && (s1.begin == s1.end) {
      return endpoints
    }
    // Segments are equal.
    if endpoints.count == 2 {
      return endpoints
    }
    let collinearSegments: Bool = orientation(s1.begin, s1.end, s2.begin) == 0 &&
      orientation(s1.begin, s1.end, s2.end) == 0
    if collinearSegments {
      // Segment #2 is enclosed in segment #1
      if pointOnLine(s1.begin, s1.end, s2.begin) && pointOnLine(s1.begin, s1.end, s2.end) {
        return [s2.begin, s2.end]
      }
      // Segment #1 is enclosed in segment #2
      if pointOnLine(s2.begin, s2.end, s1.begin) && pointOnLine(s2.begin, s2.end, s1.end) {
        return [s1.begin, s1.end]
      }
      let midPoint1 = pointOnLine(s1.begin, s1.end, s2.begin) ? s2.begin : s2.end
      let midPoint2 = pointOnLine(s2.begin, s2.end, s1.begin) ? s1.begin : s1.end
      if midPoint1 == midPoint2 {
        return [midPoint1]
      }
      return [midPoint1, midPoint2]
    }
    // Segment #1 is a vertical line.
    if abs(s1.begin.x - s1.end.x) < eps {
      let m = (s2.end.y - s2.begin.y) / (s2.end.x - s2.begin.x)
      let b = s2.begin.y - m * s2.begin.x
      return [GPoint(x: s1.begin.x, y: m * s1.begin.x + b)]
    }

    // Segment #2 is a vertical line.
    if abs(s2.begin.x - s2.end.x) < eps {
      let m = (s1.end.y - s1.begin.y) / (s1.end.x - s1.begin.x)
      let b = s1.begin.y - m * s1.begin.x
      return [GPoint(x: s2.begin.x, y: m * s2.begin.x + b)]
    }

    let m1 = (s1.end.y - s1.begin.y) / (s1.end.x - s1.begin.x)
    let m2 = (s2.end.y - s2.begin.y) / (s2.end.x - s2.begin.x)
    let b1 = s1.begin.y - m1 * s1.begin.x
    let b2 = s2.begin.y - m2 * s2.begin.x
    let x = (b2 - b1) / (m1 - m2)
    let y = (m1 * b2 - m2 * b1) / (m1 - m2)
    return [GPoint(x: x, y: y)]
  }

}

open class GSegment: GeometrySegment {

  public static func getSegments<T: GSegment>(from points: [GPoint]) -> [T] {
    return [Int](1..<points.count).map { T.init(begin: points[$0-1], end: points[$0]) }
  }

  public var begin: GPoint
  public var end: GPoint

  public required init(begin: GPoint, end: GPoint) {
    self.begin = begin
    self.end = end
  }

  public func setOffset<T: GSegment>(_ offset: Float) -> T {
    return T.init(begin: Geometry().getTrianglePoint(c: begin, a: end, bc: offset),
                  end: Geometry().getTrianglePoint(c: end, a: begin, bc: offset, up: false))
  }
}

extension GSegment: Equatable {
  public static func == (lhs: GSegment, rhs: GSegment) -> Bool {
    return lhs.begin == rhs.begin && lhs.end == rhs.end
  }
}
