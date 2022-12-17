//
//  Quake.swift
//  everyearthquake
//
//  Created by David Barkman on 12/15/22.
//

import SwiftUI

struct Quake: Codable, Equatable, Hashable, Identifiable {
  var id: String
  var magnitude: String
  var type: String
  var title: String
  var date: Date
  var time: String
  var url: String
  var tsunami: String
  var depth: String
  var latitude: String
  var longitude: String
  var place: String
  var location: String
  var continent: String
  var country: String
  var subnational: String
  var city: String
  var locality: String
  var postcode: String
  var what3words: String?
  var timezone: String

  enum CodingKeys: String, CodingKey {
    case id, magnitude, type, title, date, time, url, tsunami, depth, latitude, longitude, place, location, continent, country, subnational, city, locality, postcode, what3words, timezone
  }
}

extension Quake {
  var color: Color {
    switch Double(magnitude) ?? 0 {
      case 0..<1:
        return .green
      case 1..<2:
        return .yellow
      case 2..<3:
        return .orange
      case 3..<5:
        return .red
      case 5..<Double.greatestFiniteMagnitude:
        return .init(red: 0.8, green: 0.2, blue: 0.7)
      default:
        return .gray
    }
  }
}
