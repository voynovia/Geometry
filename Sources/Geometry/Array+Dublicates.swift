//
//  Array+Unique.swift
//  Geometry
//
//  Created by Igor Voynov on 30.03.2018.
//

import Foundation

public extension Array where Element: Equatable {
  func removingDuplicates() -> Array {
    return reduce([], { $0.contains($1) ? $0 : $0 + [$1] })
  }
}
