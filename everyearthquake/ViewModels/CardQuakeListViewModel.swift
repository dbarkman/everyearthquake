//
//  CardQuakeListViewModel.swift
//  everyearthquake
//
//  Created by David Barkman on 12/30/22.
//

import Foundation

import Mixpanel
import OSLog

class CardQuakeListViewModel: ObservableObject {
  
  let logger = Logger(subsystem: "com.dbarkman.everyearthquake", category: "CardQuakeListViewModel")
  
  static let shared = CardQuakeListViewModel()
  
  private init() { }
  
  @Published var fetching = false
  @Published var quakes: [Day] = []
  
  func getQuakes(card: String) async {
    DispatchQueue.main.async {
      self.fetching = true
    }

    var url = ""
    switch card {
      case "thing1":
        url = "thing1"
      default:
        url = "thing"
    }
    if let response = await AsyncAPI.shared.getCardQuakes(url: url) {
      DispatchQueue.main.async {
        self.quakes.removeAll()
      }
      
      for var quake in response.quakes {
        if quake.country.hasSuffix(" (the)") {
          quake.country = String(quake.country.dropLast(6))
        }
        if quake.distanceKM == "0" {
          quake.formattedTitle = quake.placeOnly
        } else {
          quake.formattedTitle = "\(Formatters.shared.format(distance: Double(quake.distanceKM) ?? 0, from: .kilometers)) \(quake.placeOnly)"
        }
        let sectionHeader = DateTime.shared.makeStringFromDate(date: quake.date, dateFormat: .full, timeFormat: .none)
        if let sectionIndex = self.quakes.firstIndex(where: { $0.title == sectionHeader }) {
          self.quakes[sectionIndex].quakes.append(quake)
        } else {
          let day = Day(title: sectionHeader, quakes: [quake], date: quake.date)
          self.quakes.append(day)
        }
      }
    } else {
      logger.error("Couldn't get new card quakes from AsyncAPI.")
    }
    
    DispatchQueue.main.async {
      self.fetching = false
    }
  }
  
}
