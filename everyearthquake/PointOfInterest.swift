//
//  PointOfInterest.swift
//  everyearthquake
//
//  Created by David Barkman on 12/17/22.
//

import Foundation
import MapKit

struct PointOfInterest: Identifiable {

  let id = UUID()
  let name: String
  let latitude: Double
  let longitude: Double
  
  var coordinate: CLLocationCoordinate2D {
    CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
}
