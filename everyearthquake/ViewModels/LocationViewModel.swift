//
//  LocationViewModel.swift
//  everyearthquake
//
//  Created by David Barkman on 7/7/22.
//

import Foundation
import CoreLocation
import Mixpanel
import OSLog

class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
  
  let logger = Logger(subsystem: "com.dbarkman.everyearthquake", category: "LocationViewModel")
  
  static let shared = LocationViewModel()
  
  @Published var lastSeenLocation: CLLocation? {
    didSet {
      guard oldValue != lastSeenLocation else { return }
      logger.debug("LocationManager lastSeenLocation updated")
    }
  }
  @Published var currentPlacemark: CLPlacemark? {
    didSet {
      guard oldValue != currentPlacemark else { return }
      logger.debug("LocationManager currentPlacemark updated")
    }
  }
  @Published var authorizationStatus: CLAuthorizationStatus {
    didSet {
      guard oldValue != authorizationStatus else { return }
      logger.debug("LocationManager authorizationStatus updated")
      NotificationCenter.default.post(name: .locationUpdatedEvent, object: nil)
      if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
        UserDefaults.standard.set(true, forKey: "automaticLocation")
      } else {
        Mixpanel.mainInstance().track(event: "Location Not Authorized")
        UserDefaults.standard.set(false, forKey: "automaticLocation")
        guard let _ = UserDefaults.standard.string(forKey: "manualLocationData") else {
          UserDefaults.standard.set("&latitude=38.7998839&longitude=-123.0238556", forKey: "manualLocationData")
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
    //    locationManager.startUpdatingLocation()
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
