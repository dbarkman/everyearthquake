//
//  QuakeListRow.swift
//  everyearthquake
//
//  Created by David Barkman on 12/30/22.
//

import SwiftUI

struct QuakeListRow: View {
  
  var quake: Quake
  
  var body: some View {
    HStack {
      ZStack {
        RoundedRectangle(cornerRadius: 75, style: .continuous)
          .fill(quake.color)
          .frame(width: 50, height: 50)
        Text(quake.magnitude)
          .foregroundColor(Color.black)
      }
      Text(quake.formattedTitle ?? "")
        .lineLimit(2)
      Spacer()
      Text(DateTime.shared.makeStringFromDate(date: quake.date, dateFormat: .none, timeFormat: .short))
        .font(.caption)
    }
  }
}

struct QuakeListRow_Previews: PreviewProvider {
  static let date = DateTime.shared.makeDateFromString(date: "2022-12-14T13:32:49", format: "yyyy-MM-dd'T'HH:mm:ss")
  static let quake = Quake(id: "ok2022yqrm", magnitude: "2.56", type: "earthquake", title: "M 2.6 - 7 km N of Quinlan, Oklahoma", date: date, time: "1671292301492", url: "https://earthquake.usgs.gov/earthquakes/eventpage/ok2022yqrm", tsunami: "0", alert: "green", cdi: "2", felt: "15", mmi: "2", sig: "20", status: "automatic", depth: "5", latitude: "36.5216", longitude: "-99.0586", place: "7 km N of Quinlan, Oklahoma", distanceKM: "7", placeOnly: "N of Quinlan, Oklahoma", location: "Quinlan, Oklahoma", continent: "North America", country: "United States of America", subnational: "Oklahoma", city: "", locality: "Woodward County", postcode: "73852", what3words: "ironclad.letters.refrigerator", timezone: "-360")
  static var previews: some View {
    QuakeListRow(quake: quake)
  }
}
