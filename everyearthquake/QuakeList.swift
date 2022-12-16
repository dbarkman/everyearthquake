//
//  QuakeList.swift
//  everyearthquake
//
//  Created by David Barkman on 12/15/22.
//

import SwiftUI
import OSLog

struct QuakeList: View {
  
  let logger = Logger(subsystem: "com.dbarkman.everyearthquake", category: "QuakeList")
  
  @StateObject private var quakeListViewModel = QuakeListViewModel.shared

  var body: some View {
    NavigationStack {
      List(quakeListViewModel.quakes, id: \.id) { quake in
        NavigationLink(value: quake) {
          HStack {
            ZStack {
              RoundedRectangle(cornerRadius: 75, style: .continuous)
                .fill(quake.color)
                .frame(width: 50, height: 50)
              Text(quake.magnitude)
                .foregroundColor(Color.black)
            }
            VStack(alignment: .leading) {
              Text(quake.place)
                .lineLimit(2)
            }
          }
        }
      }
      .navigationDestination(for: Quake.self) { quake in
        Text("Earthquake \(quake.place) Detail")
      }
      .navigationTitle("Every Earthquake")
      .onAppear {
        quakeListViewModel.getQuakes()
      }
      .refreshable {
        quakeListViewModel.getQuakes()
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    QuakeList()
  }
}
