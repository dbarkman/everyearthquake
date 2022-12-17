//
//  DateTime.swift
//  everyearthquake
//
//  Created by David Barkman on 12/16/22.
//

import Foundation

struct DateTime {
  
  static let shared = DateTime()
  
  private init() { }
  
  func makeStringFromDate(date: Date, dateFormat: DateFormatter.Style, timeFormat: DateFormatter.Style) -> String {
    let localDate = date.convertToTimeZone(initTimeZone: TimeZone(identifier: "UTC")!, timeZone: .current)
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = dateFormat
    dateFormatter.timeStyle = timeFormat
    return dateFormatter.string(from: localDate)
  }
}

extension Date {
  func convertToTimeZone(initTimeZone: TimeZone, timeZone: TimeZone) -> Date {
    let delta = TimeInterval(timeZone.secondsFromGMT(for: self) - initTimeZone.secondsFromGMT(for: self))
    return addingTimeInterval(delta)
  }
}
