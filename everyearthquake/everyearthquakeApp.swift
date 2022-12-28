//
//  everyearthquakeApp.swift
//  everyearthquake
//
//  Created by David Barkman on 12/15/22.
//

import SwiftUI
import Mixpanel

@main
struct everyearthquakeApp: App {
  
  @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

  init() {
    Mixpanel.initialize(token: "71bea55cd83ac3de3ae7a742c307d4b5", trackAutomaticEvents: true)
    if !UserDefaults.standard.bool(forKey: "notNewInstall") {
      UserDefaults.standard.set(false, forKey: "sendPush")
    }
  }

  var body: some Scene {
    WindowGroup {
      QuakeList(refresh: false)
    }
  }
}
