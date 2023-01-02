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
    self.startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
    NotificationCenter.default.addObserver(self, selector: #selector(overrideGetQuakes), name: .notificationReceivedEvent, object: nil)
  }

  @Published var start = 0
  @Published var count = 100
  @Published var fetching = false
  @Published var quakes: [Day] = []
  @Published var magnitude: String = "All Magnitudes"
  @Published var type: String = "All Types"
  @Published var sortBy: String = "Date"
  @Published var filterEventsByDate = false
  @Published var startDate: Date
  @Published var endDate = Date()
  @Published var filterEventsByLocation = false
  @Published var automaticLocation = true
  @Published var radius = ""
  @Published var units = "miles"
  
  private var location = ""

  let magDict: [String:String] = ["All Magnitudes":"0", "Magnitude 1 and greater":"1", "Magnitude 2 and greater":"2", "Magnitude 3 and greater":"3", "Magnitude 4 and greater":"4", "Magnitude 5 and greater":"5", "Magnitude 6 and greater":"6", "Magnitude 7 and greater":"7", "Magnitude 8 and greater":"8", "Magnitude 9 and greater":"9"]
  let notificationsMagDict: [String:String] = ["All Magnitudes\rabout 350 per day":"0", "M 1 and greater\rabout 250 per day":"1", "M 2 and greater\rabout 100 per day":"2", "M 3 and greater\rabout 50 per day":"3", "M 4 and greater\rabout 35 per day":"4", "M 5 and greater\rabout 5 per day":"5", "M 6 and greater\rabout 4 per week":"6", "M 7 and greater\rabout 2 per month":"7", "M 8 and greater\rabout 1-2 per year":"8", "M 9 and greater\rrare, 1 in every 1 million":"9"]
  let sortByDict = ["Date":"time", "Magnitude":"magnitude", "Significance":"sig", "Felt It Reports":"felt", "Felt Intensity":"cdi DESC,felt", "Measured Intensity":"mmi"]

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
      
      var startDateString = ""
      var endDateString = ""
      if filterEventsByDate {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        startDateString = dateFormatter.string(from: startDate)
        endDateString = dateFormatter.string(from: endDate)
        Mixpanel.mainInstance().track(event: "Filtering Events by date", properties: ["startDate": startDateString, "endDate": endDateString])
      }
      
      if filterEventsByLocation {
        location = await Location.getLocation()
        Mixpanel.mainInstance().track(event: "Filtering Events distance by \(units)", properties: ["radius": radius])
      } else {
        location = ""
      }
      
      let orderBy = sortByDict[sortBy] ?? "time"
      
      if let response = await AsyncAPI.shared.getQuakes(start: start, count: count, magnitude: selectedMagnitude, type: selectedType, startDate: startDateString, endDate: endDateString, location: location, radius: radius, units: units, orderBy: orderBy) {
        
        DispatchQueue.main.async {
          if start == 0 {
            self.quakes.removeAll()
          } else if start > 0 {
            Review.secondPageViewed()
            Mixpanel.mainInstance().track(event: "Page \(start / 100 + 1) Viewed")
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
            
            var sectionHeader: String
            switch orderBy {
              case "magnitude":
                sectionHeader = "Magnitude " + quake.magnitude
              case "sig":
                sectionHeader = "Significance: " + Formatters.shared.formatNumber(quake.sig)
              case "felt":
                sectionHeader = "Felt It Reports: " + Formatters.shared.formatNumber(quake.felt)
              case "cdi DESC,felt":
                sectionHeader = "Felt It Intensity: " + Formatters.shared.convertToRoman(number: quake.cdi)
              case "mmi":
                sectionHeader = "Measured Intensity: " + Formatters.shared.convertToRoman(number: quake.mmi)
              default:
                sectionHeader = DateTime.shared.makeStringFromDate(date: quake.date, dateFormat: .full, timeFormat: .none)
            }
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
