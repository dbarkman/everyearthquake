//
//  QuakeList.swift
//  everyearthquake
//
//  Created by David Barkman on 12/15/22.
//

import SwiftUI
import Mixpanel
import OSLog

struct QuakeList: View {
  
  let logger = Logger(subsystem: "com.dbarkman.everyearthquake", category: "QuakeList")
  
  @StateObject private var quakeListViewModel = QuakeListViewModel.shared
  
  @State private var start = 0
  @State private var count = 100
  @State private var fetching = false
  @State private var showFeedback = false

  var body: some View {
    NavigationStack {
      List {
        ForEach(quakeListViewModel.quakes) { section in
          Section(header: Text(section.title)) {
            ForEach(section.quakes) { quake in
              NavigationLink(value: quake) {
                HStack {
                  ZStack {
                    RoundedRectangle(cornerRadius: 75, style: .continuous)
                      .fill(quake.color)
                      .frame(width: 50, height: 50)
                    Text(quake.magnitude)
                      .foregroundColor(Color.black)
                  }
                  Text("\(Formatters.shared.format(distance: Double(quake.distanceKM) ?? 0, from: .kilometers)) \(quake.placeOnly)")
                    .lineLimit(2)
//                  Text(quake.placeOnly)
                  Spacer()
                  Text(DateTime.shared.makeStringFromDate(date: quake.date, dateFormat: .none, timeFormat: .short))
                    .font(.caption)
                }
                .task {
                  if let index = section.quakes.firstIndex(of: quake) {
                    if section.quakes.count - index < 5 && !fetching {
                      fetching = true
                      start = start + count
                      await quakeListViewModel.getQuakes(start: start, count: count)
                      fetching = false
                    }
                  }
                }
              }
            }
          }
        }
      }
      .listStyle(.plain)
      .navigationDestination(for: Quake.self) { quake in
        QuakeDetail(quake: quake)
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          HStack(spacing: 2) {
            Button(action: {
              showFeedback.toggle()
            }, label: {
              Image(systemName: "megaphone.fill")
                .symbolRenderingMode(.monochrome)
            })
          }
        }
      }
      .sheet(isPresented: $showFeedback) {
        FeedbackModal()
      }
      .task {
        await quakeListViewModel.getQuakes(start: 0, count: count)
      }
      .refreshable {
        start = 0
        await quakeListViewModel.getQuakes(start: 0, count: count)
      }
      .onAppear() {
        Mixpanel.mainInstance().track(event: "QuakeList View")
      }
      .navigationTitle("Every Earthquake")
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    QuakeList()
  }
}
