//
//  Location.swift
//  everyearthquake
//
//  Created by David Barkman on 12/18/22.
//

import Foundation

struct Location {

  static func getLocation(forToken: Bool = false) async -> String {
    let authorizationStatus = LocationViewModel.shared.authorizationStatus
    if !UserDefaults.standard.bool(forKey: "automaticLocationFilter") {
      guard let manualLocationData = UserDefaults.standard.string(forKey: "manualLocationDataFilter") else {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
          UserDefaults.standard.set(true, forKey: "automaticLocationFilter")
          return await getAutomaticLocation(forToken: forToken)
        } else {
          UserDefaults.standard.set(false, forKey: "automaticLocationFilter")
          UserDefaults.standard.set("&latitude=38.7998839&longitude=-123.0238556", forKey: "manualLocationDataFilter")
          if forToken {
            return "38.7998839,123.0238556"
          } else {
            return "&latitude=38.7998839&longitude=-123.0238556"
          }
        }
      }
      if !manualLocationData.isEmpty {
        if let latitude = manualLocationData.components(separatedBy: ",").first, let longitude = manualLocationData.components(separatedBy: ",").last {
          if forToken {
            return manualLocationData
          } else {
            return "&latitude=\(latitude)&longitude=\(longitude)"
          }
        }
      }
      if forToken {
        return "38.7998839,123.0238556"
      } else {
        return "&latitude=38.7998839&longitude=-123.0238556"
      }
    } else {
      if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
        return await getAutomaticLocation(forToken: forToken)
      } else {
        if forToken {
          return "38.7998839,123.0238556"
        } else {
          return "&latitude=38.7998839&longitude=-123.0238556"
        }
      }
    }
  }
  
  private static func getAutomaticLocation(forToken: Bool = false) async -> String {
    let locationManager = LocationViewModel.shared.locationManager
    if let location = locationManager.location {
      let latitude = location.coordinate.latitude
      let longitude = location.coordinate.longitude
      if forToken {
        return "\(latitude),\(longitude)"
      } else {
        return "&latitude=\(latitude)&longitude=\(longitude)"
      }
    } else {
      if forToken {
        return "38.7998839,123.0238556"
      } else {
        return "&latitude=38.7998839&longitude=-123.0238556"
      }
    }
  }

}
