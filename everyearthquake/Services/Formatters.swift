//
//  Formatters.swift
//  everyearthquake
//
//  Created by David Barkman on 12/18/22.
//

import Foundation

struct Formatters {
  
  static let shared = Formatters()
  
  private init() { }
  
  func format(distance: Double, from unit: UnitLength, natural: Bool = false) -> String {
    let formatter = MeasurementFormatter()
    formatter.unitStyle = .medium
    formatter.numberFormatter.roundingMode = .halfUp
    formatter.numberFormatter.maximumFractionDigits = 1
    if natural { formatter.unitOptions = .naturalScale }
    let measurement = Measurement(value: distance, unit: unit)
    return formatter.string(from: measurement)
  }

}
