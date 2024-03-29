//
//  AsyncAPI.swift
//  everyearthquake
//
//  Created by David Barkman on 12/15/22.
//

import Foundation
import Mixpanel
import OSLog

struct AsyncAPI {
  
  let logger = Logger(subsystem: "com.dbarkman.everyearthquake", category: "AsyncAPI")
  
  static let shared = AsyncAPI()
  
  var apiKey: String
  var urlBase: String
  var tokenEndpoint: String
  var earthquakesEndpoint: String
  var earthquakesByDateEndpoint: String

  private init() {
    apiKey = APISettings.shared.fetchAPISettings().apiKey
    urlBase = APISettings.shared.fetchAPISettings().urlBase
    tokenEndpoint = APISettings.shared.fetchAPISettings().tokenEndpoint
    earthquakesEndpoint = APISettings.shared.fetchAPISettings().earthquakesEndpoint
    earthquakesByDateEndpoint = APISettings.shared.fetchAPISettings().earthquakesByDateEndpoint
  }
  
  func saveToken(token: String, debug: Int) async {
    
    var urlString = urlBase + tokenEndpoint
    urlString += "?key=" + apiKey
    urlString += addVersionInfo(urlString: urlString)
    logger.debug("URL: \(urlString)")
    guard let url = URL(string: urlString) else { return }
    
    var httpBody = "token=\(token)&debug=\(debug)"
    let sendPush = UserDefaults.standard.bool(forKey: "sendPush") == true ? 1 : 0
    let magnitude = UserDefaults.standard.string(forKey: "notificationMagnitude") ?? "M 5 and greater\rabout 5 per day"
    let notificationMagnitude = QuakeListViewModel.shared.notificationsMagDict[magnitude] ?? "5"
    httpBody += "&sendPush=\(sendPush)&magnitude=\(notificationMagnitude)"
    
    if UserDefaults.standard.bool(forKey: "sendPushForLocation") {
      var location = ""
      if UserDefaults.standard.bool(forKey: "automaticLocationNotifications") {
        location = await Location.getLocation(forToken: true)
      } else {
        location = UserDefaults.standard.string(forKey: "manualLocationDataNotifications") ?? "38.7998839,123.0238556"
      }
      guard let latitude = location.components(separatedBy: ",").first, let longitude = location.components(separatedBy: ",").last else { return }
      let radius = UserDefaults.standard.string(forKey: "radiusSelectedNotifications") ?? "500"
      let units = UserDefaults.standard.string(forKey: "unitsSelectedNotifications") ?? "miles"
      httpBody += "&location=1&latitude=\(latitude)&longitude=\(longitude)&radius=\(radius)&units=\(units)"
    }
    
    if let distinctId = UserDefaults.standard.string(forKey: "distinctId") {
      httpBody += "&uuid=\(distinctId)"
    } else {
      let distinctId = UUID().uuidString
      UserDefaults.standard.set(distinctId, forKey: "distinctId")
      httpBody += "&uuid=\(distinctId)"
      Mixpanel.mainInstance().identify(distinctId: distinctId)
      Mixpanel.mainInstance().people.set(properties: ["$name":distinctId])
    }
    logger.debug("httpBody: \(httpBody)")

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = httpBody.data(using: String.Encoding.utf8)
    
    do {
      let (_, response) = try await URLSession.shared.data(for: request)
      if let httpResponse = response as? HTTPURLResponse {
        if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 {
          logger.error("HTTP response was not 200 or 201 when saving token. 😭 Response code: \(httpResponse.statusCode), Response description: \(httpResponse.description)")
        }
      }
    } catch {
      logger.error("Failed to fetch data when fetching earthquakes. 😭 \(error.localizedDescription)")
    }
    return
  }
  
  func getQuakes(start: Int, count: Int, magnitude: String, type: String, startDate: String, endDate: String, location: String, radius: String, units: String, orderBy: String) async -> EarthquakesResponse? {
    var decodedResponse: EarthquakesResponse?
    
    var urlString = urlBase + earthquakesEndpoint
    if !startDate.isEmpty && !endDate.isEmpty {
      urlString = urlBase + earthquakesByDateEndpoint
    }
    
    urlString += "?start=\(start)"
    urlString += "&count=\(count)"
    urlString += "&magnitude=\(magnitude)"
    if !type.isEmpty { urlString += "&type=\(type)" }
    
    if !startDate.isEmpty && !endDate.isEmpty {
      urlString += "&startDate=\(startDate)&endDate=\(endDate)"
    }
    
    if !location.isEmpty {
      urlString += location
      urlString += "&radius=\(radius)"
      urlString += "&units=\(units)"
    }
    urlString += "&orderBy=\(orderBy)"
    urlString += "&key=" + apiKey
    urlString += addVersionInfo(urlString: urlString)
    urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? urlString
    logger.debug("URL: \(urlString)")
    guard let url = URL(string: urlString) else {
      logger.error("Failed to build URL. 😭")
      return nil
    }
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    do {
      let (data, response) = try await URLSession.shared.data(for: request)
      if let httpResponse = response as? HTTPURLResponse {
        if httpResponse.statusCode == 200 {
          let jsonDecoder = JSONDecoder()
          let dateFormatter = DateFormatter()
          jsonDecoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            if let date = dateFormatter.date(from: dateStr) {
              return date
            }
            throw DateError.invalidDate
          })
          do {
            decodedResponse = try jsonDecoder.decode(EarthquakesResponse.self, from: data)
          } catch {
            logger.error("Failed to decode data when fetching earthquakes. 😭 \(error.localizedDescription)")
          }
        } else { //response was not 200
          logger.error("HTTP response was not 200 when fetching earthquakes. 😭 Response code: \(httpResponse.statusCode), Response description: \(httpResponse.description)")
          return decodedResponse
        }
      } else {
        logger.error("Failed to parse http response when fetching earthquakes. 😭")
        return nil
      }
    } catch {
      logger.error("Failed to fetch data when fetching earthquakes. 😭 \(error.localizedDescription)")
    }
    return decodedResponse
  }
  
  func addVersionInfo(urlString: String) -> String {
    let appVersion = GlobalViewModel.shared.fetchAppVersionNumber()
    let buildNumber = GlobalViewModel.shared.fetchBuildNumber()
    let osVersion = GlobalViewModel.shared.fetchOsVersion()
    let device = GlobalViewModel.shared.fetchDevice()
    return "&appVersion=\(appVersion).\(buildNumber)&osVersion=\(osVersion)&device=\(device)"
  }
  
}
