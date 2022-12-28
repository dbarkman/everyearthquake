//
//  LocationViewModel.swift
//  everyearthquake
//
//  Created by David Barkman on 7/7/22.
//

import Foundation
import CoreLocation
import Mixpanel

class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
  
  static let shared = LocationViewModel()
  
  @Published var lastSeenLocation: CLLocation? {
    didSet {
      guard oldValue != lastSeenLocation else { return }
    }
  }
  @Published var currentPlacemark: CLPlacemark? {
    didSet {
      guard oldValue != currentPlacemark else { return }
    }
  }
  @Published var authorizationStatus: CLAuthorizationStatus {
    didSet {
      guard oldValue != authorizationStatus else { return }
      if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
        UserDefaults.standard.set(true, forKey: "automaticLocationFilter")
      } else {
        Mixpanel.mainInstance().track(event: "Location Not Authorized")
        UserDefaults.standard.set(false, forKey: "automaticLocationFilter")
        guard let _ = UserDefaults.standard.string(forKey: "manualLocationDataFilter") else {
          UserDefaults.standard.set("&latitude=38.7998839&longitude=-123.0238556", forKey: "manualLocationDataFilter")
          return
        }
      }
    }
  }
  
  let locationManager: CLLocationManager
  
  override private init() {
    locationManager = CLLocationManager()
    authorizationStatus = locationManager.authorizationStatus
    
    super.init()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    locationManager.pausesLocationUpdatesAutomatically = true
    locationManager.startMonitoringSignificantLocationChanges()
  }
  
  func requestPermission() {
    locationManager.requestWhenInUseAuthorization()
  }
  
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    authorizationStatus = manager.authorizationStatus
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    lastSeenLocation = locations.first
  }
}
