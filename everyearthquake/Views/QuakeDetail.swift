//
//  QuakeDetail.swift
//  everyearthquake
//
//  Created by David Barkman on 12/17/22.
//

import SwiftUI
import Mixpanel

struct QuakeDetail: View {
  
  @State private var showFeedback = false
  @State private var showSignifcanceAlert = false
  @State private var showFeltItAlert = false
  @State private var showCDIAlert = false
  @State private var showMMIAlert = false

  var quake: Quake
  
  var body: some View {
    GeometryReader { geometry in
      List {
        Text("M\(quake.magnitude) \(quake.type.capitalized)\r\(Formatters.shared.format(distance: Double(quake.distanceKM) ?? 0, from: .kilometers)) \(quake.placeOnly)")
          .font(.title)
          .listRowSeparator(.hidden)
        Text(DateTime.shared.makeStringFromDate(date: quake.date, dateFormat: .full, timeFormat: .medium))
          .listRowSeparator(.hidden)

        MapView(type: quake.type, latitude: Double(quake.latitude) ?? 0, longitude: Double(quake.longitude) ?? 0, width: geometry.size.width * 0.9)
          .listRowSeparator(.hidden)
        
        Section(header: Text("Location Details")) {
          if !quake.continent.isEmpty { Text("Continent: \(quake.continent)") }
          if !quake.country.isEmpty { Text("Country: \(quake.country)") }
          if !quake.subnational.isEmpty { Text("Subnational: \(quake.subnational)") }
          if !quake.locality.isEmpty { Text("Locality: \(quake.locality)") }
          if !quake.city.isEmpty { Text("City: \(quake.city)") }
          if !quake.postcode.isEmpty { Text("Postal code: \(quake.postcode)") }
          if quake.what3words != nil {
            HStack {
              Text("What3Words: ")
              Link(quake.what3words!, destination: URL(string: "https://what3words.com/" + quake.what3words!)!)
                .foregroundColor(.blue)
                .padding(.leading, -5)
            }
          }
        
        }

        Section(header: Text("\(quake.type.capitalized) Details")) {
          HStack {
            Text("Alert level:")
            ZStack {
              RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(quake.alertColor)
                .frame(width: 100, height: 35)
              Text(quake.alert.isEmpty ? "N/A" : quake.alert)
                .foregroundColor(Color.black)
                .textCase(.uppercase)
            }
            Link(destination: URL(string: "https://earthquake.usgs.gov/data/pager")!) {
              Image(systemName: "questionmark.circle")
            }
            .foregroundColor(.blue)
          }
          HStack {
            Text("Significance:")
            Text(Formatters.shared.formatNumber(quake.sig))
            Button {
              showSignifcanceAlert = true
            } label: {
              Image(systemName: "questionmark.circle")
                .foregroundColor(.blue)
            }
          }
          HStack {
            Text("Felt It Reports:")
            Text(Formatters.shared.formatNumber(quake.felt))
            Button {
              showFeltItAlert = true
            } label: {
              Image(systemName: "questionmark.circle")
                .foregroundColor(.blue)
            }
          }
          HStack {
            Text("Felt Intensity:")
            Text(Formatters.shared.convertToRoman(number: quake.cdi))
            Button {
              showCDIAlert = true
            } label: {
              Image(systemName: "questionmark.circle")
                .foregroundColor(.blue)
            }
          }
          HStack {
            Text("Measured Intensity:")
            Text(Formatters.shared.convertToRoman(number: quake.mmi))
            Button {
              showMMIAlert = true
            } label: {
              Image(systemName: "questionmark.circle")
                .foregroundColor(.blue)
            }
          }
          Text("Depth: \(Formatters.shared.format(distance: Double(quake.depth) ?? 0, from: .kilometers))")
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
          HStack {
            Text("Status:")
            Text(quake.status.capitalized)
            Text(quake.status == "automatic" ? "(not reviewed by a human)" : "(reviewed by a human)")
              .font(.caption)
            
          }
        }

        Link("More details at USGS.gov", destination: URL(string: quake.url)!)
          .font(.title)
          .foregroundColor(.blue)
      } //end of List
      .listStyle(.plain)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          HStack(spacing: 2) {
            Button(action: {
              showFeedback = true
            }, label: {
              Image(systemName: "megaphone.fill")
                .symbolRenderingMode(.monochrome)
            })
          }
        }
      }
      .sheet(isPresented: $showFeedback) {
        FeedbackModal()
      }
      .alert(Text("Significance"), isPresented: $showSignifcanceAlert, actions: {
        Button("OK") { }
      }, message: {
        Text("A number describing how significant the event is, ranging from 0 to 2,910, the highest yet reported. This value is determined on a number of factors, including: magnitude, measured intensity, felt reports, and estimated impact.")
      })
      .alert(Text("Felt It"), isPresented: $showFeltItAlert, actions: {
        Link("DYFI", destination: URL(string: "https://earthquake.usgs.gov/data/dyfi")!)
        Button("OK") { }
      }, message: {
        Text("The total number of felt reports submitted to the DYFI system.")
      })
      .alert(Text("Felt Intensity"), isPresented: $showCDIAlert, actions: {
        Link("DYFI", destination: URL(string: "https://earthquake.usgs.gov/data/dyfi")!)
        Link("Magnitude vs. Intensity", destination: URL(string: "https://www.usgs.gov/natural-hazards/earthquake-hazards/science/earthquake-magnitude-energy-release-and-shaking-intensity")!)
        Button("OK") { }
      }, message: {
        Text("The maximum reported intensity for the event. Computed by DYFI.")
      })
      .alert(Text("Measured Intensity"), isPresented: $showMMIAlert, actions: {
        Link("ShakeMap", destination: URL(string: "https://earthquake.usgs.gov/data/shakemap")!)
        Link("Magnitude vs. Intensity", destination: URL(string: "https://www.usgs.gov/natural-hazards/earthquake-hazards/science/earthquake-magnitude-energy-release-and-shaking-intensity")!)
        Button("OK") { }
      }, message: {
        Text("The maximum estimated instrumental intensity for the event. Computed by ShakeMap.")
      })
      .onAppear() {
        Mixpanel.mainInstance().track(event: "QuakeDetail View for \(quake.id)")
        Review.detailViewed()
      }
      .navigationTitle("M\(quake.magnitude) - \(quake.location)")
    }
    .navigationBarTitleDisplayMode(.inline)
  } //end of body
}

struct QuakeDetail_Previews: PreviewProvider {
  static let date = DateTime.shared.makeDateFromString(date: "2022-12-14T13:32:49", format: "yyyy-MM-dd'T'HH:mm:ss")
  static let quake = Quake(id: "ok2022yqrm", magnitude: "2.56", type: "earthquake", title: "M 2.6 - 7 km N of Quinlan, Oklahoma", date: date, time: "1671292301492", url: "https://earthquake.usgs.gov/earthquakes/eventpage/ok2022yqrm", tsunami: "1", alert: "red", cdi: "7", felt: "525", mmi: "8", sig: "356", status: "reviewed", depth: "5", latitude: "36.5216", longitude: "-99.0586", place: "7 km N of Quinlan, Oklahoma", distanceKM: "7", placeOnly: "N of Quinlan, Oklahoma", location: "Quinlan, Oklahoma", continent: "North America", country: "United States of America", subnational: "Oklahoma", city: "", locality: "Woodward County", postcode: "73852", what3words: "ironclad.letters.refrigerator", timezone: "-360")
  static var previews: some View {
    NavigationStack {
      QuakeDetail(quake: quake)
    }
  }
}

struct Previews_QuakeDetail_Previews: PreviewProvider {
  static var previews: some View {
    /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
  }
}
