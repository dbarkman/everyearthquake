//
//  MapView.swift
//  everyearthquake
//
//  Created by David Barkman on 12/17/22.
//

import SwiftUI
import MapKit

struct MapView: View {
  
  @State private var region: MKCoordinateRegion
  
  private var type: String = ""
  private var latitude: Double = 0
  private var longitude: Double = 0
  private var width: CGFloat = 400
  private var places: [PointOfInterest] = []
  
  init(type: String, latitude: Double, longitude: Double, width: CGFloat) {
    region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2))
    self.type = type
    self.latitude = latitude
    self.longitude = longitude
    self.width = width
    
    let poi = PointOfInterest(name: type, latitude: latitude, longitude: longitude)
    places.append(poi)
  }
  
  var body: some View {
    VStack {
      Map(coordinateRegion: $region, interactionModes: [], annotationItems: places) { place in
        MapAnnotation(coordinate: place.coordinate) {
          Image(systemName: "waveform.path.ecg")
            .resizable()
            .foregroundColor(Color.red)
            .scaledToFit()
            .frame(width: 25, height: 25)
        }
      }
      .frame(width: width, height: width)
    }
  }
}

struct MapView_Previews: PreviewProvider {
  static var previews: some View {
    MapView(type: "Earthquake", latitude: 51.507222, longitude: -0.1275, width: 400)
  }
}
