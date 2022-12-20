//
//  Location.swift
//  everyearthquake
//
//  Created by David Barkman on 12/18/22.
//

import Foundation

struct Location {

  static func getLocation() async -> String {
    let authorizationStatus = LocationViewModel.shared.authorizationStatus
    if !UserDefaults.standard.bool(forKey: "automaticLocation") {
      guard let manualLocationData = UserDefaults.standard.string(forKey: "manualLocationData") else {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
          UserDefaults.standard.set(true, forKey: "automaticLocation")
          return await getAutomaticLocation()
        } else {
          UserDefaults.standard.set(false, forKey: "automaticLocation")
          UserDefaults.standard.set("&latitude=38.7998839&longitude=-123.0238556", forKey: "manualLocationData")
          return "&latitude=38.7998839&longitude=-123.0238556"
        }
      }
      if !manualLocationData.isEmpty {
        if let latitude = manualLocationData.components(separatedBy: ",").first, let longitude = manualLocationData.components(separatedBy: ",").last {
          return "&latitude=\(latitude)&longitude=\(longitude)"
        }
      }
      return "&latitude=38.7998839&longitude=-123.0238556"
    } else {
      if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
        return await getAutomaticLocation()
      } else {
        return "&latitude=38.7998839&longitude=-123.0238556"
      }
    }
  }
  
  private static func getAutomaticLocation() async -> String {
    let locationManager = LocationViewModel.shared.locationManager
    if let location = locationManager.location {
      let latitude = location.coordinate.latitude
      let longitude = location.coordinate.longitude
      return "&latitude=\(latitude)&longitude=\(longitude)"
    } else {
      return "&latitude=38.7998839&longitude=-123.0238556"
    }
  }

}
