//
//  QuakeDetail.swift
//  everyearthquake
//
//  Created by David Barkman on 12/17/22.
//

import SwiftUI

struct QuakeDetail: View {
  
  var quake: Quake
  
  var body: some View {
    GeometryReader { geometry in
      List {
        Text("M\(quake.magnitude) \(quake.type.capitalized)\r\(quake.place)")
          .font(.title)
          .listRowSeparator(.hidden)
        Text(DateTime.shared.makeStringFromDate(date: quake.date, dateFormat: .full, timeFormat: .medium))
          .listRowSeparator(.hidden)

        MapView(type: quake.type, latitude: Double(quake.latitude) ?? 0, longitude: Double(quake.longitude) ?? 0, width: geometry.size.width * 0.9)
          .listRowSeparator(.hidden)
        
        Section(header: Text("Location Details")) {
          if !quake.continent.isEmpty { Text("Continent: " + quake.continent) }
          if !quake.country.isEmpty { Text("Country: " + quake.country) }
          if !quake.subnational.isEmpty { Text("Subnational: " + quake.subnational) }
          if !quake.locality.isEmpty { Text("Locality: " + quake.locality) }
          if !quake.city.isEmpty { Text("City: " + quake.city) }
          if !quake.postcode.isEmpty { Text("Postal code: " + quake.postcode) }
          if quake.what3words != nil {
            HStack {
              Text("What3Words: ")
              Link(quake.what3words!, destination: URL(string: "https://what3words.com/" + quake.what3words!)!)
                .foregroundColor(.blue)
                .padding(.leading, -5)
            }
          }
        
        }

        Section(header: Text(quake.type.capitalized + " Details")) {
          Text("Depth: " + quake.depth + "km")
          if quake.tsunami == "0" {
            Text("Tsunami: No")
          } else {
            HStack {
              Text("Tsunami: ")
              Link("Possibly", destination: URL(string: "http://tsunami.gov")!)
                .foregroundColor(.blue)
                .padding(.leading, -5)
            }
          }
        }

        Link("More details at USGS.gov", destination: URL(string: quake.url)!)
          .font(.title)
          .foregroundColor(.blue)
      }
      .listStyle(.plain)
    }
    .navigationBarTitleDisplayMode(.inline)
  }
}

struct QuakeDetail_Previews: PreviewProvider {
  static let date = DateTime.shared.makeDateFromString(date: "2022-12-14T13:32:49", format: "yyyy-MM-dd'T'HH:mm:ss")
  static let quake = Quake(id: "ok2022yqrm", magnitude: "2.56", type: "earthquake", title: "M 2.6 - 7 km N of Quinlan, Oklahoma", date: date, time: "1671292301492", url: "https://earthquake.usgs.gov/earthquakes/eventpage/ok2022yqrm", tsunami: "0", depth: "5", latitude: "36.5216", longitude: "-99.0586", place: "7 km N of Quinlan, Oklahoma", location: "Quinlan, Oklahoma", continent: "North America", country: "United States of America", subnational: "Oklahoma", city: "", locality: "Woodward County", postcode: "73852", what3words: "ironclad.letters.refrigerator", timezone: "-360")
  static var previews: some View {
    NavigationStack {
      QuakeDetail(quake: quake)
    }
  }
}
