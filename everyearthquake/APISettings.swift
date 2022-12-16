//
//  APISettings.swift
//  everyearthquake
//
//  Created by David Barkman on 12/15/22.
//

import Foundation

struct APISettings {
  
  static let shared = APISettings()
  
  private init() { }
  
  func fetchAPISettings() -> APIInfo {
    var apiSettings = APIInfo()
    if  let path = Bundle.main.path(forResource: "apiInfo", ofType: "plist"),
        let xml = FileManager.default.contents(atPath: path)
    {
      do {
        let api = try PropertyListDecoder().decode(APIInfo.self, from: xml)
        apiSettings = api
      } catch {
        print("API settings decoding problem. 😭 \(error.localizedDescription)")
      }
    }
    return apiSettings
  }
}
