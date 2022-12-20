//
//  EarthquakesResponse.swift
//  everyearthquake
//
//  Created by David Barkman on 12/15/22.
//

import Foundation

struct EarthquakesResponse: Codable {
  var quakes: [Quake] = []
  
  enum CodingKeys: String, CodingKey {
    case quakes = "data"
  }
}
