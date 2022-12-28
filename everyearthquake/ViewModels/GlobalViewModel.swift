//
//  GlobalViewModel.swift
//  everyearthquake
//
//  Created by David Barkman on 12/18/22.
//

import Foundation
import Mixpanel

class GlobalViewModel: ObservableObject {
  
  static let shared = GlobalViewModel()
  
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
