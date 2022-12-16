//
//  QuakeListViewModel.swift
//  everyearthquake
//
//  Created by David Barkman on 12/15/22.
//

import Foundation
import OSLog

class QuakeListViewModel: ObservableObject {
  
  let logger = Logger(subsystem: "com.dbarkman.everyearthquake", category: "QuakeListViewModel")
  
  static let shared = QuakeListViewModel()
  
  private init() { }

  @Published public var quakes: [Quake] = []
  
  public func getQuakes() {
    Task {
      if let response = await AsyncAPI.shared.getQuakes() {
        let newQuakes = response.quakes
        DispatchQueue.main.async {
          self.quakes.removeAll()
          self.quakes.append(contentsOf: newQuakes)
        }
      } else {
        logger.error("Couldn't get new quakes from AsyncAPI.")
      }
    }
  }
  
}
