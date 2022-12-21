//
//  AsyncAPI.swift
//  everyearthquake
//
//  Created by David Barkman on 12/15/22.
//

import Foundation
import OSLog

struct AsyncAPI {
  
  let logger = Logger(subsystem: "com.dbarkman.everyearthquake", category: "AsyncAPI")
  
  static let shared = AsyncAPI()
  
  var apiKey: String
  var urlBase: String
  var tokenEndpoint: String
  var earthquakesEndpoint: String
  
  private init() {
    apiKey = APISettings.shared.fetchAPISettings().apiKey
    urlBase = APISettings.shared.fetchAPISettings().urlBase
    tokenEndpoint = APISettings.shared.fetchAPISettings().tokenEndpoint
    earthquakesEndpoint = APISettings.shared.fetchAPISettings().earthquakesEndpoint
  }
  
  func saveToken(token: String, debug: Int) async {
    var urlString = urlBase + tokenEndpoint
    urlString += "?key=" + apiKey
    guard let url = URL(string: urlString) else { return }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = "token=\(token)&debug=\(debug)".data(using: String.Encoding.utf8)
    
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
  
  func getQuakes(start: Int, count: Int, magnitude: String, type: String, location: String, radius: String, units: String) async -> EarthquakesResponse? {
    var decodedResponse: EarthquakesResponse?
    
    var urlString = urlBase + earthquakesEndpoint
    urlString += "?start=\(start)"
    urlString += "&count=\(count)"
    urlString += "&magnitude=\(magnitude)"
    if !type.isEmpty { urlString += "&type=\(type)" }
    if !location.isEmpty {
      urlString += location
      urlString += "&radius=\(radius)"
      urlString += "&units=\(units)"
    }
    urlString += "&key=" + apiKey
    logger.debug("URL: \(urlString)")
    guard let url = URL(string: urlString) else { return nil }
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
        return nil
      }
    } catch {
      logger.error("Failed to fetch data when fetching earthquakes. 😭 \(error.localizedDescription)")
    }
    return decodedResponse
  }
}
