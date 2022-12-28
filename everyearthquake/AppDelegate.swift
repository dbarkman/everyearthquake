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
    AppDelegate.register(in: application, using: self)
    Review.requestReview()
    return true
  }
  
  static func register(in application: UIApplication, using notificationDelegate: UNUserNotificationCenterDelegate? = nil) {
    let center = UNUserNotificationCenter.current()
    center.delegate = notificationDelegate
    center.requestAuthorization(options: [.sound, .alert], completionHandler: { granted, error in
      if error != nil {
        print("Notification request error: \(error?.localizedDescription ?? "")")
      } else if granted {
        DispatchQueue.main.async {
          application.registerForRemoteNotifications()
        }
      } else {
        print("User denied notifications")
        if !UserDefaults.standard.bool(forKey: "notNewInstall") {
          UserDefaults.standard.set(true, forKey: "notNewInstall")
          UserDefaults.standard.set(false, forKey: "sendPush")
        }
      }
    })
  }
    
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      guard settings.authorizationStatus == .authorized else { return }
      if settings.alertSetting == .enabled {
        if !UserDefaults.standard.bool(forKey: "notNewInstall") {
          UserDefaults.standard.set(true, forKey: "notNewInstall")
          UserDefaults.standard.set(true, forKey: "sendPush")
        }
        let token = deviceToken.reduce("") { $0 + String(format: "%02x", $1) }
        self.logger.debug("APNs token: \(token)")
        UserDefaults.standard.set(token, forKey: "apnsToken")
        
        var debug = 0
        #if DEBUG
          debug = 1
        #endif
        
        Task {
          await AsyncAPI.shared.saveToken(token: token, debug: debug)
        }
      }
    }
  }
  
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    logger.error("APNs error: \(error)")
  }
  
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) async -> UIBackgroundFetchResult {
    NotificationCenter.default.post(name: .notificationReceivedEvent, object: nil)
    return .noData
  }
  
}

extension AppDelegate: UNUserNotificationCenterDelegate {
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
    return [.banner, .sound]
  }
}
