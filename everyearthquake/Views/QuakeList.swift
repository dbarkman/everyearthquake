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
  
  @State private var showFilters = false
  @State private var showFeedback = false
  @State var refreshLocation: Bool = false

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
        ToolbarItem(placement: .navigationBarTrailing) {
          HStack(spacing: 2) {
            Button(action: {
              showFilters = true
            }, label: {
              Image(systemName: "line.3.horizontal.decrease.circle.fill")
                .symbolRenderingMode(.monochrome)
            })
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          HStack(spacing: 2) {
            Button(action: {
              showFeedback = true
            }, label: {
              Image(systemName: "megaphone.fill")
                .symbolRenderingMode(.monochrome)
            })
          }
        }
      }
      .sheet(isPresented: $showFilters) {
        QuakeListFiltersModal(refreshLocation: $refreshLocation)
      }
      .sheet(isPresented: $showFeedback) {
        FeedbackModal()
      }
      .task {
        await quakeListViewModel.getQuakes(start: 0, count: quakeListViewModel.count)
      }
      .refreshable {
        quakeListViewModel.start = 0
        await quakeListViewModel.getQuakes(start: quakeListViewModel.start, count: quakeListViewModel.count)
      }
      .onAppear() {
        Mixpanel.mainInstance().track(event: "QuakeList View")
      }
      .navigationTitle("Every Earthquake")
    }// end of NavigationStack
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    QuakeList()
  }
}
