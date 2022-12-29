//
//  MapView.swift
//  everyearthquake
//
//  Created by David Barkman on 12/17/22.
//

import SwiftUI
import MapKit

struct MapView: View {
  
  @Binding var region: MKCoordinateRegion

  var width: CGFloat = 400
  var places: [PointOfInterest] = []
  
//  init(type: String, latitude: Double, longitude: Double, width: CGFloat) {
//    region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2))
//    self.width = width
//
//    let poi = PointOfInterest(name: type, latitude: latitude, longitude: longitude)
//    places.append(poi)
//  }
  
  var body: some View {
    Map(coordinateRegion: $region, interactionModes: [], annotationItems: places) { place in
      MapMarker(coordinate: place.coordinate)
//      MapAnnotation(coordinate: place.coordinate) {
//        Image(systemName: "waveform.path.ecg")
//          .resizable()
//          .foregroundColor(Color.red)
//          .scaledToFit()
//          .frame(width: 25, height: 25)
//      }
    }
    .frame(width: width, height: width)
  }
}

//struct MapView_Previews: PreviewProvider {
//  static var previews: some View {
//    MapView(type: "Earthquake", latitude: 51.507222, longitude: -0.1275, width: 400)
//  }
//}
