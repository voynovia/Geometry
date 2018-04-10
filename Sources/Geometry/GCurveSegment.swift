//
//  GCurveSegment.swift
//  Geometry
//
//  Created by Igor Voynov on 29.03.2018.
//

import Foundation

open class GCurveSegment {

  typealias CNP = (c: GPoint, n: GPoint, p: GPoint)

  public var begin: GPoint
  public var cp1: GPoint
  public var cp2: GPoint
  public var end: GPoint

  var order: Int {
    return 3
  }

  var points: [GPoint] {
    return [begin, cp1, cp2, end]
  }

  public var simple: Bool {
    let a1 = Geometry.angle(o: begin, v1: end, v2: cp1)
    let a2 = Geometry.angle(o: begin, v1: end, v2: cp2)
    if a1>0 && a2<0 || a1<0 && a2>0 {
      return false
    }
    let n1 = normal(0)
    let n2 = normal(1)
    let s = Geometry.clamp(n1.dot(n2), -1.0, 1.0)
    let angle: Float = Float(abs(acos(Double(s))))
    return angle < (Float.pi / 3.0)
  }

  public var boundingBox: GBox {
    let mmin = GPoint.min(p1: begin, p2: end)
    let mmax = GPoint.max(p1: begin, p2: end)
    let d0 = cp1 - begin
    let d1 = cp2 - cp1
    let d2 = end - cp2
    for d in 0..<GPoint.dimensions {
      Geometry().droots(d0[d], d1[d], d2[d]).forEach { result in
        if result <= 0.0 || result >= 1.0 { return }
        let value = GCurve().getCubicPoint(curve: self, t: result)[d]
        if value < mmin[d] {
          mmin[d] = value
        } else if value > mmax[d] {
          mmax[d] = value
        }
      }
    }
    return GBox(min: mmin, max: mmax)
  }

  private var dpoints: [[GPoint]] {
    var ret: [[GPoint]] = []
    var p = points
    ret.reserveCapacity(p.count-1)
    for d in (2...p.count).reversed() {
      let c = d-1
      var list: [GPoint] = []
      list.reserveCapacity(c)
      for j in 0..<c {
        let dpt: GPoint = Float(c) * (p[j+1] - p[j])
        list.append(dpt)
      }
      ret.append(list)
      p = list
    }
    return ret
  }

  public init(points: [GPoint]) {
    precondition(points.count == 4)
    self.begin = points[0]
    self.cp1 = points[1]
    self.cp2 = points[2]
    self.end = points[3]
  }

  public init(begin: GPoint, cp1: GPoint, cp2: GPoint, end: GPoint) {
    self.begin = begin
    self.cp1 = cp1
    self.cp2 = cp2
    self.end = end
  }

  public func split(at t: Float) -> (left: GCurveSegment, right: GCurveSegment) {
    let h4 = Geometry.lerp(t, begin, cp1)
    let h5 = Geometry.lerp(t, cp1, cp2)
    let h6 = Geometry.lerp(t, cp2, end)
    let h7 = Geometry.lerp(t, h4, h5)
    let h8 = Geometry.lerp(t, h5, h6)
    let h9 = Geometry.lerp(t, h7, h8)
    return (
      GCurveSegment(begin: begin, cp1: h4, cp2: h7, end: h9),
      GCurveSegment(begin: h9, cp1: h8, cp2: h6, end: end)
    )
  }

  public func split(from t1: Float, to t2: Float) -> GCurveSegment {
    let tr = Geometry.map(t2, t1, 1, 0, 1)
    let h4 = Geometry.lerp(t1, begin, cp1)
    let h5 = Geometry.lerp(t1, cp1, cp2)
    let h6 = Geometry.lerp(t1, cp2, end)
    let h7 = Geometry.lerp(t1, h4, h5)
    let h8 = Geometry.lerp(t1, h5, h6)
    let h9 = Geometry.lerp(t1, h7, h8)
    let i4 = Geometry.lerp(tr, h9, h8)
    let i5 = Geometry.lerp(tr, h8, h6)
    let i6 = Geometry.lerp(tr, h6, end)
    let i7 = Geometry.lerp(tr, i4, i5)
    let i8 = Geometry.lerp(tr, i5, i6)
    let i9 = Geometry.lerp(tr, i7, i8)
    return GCurveSegment(begin: h9, cp1: i4, cp2: i7, end: i9)
  }

  public func scale(distance d: Float?, function distanceFn: ((Float) -> Float)?) -> GCurveSegment {
    precondition((d != nil && distanceFn == nil) || (d == nil && distanceFn != nil))

    let r1 = (distanceFn != nil) ? distanceFn!(0) : d!
    let r2 = (distanceFn != nil) ? distanceFn!(1) : d!
    var v = [0, 1].map { offset(t: $0, distance: 10) }
    // move all points by distance 'd' wrt the origin 'o'
    var np: [GPoint] = [GPoint](repeating: GPoint.zero, count: order + 1)

    // move end points by fixed distance along normal.
    for t in [0, 1] {
      let p: GPoint = points[t*order]
      np[t*order] = p + ((t != 0) ? r2 : r1) * v[t].n
    }

    let o = Geometry.lli4(v[0].p, v[0].c, v[1].p, v[1].c)

    if d != nil {
      // move control points to lie on the intersection of the offset
      // derivative vector, and the origin-through-control vector
      for t in [0, 1] {
        let p = np[t*order] // either the first or last of np
        let d = derivative(Float(t))
        let p2 = p + d
        let o2 = (o != nil) ? o! : points[t+1] - normal(Float(t))
        np[t+1] = Geometry.lli4(p, p2, o2, points[t+1])!
      }
      return GCurveSegment(points: np)
    } else {
      let clockwise: Bool = {
        let angle = Geometry.angle(o: points[0], v1: points[order], v2: points[1])
        return angle > 0
      }()
      for t in [0, 1] {
        let p = points[t+1]
        let ov = ((o != nil) ? (p - o!) : (p - normal(Float(t)))).normalize()
        var rc: Float = distanceFn!(Float(t+1) / Float(order))
        if !clockwise {
          rc = -rc
        }
        np[t+1] = p + rc * ov
      }
      return GCurveSegment(points: np)
    }
  }

  private func offset(t: Float, distance d: Float) -> CNP {
    let c = GCurve().getCubicPoint(curve: self, t: t)
    let n = normal(t)
    return (c, n, c + d * n)
  }

  public func offset(distance d: Float) -> [GCurveSegment] {
    if linear {
      let n = normal(0)
      let coords: [GPoint] = points.map { $0 + d * n }
      return [GCurveSegment(points: coords)]
    }
    return reduce().map { $0.curve.scale(distance: d, function: nil) }
  }

  private func normal(_ t: Float) -> GPoint {
    let d = derivative(t)
    let q = d.length
    return GPoint(x: -d.y/q, y: d.x/q)
  }

  private func derivative(_ t: Float) -> GPoint {
    let mt: Float = 1-t
    let k: Float = 3
    let p0 = k * (cp1 - begin)
    let p1 = k * (cp2 - cp1)
    let p2 = k * (end - cp2)
    let a = pow(mt, 2)
    let b = mt*t*2
    let c = pow(t, 2)
    return a*p0 + b*p1 + c*p2
  }

  private var linear: Bool {
    var a = Geometry.align(points, p1: points[0], p2: points[order])
    for i in 0..<a.count {
      if abs(a[i].y) > 0.0001 { // it's magic
        return false
      }
    }
    return true
  }

  private func bisectionMethod(min: Float, max: Float,
                               tolerance: Float, completion: (Float) -> Bool) -> Float {
    var lb = min // lower bound (callback(x <= lb) should return true
    var ub = max // upper bound (callback(x >= ub) should return false
    while (ub - lb) > tolerance {
      let val = 0.5 * (lb + ub)
      if completion(val) {
        lb = val
      } else {
        ub = val
      }
    }
    return lb
  }

  private func reduce() -> [GSubCurveSegment] {

    let step: Float = 0.01
    var extrema = getExtrema().values
    extrema = extrema.filter {
      switch $0 {
      case _ where $0 < step: return false
      case _ where (1.0 - $0) < step: return false
      default: return true
      }
    }
    // aritifically add 0.0 and 1.0 to our extreme points
    extrema.insert(0.0, at: 0)
    extrema.append(1.0)

    // first pass: split on extrema
    var pass1: [GSubCurveSegment] = []
    pass1.reserveCapacity(extrema.count-1)
    for i in 0..<extrema.count-1 {
      let t1 = extrema[i]
      let t2 = extrema[i+1]
      let curve = self.split(from: t1, to: t2)
      pass1.append(GSubCurveSegment(t1: t1, t2: t2, curve: curve))
    }

    // second pass: further reduce these segments to simple segments
    var pass2: [GSubCurveSegment] = []
    pass2.reserveCapacity(pass1.count)
    pass1.forEach { p1 in
      var t1: Float = 0.0
      while t1 < 1.0 {
        let fullSegment = p1.split(from: t1, to: 1.0)
        if (1.0 - t1) <= step || fullSegment.curve.simple {
          pass2.append(fullSegment)
          t1 = 1.0
        } else {
          let t2 = bisectionMethod(min: t1 + step, max: 1.0, tolerance: step) {
            return p1.split(from: t1, to: $0).curve.simple
          }
          let partialSegment = p1.split(from: t1, to: t2)
          pass2.append(partialSegment)
          t1 = t2
        }
      }
    }

    return pass2
  }

  private func getExtrema() -> (xyz: [[Float]], values: [Float]) {
    var xyz: [[Float]] = []
    xyz.reserveCapacity(GPoint.dimensions)
    for d in 0..<GPoint.dimensions {
      let mfn = { (v: GPoint) in v[d] }
      var p: [Float] = dpoints[0].map(mfn)
      xyz.append(Geometry().droots(p))
      p = dpoints[1].map(mfn)
      xyz[d] += Geometry().droots(p)
      xyz[d] = xyz[d].filter({$0 >= 0 && $0 <= 1}).sorted()
    }
    let values = xyz.reduce([], +).removingDuplicates()
    return (xyz: xyz, values: values)
  }
}

extension GCurveSegment: Equatable {
  public static func == (lhs: GCurveSegment, rhs: GCurveSegment) -> Bool {
    return
      lhs.begin == rhs.begin &&
      lhs.cp1 == rhs.cp1 &&
      lhs.cp2 == rhs.cp2 &&
      lhs.end == rhs.end
  }
}
