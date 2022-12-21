//
//  AppDelegate.swift
//  everyearthquake
//
//  Created by David Barkman on 12/20/22.
//

import UIKit
import UserNotifications
import OSLog

class AppDelegate: NSObject, UIApplicationDelegate {
  
  let logger = Logger(subsystem: "com.dbarkman.everearthquake", category: "AppDelegate")
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    Task {
      let center = UNUserNotificationCenter.current()
      try await center.requestAuthorization(options: [.badge, .sound, .alert])
      
      await MainActor.run {
        application.registerForRemoteNotifications()
      }
    }
    
    return true
  }
  
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let token = deviceToken.reduce("") { $0 + String(format: "%02x", $1) }
    logger.debug("APNs token: \(token)")

    var debug = 0
    #if DEBUG
      debug = 1
    #endif
    
    Task {
      await AsyncAPI.shared.saveToken(token: token, debug: debug)
    }
  }
  
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    logger.error("APNs error: \(error)")
  }
  
}
