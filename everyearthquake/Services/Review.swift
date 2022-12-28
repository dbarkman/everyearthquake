//
//  Review.swift
//  everyearthquake
//
//  Created by David Barkman on 12/28/22.
//

import StoreKit
import OSLog

class Review {
  
  let logger = Logger(subsystem: "com.dbarkman.everyearthquake", category: "Review")

  private let ud = UserDefaults.standard
  
  let minLaunches = 8
  let minDays = 0
  let daysBetweenReviews = 0
  
  var viewedDetail: Bool {
    get { ud.bool(forKey: "viewedDetail") }
    set(value) { ud.set(value, forKey: "viewedDetail") }
  }
  
  var viewedFilters: Bool {
    get { ud.bool(forKey: "viewedFilters") }
    set(value) { ud.set(value, forKey: "viewedFilters") }
  }

  var viewedSecondPage: Bool {
    get { ud.bool(forKey: "viewedSecondPage") }
    set(value) { ud.set(value, forKey: "viewedSecondPage") }
  }

  var launches: Int {
    get { ud.integer(forKey: "launches") }
    set(value) { ud.set(value, forKey: "launches") }
  }
  
  var firstLaunchDate: Date? {
    get { ud.object(forKey: "firstLaunchDate") as? Date }
    set(value) { ud.set(value, forKey: "firstLaunchDate") }
  }
  
  var lastReviewDate: Date? {
    get { ud.object(forKey: "lastReviewDate") as? Date }
    set(value) { ud.set(value, forKey: "lastReviewDate") }
  }
  
  var daysInstalled: Int {
    if let date = firstLaunchDate {
      return daysBetween(date, Date())
    }
    return 0
  }
  
  var daysSinceLastReview: Int {
    if let date = lastReviewDate {
      return daysBetween(date, Date())
    }
    return 0
  }
  
  var lastRequestVersion: String? {
    get { ud.string(forKey: "lastRequestVersion") }
    set(value) { ud.set(value, forKey: "lastRequestVersion") }
  }
  
  static func requestReview() {
    Review().requestReviewIfReady()
  }
  
  static func detailViewed() {
    Review().viewedDetail = true
  }
  
  static func filtersViewed() {
    Review().viewedFilters = true
  }
  
  static func secondPageViewed() {
    Review().viewedSecondPage = true
  }
  
  func requestReviewIfReady() {
    if firstLaunchDate == nil { firstLaunchDate = Date() }
    launches += 1
    if viewedDetail && viewedFilters && viewedSecondPage && launches >= minLaunches && daysInstalled >= minDays {
      if lastReviewDate == nil || daysSinceLastReview >= daysBetweenReviews {
        lastReviewDate = Date()
        lastRequestVersion = version
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
          if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
          }
        }
      }
    }
  }
  
  var version = Bundle.main.object(
    forInfoDictionaryKey: "CFBundleShortVersionString"
  ) as! String
  
  func daysBetween(_ start: Date, _ end: Date) -> Int {
    Calendar.current.dateComponents([.day], from: start, to: end).day!
  }
}
