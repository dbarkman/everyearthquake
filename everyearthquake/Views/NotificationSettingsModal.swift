//
//  NotificationSettingsModal.swift
//  everyearthquake
//
//  Created by David Barkman on 12/20/22.
//

import SwiftUI
import Mixpanel
import OSLog

struct NotificationSettingsModal: View {
  
  @Environment(\.presentationMode) var presentationMode
  
  @StateObject private var locationViewModel = LocationViewModel.shared
  
  @State private var sendPush = false
  @State private var sendPushForLocation = false
  @State private var automaticLocation = 0
  @State private var units = 0
  @State private var latitude = ""
  @State private var longitude = ""
  @State private var radius = ""
  @State private var updateLocationResult = ""
  @State private var notificationsAllowed = false

  @State var magnitude: String

  @FocusState private var isFocused: Bool

  var magnitudes = ["All Magnitudes", "Magnitude 1 and greater", "Magnitude 2 and greater", "Magnitude 3 and greater", "Magnitude 4 and greater", "Magnitude 5 and greater", "Magnitude 6 and greater", "Magnitude 7 and greater", "Magnitude 8 and greater", "Magnitude 9 and greater", "No Magnitudes"]
  
  var body: some View {
    NavigationStack {
      List {
        Toggle(isOn: $sendPush) {
          Text("Send Notifications?")
        }
        if sendPush {
          if notificationsAllowed {
            Text("Minimum magnitude\rto receive notifications for:")
            Picker("Magnitude Notifications", selection: $magnitude) {
              ForEach(magnitudes, id: \.self) {
                Text($0)
              }
            }
            Toggle(isOn: $sendPushForLocation) {
              Text("Also limit notifications for\revents in a specific area?")
            }
            if sendPushForLocation {
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
            }
          } else {
            Text("\"Every Earthquake\" is not currently allowed to send you notifications. To enable notifications, tap Open Settings below and grant Notifications permission to this app.")
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
        } //end of sendPush = true
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
            saveNotificationSettings()
          }) {
            Text("Save")
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
        Mixpanel.mainInstance().track(event: "NotificationSettings View")
        UNUserNotificationCenter.current().getNotificationSettings { settings in
          guard (settings.authorizationStatus == .authorized) || (settings.authorizationStatus == .provisional) else { return }
          if settings.alertSetting == .enabled {
            notificationsAllowed = true
          } else {
            notificationsAllowed = false
          }
        }
        if UserDefaults.standard.bool(forKey: "sendPush") {
          self.sendPush = true
          if UserDefaults.standard.bool(forKey: "sendPushForLocation") {
            self.sendPushForLocation = true
            if UserDefaults.standard.bool(forKey: "automaticLocationNotifications") {
              self.automaticLocation = 0
            } else {
              self.automaticLocation = 1
              guard let manualLocationData = UserDefaults.standard.string(forKey: "manualLocationDataNotifications") else { return }
              if let latitude = manualLocationData.components(separatedBy: ",").first, let longitude = manualLocationData.components(separatedBy: ",").last {
                self.latitude = latitude
                self.longitude = longitude
              }
            }
            self.radius = UserDefaults.standard.string(forKey: "radiusSelectedNotifications") ?? "500"
            self.units = UserDefaults.standard.string(forKey: "unitsSelectedNotifications") == "miles" ? 0 : 1
          } else {
            self.sendPushForLocation = false
          }
        } else {
          self.sendPush = false
        }
      }
      .navigationTitle("Notification Settings")
    }
  }
  
  func saveNotificationSettings() {
    if sendPush {
      UserDefaults.standard.set(true, forKey: "sendPush")
      UserDefaults.standard.set(magnitude, forKey: "notificationMagnitude")
      if sendPushForLocation == true {
        Mixpanel.mainInstance().track(event: "Sending Notifications by Location")
        UserDefaults.standard.set(true, forKey: "sendPushForLocation")
        if automaticLocation == 0 {
          if locationViewModel.authorizationStatus != .authorizedWhenInUse && locationViewModel.authorizationStatus != .authorizedAlways {
            updateLocationResult = "Location permission must be granted in order to use automatic location."
            return
          }
          
          UserDefaults.standard.set(true, forKey: "automaticLocationNotifications")
        } else {
          UserDefaults.standard.set(false, forKey: "automaticLocationNotifications")
          if latitude.isEmpty || longitude.isEmpty {
            updateLocationResult = "Both latitude and longitude must be entered."
            return
          }
          UserDefaults.standard.set("\(latitude),\(longitude)", forKey: "manualLocationDataNotifications")
        }
        if radius.isEmpty {
          updateLocationResult = "Please enter a search radius."
          return
        }
        UserDefaults.standard.set(radius, forKey: "radiusSelectedNotifications")
        UserDefaults.standard.set(units == 0 ? "miles" : "kilometers", forKey: "unitsSelectedNotifications")
      } else {
        UserDefaults.standard.set(false, forKey: "sendPushForLocation")
      }
    } else {
      UserDefaults.standard.set(false, forKey: "sendPush")
    }
    Task {
      let token = UserDefaults.standard.string(forKey: "apnsToken") ?? ""
      var debug = 0
      #if DEBUG
        debug = 1
      #endif
      await AsyncAPI.shared.saveToken(token: token, debug: debug)
    }
    presentationMode.wrappedValue.dismiss()
  }
}

struct NotificationSettingsModal_Previews: PreviewProvider {
  static var previews: some View {
    NotificationSettingsModal(magnitude: "")
  }
}
