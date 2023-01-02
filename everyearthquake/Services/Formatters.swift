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
  
  func formatNumber(_ number: String) -> String {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    guard let formattedNumber = numberFormatter.string(from: NSNumber(value: Int(number) ?? 0)) else { return "" }
    return formattedNumber
  }
  
  func convertToRoman(number: String) -> String {
    switch number {
      case "1":
        return "I"
      case "2":
        return "II"
      case "3":
        return "III"
      case "4":
        return "IV"
      case "5":
        return "V"
      case "6":
        return "VI"
      case "7":
        return "VII"
      case "8":
        return "VIII"
      case "9":
        return "IX"
      case "10":
        return "X"
      default:
        return ""
    }
  }

}
