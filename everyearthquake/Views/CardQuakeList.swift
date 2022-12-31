//
//  CardQuakeList.swift
//  everyearthquake
//
//  Created by David Barkman on 12/30/22.
//

import SwiftUI
import Mixpanel
import OSLog

struct CardQuakeList: View {
  let logger = Logger(subsystem: "com.dbarkman.everyearthquake", category: "CardQuakeList")
  
  @StateObject private var cardQuakeListViewModel = CardQuakeListViewModel.shared
  
  @State private var showFeedback = false
  
  var body: some View {
    NavigationStack {
      ZStack {
        List {
          ForEach(cardQuakeListViewModel.quakes) { section in
            Section(header: Text(section.title)) {
              ForEach(section.quakes) { quake in
                NavigationLink(value: quake) {
                  QuakeListRow(quake: quake)
                }
              }
            }
          }
        }
        .listStyle(.plain)
        .navigationDestination(for: Quake.self) { quake in
          QuakeDetail(quake: quake)
        }
        if cardQuakeListViewModel.fetching {
          ProgressView("loading events")
            .padding(.bottom, 100)
        }
      }// end of ZStack
      .overlay(cardQuakeListViewModel.quakes.isEmpty && !cardQuakeListViewModel.fetching ? Text("no events to show or search timed out\r   go back and select a different card") : nil, alignment: .center)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            showFeedback = true
          }, label: {
            Image(systemName: "megaphone.fill")
              .symbolRenderingMode(.monochrome)
          })
        }
      }
      .sheet(isPresented: $showFeedback) {
        FeedbackModal()
      }
      .refreshable {
        await cardQuakeListViewModel.getQuakes()
      }
      .onAppear() {
        Mixpanel.mainInstance().track(event: "CardQuakeList View")
        Task {
          await cardQuakeListViewModel.getQuakes()
        }
      }
      .navigationTitle("Card Quake List")
    }// end of NavigationStack
  } //end of body
}

struct CardQuakeList_Previews: PreviewProvider {
    static var previews: some View {
        CardQuakeList()
    }
}
