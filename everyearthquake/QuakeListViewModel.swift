//
//  QuakeListViewModel.swift
//  everyearthquake
//
//  Created by David Barkman on 12/15/22.
//

import Foundation
import OSLog

class QuakeListViewModel: ObservableObject {
  
  let logger = Logger(subsystem: "com.dbarkman.everyearthquake", category: "QuakeListViewModel")
  
  static let shared = QuakeListViewModel()
  
  private init() { }

  @Published public var quakes: [Day] = []
  
  func getQuakes(start: Int, count: Int) async {
    if let response = await AsyncAPI.shared.getQuakes(start: start, count: count) {
      
      DispatchQueue.main.async {
        if start == 0 {
          self.quakes.removeAll()
        }

        for quake in response.quakes {
          let sectionHeader = DateTime.shared.makeStringFromDate(date: quake.date, dateFormat: .full, timeFormat: .none)
          if let sectionIndex = self.quakes.firstIndex(where: { $0.title == sectionHeader }) {
            self.quakes[sectionIndex].quakes.append(quake)
          } else {
            let day = Day(title: sectionHeader, quakes: [quake], date: quake.date)
            self.quakes.append(day)
          }
        }
      }
    } else {
      logger.error("Couldn't get new quakes from AsyncAPI.")
    }
  }
  
}
