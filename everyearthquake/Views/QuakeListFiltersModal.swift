//
//  QuakeListFiltersModal.swift
//  everyearthquake
//
//  Created by David Barkman on 12/18/22.
//

import SwiftUI
import Mixpanel

struct QuakeListFiltersModal: View {
  
  @Environment(\.presentationMode) var presentationMode
  
  @StateObject private var quakeListViewModel = QuakeListViewModel.shared
  @StateObject private var locationViewModel = LocationViewModel.shared
  
  var magnitudes = ["All Magnitudes", "Magnitude 1 and greater", "Magnitude 2 and greater", "Magnitude 3 and greater", "Magnitude 4 and greater", "Magnitude 5 and greater", "Magnitude 6 and greater", "Magnitude 7 and greater", "Magnitude 8 and greater", "Magnitude 9 and greater"]
  var types = ["All Types", "Earthquake", "Ice Quake", "Explosion", "Accidental Explosion", "Chemical Explosion", "Experimental Explosion", "Industrial Explosion", "Mining Explosion", "Nuclear Explosion", "Collapse", "Building Collapse", "Mine Collapse", "Quarry Blast", "Volcanic Eruption", "Landslide", "Rock Slide", "Rock Burst", "Sonic Boom", "Acoustic Noise", "Meteorite", "Train Crash", "Induced or Triggered Event", "Not Reported", "Other Event"]
  
  @State private var filterEventsByLocation = 0
  @State private var automaticLocation = 0
  @State private var units = 0
  @State private var latitude = ""
  @State private var longitude = ""
  @State private var radius = ""
  @State private var updateLocationResult = ""
  
  @Binding var refreshLocation: Bool

  @FocusState private var isFocused: Bool

  var body: some View {
    NavigationStack {
      List {
        Section(header: Text("Event Details"), footer: Text("Over 4.3 million events available")) {
          if quakeListViewModel.magnitude != "All Magnitudes" || quakeListViewModel.type != "All Types" || filterEventsByLocation != 0 {
            Button(action: {
              quakeListViewModel.magnitude = "All Magnitudes"
              quakeListViewModel.type = "All Types"
              quakeListViewModel.filterEventsByLocation = false
              filterEventsByLocation = 0
              updateLocation()
            }) {
              Text("Reset Filters")
                .foregroundColor(Color.red)
            }
          }
          Picker("Event magnitude", selection: $quakeListViewModel.magnitude) {
            ForEach(magnitudes, id: \.self) {
              Text($0)
            }
          }
          Picker("Event type", selection: $quakeListViewModel.type) {
            ForEach(types, id: \.self) {
              Text($0)
            }
          }
        }
        Section(header: Text("Event Location")) {
          Text("Filter events based on location?")
          Picker("", selection: $filterEventsByLocation) {
            Text("No").tag(0)
            Text("Yes").tag(1)
          }
          .pickerStyle(.segmented)
          if filterEventsByLocation == 1 {
            Text("How should location be determined?")
            Picker("", selection: $automaticLocation) {
              Text("My Location").tag(0)
              Text("Manually").tag(1)
            }
            .pickerStyle(.segmented)
            if automaticLocation == 0 {
              if locationViewModel.authorizationStatus == .notDetermined {
                Button(action: {
                  withAnimation() {
                    locationViewModel.requestPermission()
                  }
                }, label: {
                  Text("Enable Location")
                })
              } else if locationViewModel.authorizationStatus == .authorizedAlways || locationViewModel.authorizationStatus == .authorizedWhenInUse {
                Text("Enabled: location will be determined using your device's GPS.")
              } else {
                Text("\"Every Earthquake\" is not currently allowed to access your location. To enable automatic location, tap Open Settings below and grant location access to this app.")
                Button(action: {
                  withAnimation() {
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                      UIApplication.shared.open(settingsUrl)
                    }
                  }
                }, label: {
                  Text("Open Settings")
                })
              }
            } else if automaticLocation == 1 {
              HStack {
                Text("Latitude:")
                TextField("latitude", text: $latitude)
                  .textFieldStyle(RoundedBorderTextFieldStyle())
                  .environment(\.colorScheme, .light)
                  .keyboardType(.numbersAndPunctuation)
                  .focused($isFocused)
                  .disableAutocorrection(true)
              }
              HStack {
                Text("Longitude:")
                TextField("longitude", text: $longitude)
                  .textFieldStyle(RoundedBorderTextFieldStyle())
                  .environment(\.colorScheme, .light)
                  .keyboardType(.numbersAndPunctuation)
                  .focused($isFocused)
                  .disableAutocorrection(true)
              }
            }
            
            Text("Filter range in miles or kilometers:")
            Picker("", selection: $units) {
              Text("Miles").tag(0)
              Text("Kilometers").tag(1)
            }
            .pickerStyle(.segmented)
            Text("How many \(units == 0 ? "miles" : "kilometers") from location centerpoint?")
            TextField("\(units == 0 ? "miles" : "kilometers")", text: $radius)
              .textFieldStyle(RoundedBorderTextFieldStyle())
              .keyboardType(.numberPad)
              .focused($isFocused)
              .disableAutocorrection(true)
              .autocapitalization(.none)
              .cornerRadius(5)
              .background(RoundedRectangle(cornerRadius: 50).fill(Color.red))
              .environment(\.colorScheme, .light)
            if !updateLocationResult.isEmpty {
              HStack {
                Text(updateLocationResult)
                Spacer()
                Text("OK")
                  .onTapGesture(perform: {
                    withAnimation() {
                      updateLocationResult = ""
                    }
                  })
              }
              .listRowBackground(Color.red.opacity(0.75))
            }
          } //end of filterEventsByLocation = true
        }
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(action: {
            presentationMode.wrappedValue.dismiss()
          }) {
            Text("Cancel")
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            updateLocation()
          }) {
            Text("Filter")
          }
        }
        ToolbarItemGroup(placement: .keyboard) {
          Spacer()
          Button("Done") {
            isFocused = false
          }
        }
      }
      .onAppear {
        Mixpanel.mainInstance().track(event: "QuakeListFilters View")
        Review.filtersViewed()
        let filterEventsByLocation = UserDefaults.standard.bool(forKey: "filterEventsByLocation")
        self.filterEventsByLocation = filterEventsByLocation ? 1 : 0
        if filterEventsByLocation {
          let automaticLocation = UserDefaults.standard.bool(forKey: "automaticLocationFilter")
          self.automaticLocation = automaticLocation ? 0 : 1
          radius = UserDefaults.standard.string(forKey: "radiusSelectedFilter") ?? "25"
          units = UserDefaults.standard.integer(forKey: "unitsSelectedFilter")
          guard let manualLocationData = UserDefaults.standard.string(forKey: "manualLocationDataFilter") else { return }
          if let latitude = manualLocationData.components(separatedBy: ",").first, let longitude = manualLocationData.components(separatedBy: ",").last {
            self.latitude = latitude
            self.longitude = longitude
          }
        }
      }
      .navigationTitle("Event Filters")
    }
  }
  
  private func updateLocation() {
    if filterEventsByLocation == 1 {
      Mixpanel.mainInstance().track(event: "Filtering Events by Location")
      UserDefaults.standard.set(true, forKey: "filterEventsByLocation")
      if automaticLocation == 0 {
        if locationViewModel.authorizationStatus != .authorizedWhenInUse && locationViewModel.authorizationStatus != .authorizedAlways {
          updateLocationResult = "Location permission must be granted in order to use automatic location."
          return
        }
        UserDefaults.standard.set(true, forKey: "automaticLocationFilter")
      } else {
        UserDefaults.standard.set(false, forKey: "automaticLocationFilter")
        if latitude.isEmpty || longitude.isEmpty {
          updateLocationResult = "Both latitude and longitude must be entered."
          return
        }
        UserDefaults.standard.set("\(latitude),\(longitude)", forKey: "manualLocationDataFilter")
      }
      if radius.isEmpty {
        updateLocationResult = "Please enter a search radius."
        return
      }
      UserDefaults.standard.set(radius, forKey: "radiusSelectedFilter")
      UserDefaults.standard.set(units, forKey: "unitsSelectedFilter")
    } else {
      UserDefaults.standard.set(false, forKey: "filterEventsByLocation")
    }
    Task {
      quakeListViewModel.quakes.removeAll()
      quakeListViewModel.start = 0
      presentationMode.wrappedValue.dismiss()
      await quakeListViewModel.getQuakes(start: 0, count: quakeListViewModel.count)
    }
  }
}

struct QuakeListFiltersModal_Previews: PreviewProvider {
  @State static var refreshLocation: Bool = false
  static var previews: some View {
    NavigationStack {
      QuakeListFiltersModal(refreshLocation: $refreshLocation)
    }
  }
}
