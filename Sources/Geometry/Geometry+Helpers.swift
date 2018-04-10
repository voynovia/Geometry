//
//  Geometry+Helpers.swift
//  Geometry
//
//  Created by Igor Voynov on 30.03.2018.
//

import Foundation

extension Geometry {

  internal func align(_ curve: GCurveSegment, segment: GSegment) -> [GPoint] {
    let tx = segment.begin.x
    let ty = segment.begin.y
    let a = -atan2(segment.end.y-ty, segment.end.x-tx)
    let d: (GPoint) -> GPoint = {
      return GPoint(
        x: ($0.x-tx)*cos(a) - ($0.y-ty)*sin(a),
        y: ($0.x-tx)*sin(a) + ($0.y-ty)*cos(a)
      )
    }
    return curve.points.map(d)
  }

  private func crt(_ v: Float) -> Float {
    return (v < 0) ? -pow(-v, 1.0/3.0) : pow(v, 1.0/3.0)
  }

  internal func roots(curve: GCurveSegment, segment: GSegment) -> [Float] {
    let pp = align(curve, segment: segment)

    let epsilon: Float = 1.0e-6
    let reduce: (Float) -> Bool = { (-epsilon) <= $0 && $0 <= (1 + epsilon) }
    let clamp: (Float) -> Float = {
      switch $0 {
      case ..<0.0: return 0.0
      case 1...: return 1.0
      default: return $0
      }
    }

    let pa = pp[0].y, pb = pp[1].y, pc = pp[2].y, pd = pp[3].y
    let d = -pa + 3*pb + -3*pc + pd
    let a = (3*pa - 6*pb + 3*pc) / d
    let b = (-3*pa + 3*pb) / d
    let p = (3*b - pow(a, 2))/3
    let q = (2*pow(a, 3) - 9*a*b + 27*pa/d)/27
    let q2 = q/2
    let discriminant = pow(q2, 2) + pow(p/3, 3)
    let tau: Float = 2.0 * Float.pi
    switch discriminant {
    case ..<0:
      let r = sqrt(pow(-p/3, 3))
      let t = -q/(2*r)
      let cosphi = t < -1 ? -1 : t > 1 ? 1 : t
      let phi = acos(cosphi)
      let crtr = crt(r)
      let t1 = 2*crtr
      let x1 = t1 * cos(phi/3) - a/3
      let x2 = t1 * cos((phi+tau)/3) - a/3
      let x3 = t1 * cos((phi+2*tau)/3) - a/3
      return [x1, x2, x3].filter(reduce).map(clamp)
    case 1:
      let u1 = q2 < 0 ? crt(-q2) : -crt(q2)
      let x1 = 2*u1-a/3
      let x2 = -u1 - a/3
      return [x1, x2].filter(reduce).map(clamp)
    default:
      let sd = sqrt(discriminant)
      let u1 = crt(-q2+sd)
      let v1 = crt(q2+sd)
      return [u1-v1-a/3].filter(reduce).map(clamp)
    }
  }

  internal func droots(_ a: Float, _ b: Float, _ c: Float) -> [Float] {
    var result: [Float] = []
    let d: Float = a - 2.0*b + c
    if d != 0 {
      let m1 = -sqrt(b*b-a*c)
      let m2 = -a+b
      result = [-( m1+m2)/d, -(-m1+m2)/d]
    } else if (b != c) && (d == 0) {
      result = [(2*b-c)/(2*(b-c))]
    }
    return result
  }

  internal func droots(_ a: Float, _ b: Float) -> [Float] {
    return a != b ? [a/(a-b)] : []
  }

  internal func droots(_ p: [Float]) -> [Float] {
    var result: [Float] = []
    switch p.count {
    case 3: result += droots(p[0], p[1], p[2])
    case 2: result += droots(p[0], p[1])
    default: fatalError("unsupported")
    }
    return result
  }

}
