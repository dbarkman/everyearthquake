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
  
  @Environment(\.scenePhase) var scenePhase
  
  @StateObject private var quakeListViewModel = QuakeListViewModel.shared
  
  @State private var showFilters = false
  @State private var showFeedback = false
  @State private var showNotificationSettings = false

  @State var refreshLocation: Bool = false
  
  var refresh: Bool
  
  var body: some View {
    NavigationStack {
      ZStack {
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
                    Text(quake.formattedTitle ?? "")
                      .lineLimit(2)
                    Spacer()
                    Text(DateTime.shared.makeStringFromDate(date: quake.date, dateFormat: .none, timeFormat: .short))
                      .font(.caption)
                  }
                }
              }
            }
          }
          HStack { }
            .listRowSeparator(.hidden)
            .onAppear {
              if !quakeListViewModel.quakes.isEmpty {
                Task {
                  quakeListViewModel.start = quakeListViewModel.start + quakeListViewModel.count
                  await quakeListViewModel.getQuakes(start: quakeListViewModel.start, count: quakeListViewModel.count)
                }
              }
            }
        }
        .listStyle(.plain)
        .navigationDestination(for: Quake.self) { quake in
          QuakeDetail(quake: quake)
        }
        if quakeListViewModel.fetching {
          ProgressView("loading events")
            .padding(.bottom, 100)
        }
      }// end of ZStack
      .overlay(quakeListViewModel.quakes.isEmpty && !quakeListViewModel.fetching ? Text("     no events to show\rtry changning the filters") : nil, alignment: .center)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(action: {
            showNotificationSettings = true
          }, label: {
            Image(systemName: "line.3.horizontal")
              .symbolRenderingMode(.monochrome)
          })
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            showFilters = true
          }, label: {
            if quakeListViewModel.magnitude != "All Magnitudes" || quakeListViewModel.type != "All Types" || quakeListViewModel.filterEventsByLocation {
              Image(systemName: "line.3.horizontal.decrease.circle.fill")
                .symbolRenderingMode(.monochrome)
            } else {
              Image(systemName: "line.3.horizontal.decrease.circle")
                .symbolRenderingMode(.monochrome)
            }
          })
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            showFeedback = true
          }, label: {
            Image(systemName: "megaphone.fill")
              .symbolRenderingMode(.monochrome)
          })
        }
      }
      .sheet(isPresented: $showNotificationSettings) {
        NotificationSettingsModal(magnitude: UserDefaults.standard.string(forKey: "notificationMagnitude") ?? "Magnitude 5 and greater")
      }
      .sheet(isPresented: $showFilters) {
        QuakeListFiltersModal(refreshLocation: $refreshLocation)
      }
      .sheet(isPresented: $showFeedback) {
        FeedbackModal()
      }
      .refreshable {
        quakeListViewModel.start = 0
        await quakeListViewModel.getQuakes(start: quakeListViewModel.start, count: quakeListViewModel.count)
      }
      .onAppear() {
        Mixpanel.mainInstance().track(event: "QuakeList View")
        if refresh {
          Task {
            await quakeListViewModel.getQuakes(start: 0, count: quakeListViewModel.count)
          }
        }
      }
      .onChange(of: scenePhase) { newPhase in
        if newPhase == .active {
          logger.debug("active")
          Task {
            await quakeListViewModel.getQuakes(start: 0, count: quakeListViewModel.count)
          }
        } else if newPhase == .inactive {
          logger.debug("inactive")
        } else if newPhase == .background {
          logger.debug("background")
        }
      }
      .navigationTitle("Every Earthquake")
    }// end of NavigationStack
  } //end of body
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    QuakeList(refresh: false)
  }
}
