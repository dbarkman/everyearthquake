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
  
  init() {
    Mixpanel.initialize(token: "71bea55cd83ac3de3ae7a742c307d4b5", trackAutomaticEvents: true)
  }

  var body: some Scene {
    WindowGroup {
      QuakeList()
    }
  }
}
