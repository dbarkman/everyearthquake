//
//  QuakeListViewModel.swift
//  everyearthquake
//
//  Created by David Barkman on 12/15/22.
//

import Foundation
import Mixpanel
import OSLog

class QuakeListViewModel: ObservableObject {
  
  let logger = Logger(subsystem: "com.dbarkman.everyearthquake", category: "QuakeListViewModel")
  
  static let shared = QuakeListViewModel()
  
  private init() { }

  @Published public var start = 0
  @Published public var count = 100
  @Published public var fetching = false
  @Published public var quakes: [Day] = []
  @Published public var magnitude: String = "All Magnitudes"
  @Published public var type: String = "All Types"

  private var location = ""
  private var radius = ""
  private var units = ""

  let magDict = ["All Magnitudes":"0", "Magnitude 1 and greater":"1", "Magnitude 2 and greater":"2", "Magnitude 3 and greater":"3", "Magnitude 4 and greater":"4", "Magnitude 5 and greater":"5", "Magnitude 6 and greater":"6", "Magnitude 7 and greater":"7", "Magnitude 8 and greater":"8", "Magnitude 9 and greater":"9"]

  func getQuakes(start: Int, count: Int) async {
    DispatchQueue.main.async {
      self.fetching = true
    }
    let selectedMagnitude = magDict[magnitude] ?? "0"
    let selectedType = self.type == "All Types" ? "" : self.type
    
    if selectedMagnitude != "0" {
      Mixpanel.mainInstance().track(event: "Filtering Events by Magnitude", properties: ["magnitude": selectedMagnitude])
    }
    if type != "All Types" {
      Mixpanel.mainInstance().track(event: "Filtering Events by Type", properties: ["type": type])
    }
    
    if UserDefaults.standard.bool(forKey: "filterEventsByLocation") {
      location = await Location.getLocation()
      radius = UserDefaults.standard.string(forKey: "radiusSelected") ?? "1000"
      units = UserDefaults.standard.integer(forKey: "unitsSelected") == 0 ? "miles" : "kilometers"
      Mixpanel.mainInstance().track(event: "Filtering Events distance by \(units)", properties: ["radius": radius])
    } else {
      location = ""
    }
    
    if let response = await AsyncAPI.shared.getQuakes(start: start, count: count, magnitude: selectedMagnitude, type: selectedType, location: location, radius: radius, units: units) {
      
      DispatchQueue.main.async {
        if start == 0 {
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
      }
    } else {
      logger.error("Couldn't get new quakes from AsyncAPI.")
    }
    DispatchQueue.main.async {
      self.fetching = false
    }
  }
  
}
