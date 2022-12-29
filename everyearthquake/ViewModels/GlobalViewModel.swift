//
//  GlobalViewModel.swift
//  everyearthquake
//
//  Created by David Barkman on 12/18/22.
//

import Foundation
import MapKit
import Mixpanel

class GlobalViewModel: ObservableObject {
  
  static let shared = GlobalViewModel()
  
  @Published var region: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2))
  @Published var places: [PointOfInterest] = []
  
  func setRegion(type: String, latitude: Double, longitude: Double) {
    DispatchQueue.main.async {
      self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2))
      let poi = PointOfInterest(name: type, latitude: latitude, longitude: longitude)
      self.places.append(poi)
    }
  }
  
  func fetchAppVersionNumber() -> String {
    var appVersion = ""
    if let buildNumber = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
      appVersion = buildNumber
    }
    return appVersion
  }
  
  func fetchBuildNumber() -> String {
    var buildNum = ""
    if let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
      buildNum = buildNumber
    }
    return buildNum
  }
}
