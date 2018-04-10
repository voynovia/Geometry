//
//  GCurve+Intersect.swift
//  Geometry
//
//  Created by Igor Voynov on 28.03.2018.
//

import Foundation

public extension Geometry {

  internal func getIntersectPoints(curves1: [GCurveSegment], curves2: [GCurveSegment]) -> [GPoint] {
    let cgCurve: GCurve = GCurve()
    var points: [GPoint] = []
    for curve1 in curves1 {
      let s = GSubCurveSegment(curve: curve1)
      for curve2 in curves2 {
        let rr = getIntersect(c1: [s], c2: [GSubCurveSegment(curve: curve2)])
        for intersection in rr {
          points.append(cgCurve.getCubicPoint(curve: curve1, t: intersection.t1))
        }
      }
    }
    return points
  }

  internal func getIntersectPoints(segment1: GSegment, segment2: GSegment) -> [GPoint] {
    return GSegment.intersect(segment1: segment1, segment2: segment2)
  }

  internal func getIntersectPoints(curves: [GCurveSegment], segment: GSegment) -> [GPoint] {
    let segmentDirection = (segment.end - segment.begin).normalize()
    let segmentLength = (segment.end - segment.begin).length
    let cgCurve: GCurve = GCurve()
    var points: [GPoint] = []
    for curve in curves {
      let intersections = roots(curve: curve, segment: segment).map({ (t: Float) -> GIntersection in
        let p = cgCurve.getCubicPoint(curve: curve, t: t) - segment.begin
        let t2 = p.dot(segmentDirection) / segmentLength
        return GIntersection(t1: t, t2: t2)
      }).filter({$0.t2 >= 0.0 && $0.t2 <= 1.0}).sorted()
      for intersection in intersections {
        points.append(cgCurve.getCubicPoint(curve: curve, t: intersection.t1))
      }
    }
    return points
  }

  // MARK: - Private Methods

  private func pairIteration(_ c1: GSubCurveSegment, _ c2: GSubCurveSegment,
                             _ results: inout [GIntersection], _ threshold: Float = 0.5) {

    let c1b = c1.curve.boundingBox
    let c2b = c2.curve.boundingBox

    if c1b.overlaps(c2b) == false {
      return
    } else if (c1b.size.x + c1b.size.y) < threshold && (c2b.size.x + c2b.size.y) < threshold {
      let a1 = c1.curve.begin
      let b1 = c1.curve.end - c1.curve.begin
      let a2 = c2.curve.begin
      let b2 = c2.curve.end - c2.curve.begin

      let a = b1.x
      let b = -b2.x
      let c = b1.y
      let d = -b2.y
      let e = -a1.x + a2.x
      let f = -a1.y + a2.y

      let invDet = 1.0 / (a * d - b * c)
      let t1 = ( e * d - b * f ) * invDet
      if t1 > 1.0 || t1 < 0.0 {
        return // t1 out of interval [0, 1]
      }
      let t2 = ( a * f - e * c ) * invDet
      if t2 > 1.0 || t2 < 0.0 {
        return // t2 out of interval [0, 1]
      }
      // segments intersect at t1, t2
      results.append(GIntersection(t1: t1 * c1.t2 + (1.0 - t1) * c1.t1,
                                   t2: t2 * c2.t2 + (1.0 - t2) * c2.t1))
    } else {
      let cc1 = c1.split(at: 0.5)
      let cc2 = c2.split(at: 0.5)
      pairIteration(cc1.left, cc2.left, &results, threshold)
      pairIteration(cc1.left, cc2.right, &results, threshold)
      pairIteration(cc1.right, cc2.left, &results, threshold)
      pairIteration(cc1.right, cc2.right, &results, threshold)
    }
  }

  private func getIntersect(c1: [GSubCurveSegment], c2: [GSubCurveSegment],
                            threshold: Float = 0.5) -> [GIntersection] {
    var inters: [GIntersection] = []
    for l in c1 {
      for r in c2 {
        pairIteration(l, r, &inters, threshold)
      }
    }
    // sort the results by t1 (and by t2 if t1 equal)
    inters = inters.sorted(by: <)
    // de-dupe the sorted array
    inters = inters.reduce([], {(inters: [GIntersection], next: GIntersection) in
      return (inters.count == 0 || inters[inters.count-1] != next) ? inters + [next] : inters
    })
    return inters
  }
}
