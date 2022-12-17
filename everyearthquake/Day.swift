//
//  Day.swift
//  everyearthquake
//
//  Created by David Barkman on 12/16/22.
//

import Foundation

struct Day: Equatable, Identifiable {
  var id = UUID()
  var title: String
  var quakes: [Quake]
  var date: Date
}
