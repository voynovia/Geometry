//
//  Geometry+Offset.swift
//  Geometry
//
//  Created by Igor Voynov on 30.03.2018.
//

import Foundation

extension Geometry {
  public func twinCurve(_ points: [GPoint], with distance: Float) -> [GPoint] {
    // FIXME: - if acute a corner, then breaks
    let curveSegments = GCurve().getCurveSegments(points: points)

//    let twinSegments = curveSegments.compactMap { $0.offset(distance: distance).last }

    var twinSegments = curveSegments.compactMap { $0.offset(distance: distance) }.reduce([], +)
    if twinSegments.count > 4 {
      twinSegments[0].end = twinSegments.remove(at: 1).end
      let prelast = twinSegments.remove(at: twinSegments.count-2)
      twinSegments[twinSegments.count-1].begin = prelast.begin
    }

    return ([twinSegments.first?.begin] + twinSegments.map({$0.end})).compactMap {$0}
  }

  public func twinSegment(_ points: [GPoint], with distance: Float) -> [GPoint] {
    let segments = GSegment.getSegments(from: points)
    var offsets = segments.map { $0.setOffset(distance) }
    for i in 1..<offsets.count {
      var intersect = Geometry().getIntersectPoints(points1: [offsets[i-1].begin, offsets[i-1].end],
                                                    points2: [offsets[i].begin, offsets[i].end]).first
      while intersect == nil {
        offsets[i-1].resize(lenght: offsets[i-1].length, toEnd: true)
        offsets[i].resize(lenght: offsets[i].length, toEnd: false)
        intersect = Geometry().getIntersectPoints(points1: [offsets[i-1].begin, offsets[i-1].end],
                                                  points2: [offsets[i].begin, offsets[i].end]).first
      }
      offsets[i-1].end = intersect!
      offsets[i].begin = intersect!
      if i-1 == 0 {
        offsets[i-1].resize(lenght: segments[i-1].length - offsets[i-1].length, toEnd: false)
      }
      offsets[i].resize(lenght: segments[i].length - offsets[i].length,
                   toEnd: true)
    }
    return offsets.reduce([], {$0 + [$1.begin, $1.end]}).removingDuplicates()
  }
}
