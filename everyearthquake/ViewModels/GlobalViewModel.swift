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
  
  func fetchOsVersion() -> String {
    let os = ProcessInfo.processInfo.operatingSystemVersion
    let osVersion = String(os.majorVersion) + "." + String(os.minorVersion) + "." + String(os.patchVersion)
    return osVersion
  }
  
  func fetchDevice() -> String {
    if let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] { return simulatorModelIdentifier }
    var sysinfo = utsname()
    uname(&sysinfo) // ignore return value
    return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
  }
  
}
