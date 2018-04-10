//
//  Geometry+Statics.swift
//  Geometry
//
//  Created by Igor Voynov on 30.03.2018.
//

import Foundation

extension Geometry {

  internal static func align(_ points: [GPoint], p1: GPoint, p2: GPoint) -> [GPoint] {
    let tx = p1.x
    let ty = p1.y
    let a = -atan2(p2.y-ty, p2.x-tx)
    let d = { (v: GPoint) in
      return GPoint(
        x: (v.x-tx)*cos(a) - (v.y-ty)*sin(a),
        y: (v.x-tx)*sin(a) + (v.y-ty)*cos(a)
      )
    }
    return points.map(d)
  }

  internal static func lerp(_ r: Float, _ v1: GPoint, _ v2: GPoint) -> GPoint {
    return v1 + r * (v2 - v1)
  }

  internal static func map(_ v: Float, _ ds: Float, _ de: Float, _ ts: Float, _ te: Float) -> Float {
    let r = (v-ds)/(de-ds)
    return ts + (te-ts)*r
  }

  internal static func angle(o: GPoint, v1: GPoint, v2: GPoint) -> Float {
    let dx1 = v1.x - o.x
    let dy1 = v1.y - o.y
    let dx2 = v2.x - o.x
    let dy2 = v2.y - o.y
    let cross = dx1*dy2 - dy1*dx2
    let dot = dx1*dx2 + dy1*dy2
    return atan2(cross, dot)
  }

  internal static func clamp(_ x: Float, _ a: Float, _ b: Float) -> Float {
    precondition(b >= a)
    switch x {
    case _ where x < a: return a
    case _ where x > b: return b
    default: return x
    }
  }

  internal static func lli4(_ p1: GPoint, _ p2: GPoint, _ p3: GPoint, _ p4: GPoint) -> GPoint? {
    let nx = (p1.x*p2.y-p1.y*p2.x)*(p3.x-p4.x)-(p1.x-p2.x)*(p3.x*p4.y-p3.y*p4.x)
    let ny = (p1.x*p2.y-p1.y*p2.x)*(p3.y-p4.y)-(p1.y-p2.y)*(p3.x*p4.y-p3.y*p4.x)
    let d = (p1.x-p2.x)*(p3.y-p4.y)-(p1.y-p2.y)*(p3.x-p4.x)
    return d != 0 ? GPoint(x: nx/d, y: ny/d) : nil
  }

}
