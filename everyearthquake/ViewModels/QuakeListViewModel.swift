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
  
  private init() {
    NotificationCenter.default.addObserver(self, selector: #selector(overrideGetQuakes), name: .notificationReceivedEvent, object: nil)
  }

  @Published var start = 0
  @Published var count = 100
  @Published var fetching = false
  @Published var quakes: [Day] = []
  @Published var magnitude: String = "All Magnitudes"
  @Published var type: String = "All Types"
  @Published var filterEventsByLocation = false

  private var location = ""
  private var radius = ""
  private var units = ""

  let magDict: [String:String] = ["All Magnitudes":"0", "Magnitude 1 and greater":"1", "Magnitude 2 and greater":"2", "Magnitude 3 and greater":"3", "Magnitude 4 and greater":"4", "Magnitude 5 and greater":"5", "Magnitude 6 and greater":"6", "Magnitude 7 and greater":"7", "Magnitude 8 and greater":"8", "Magnitude 9 and greater":"9"]

  @objc private func overrideGetQuakes() {
    Task {
      await getQuakes(start: 0, count: count)
    }
  }
  
  func getQuakes(start: Int, count: Int) async {
    if getQuakesYet() {
      DispatchQueue.main.async {
        self.fetching = true
      }
      let selectedMagnitude = magDict[magnitude] ?? "0"
      let selectedType = self.type == "All Types" ? "" : self.type
      
      if selectedMagnitude != "0" {
        Mixpanel.mainInstance().track(event: "Filtering Events by Magnitude \(selectedMagnitude)")
      }
      Mixpanel.mainInstance().track(event: "Filtering Events by \(type)")
      
      if UserDefaults.standard.bool(forKey: "filterEventsByLocation") {
        DispatchQueue.main.async {
          self.filterEventsByLocation = true
        }
        location = await Location.getLocation()
        radius = UserDefaults.standard.string(forKey: "radiusSelectedFilter") ?? "1000"
        units = UserDefaults.standard.integer(forKey: "unitsSelectedFilter") == 0 ? "miles" : "kilometers"
        Mixpanel.mainInstance().track(event: "Filtering Events distance by \(units)", properties: ["radius": radius])
      } else {
        location = ""
      }
      
      if let response = await AsyncAPI.shared.getQuakes(start: start, count: count, magnitude: selectedMagnitude, type: selectedType, location: location, radius: radius, units: units) {
        
        DispatchQueue.main.async {
          if start == 0 {
            self.quakes.removeAll()
          } else if start > 0 {
            Review.secondPageViewed()
            Mixpanel.mainInstance().track(event: "Page \(start / 100) Viewed")
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
  
  private func getQuakesYet() -> Bool {
    let now = Date()
    var nextUpdate: Date
    if let quakesNextUpdate = UserDefaults.standard.object(forKey: "quakesNextUpdate") as? Date {
      nextUpdate = quakesNextUpdate
    } else {
      nextUpdate = Date(timeIntervalSince1970: 0)
    }
    if now > nextUpdate {
      nextUpdate = Calendar.current.date(byAdding: .minute, value: 1, to: Date()) ?? Date()
      UserDefaults.standard.set(nextUpdate, forKey: "quakesNextUpdate")
      return true
    } else {
      return true
//      return false //turning off for now
    }
  }

}
