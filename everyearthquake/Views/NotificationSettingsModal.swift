//
//  NotificationSettingsModal.swift
//  everyearthquake
//
//  Created by David Barkman on 12/20/22.
//

import SwiftUI

struct NotificationSettingsModal: View {
  
  @Environment(\.presentationMode) var presentationMode
  
  @StateObject private var globalViewModel = GlobalViewModel.shared
  
  var body: some View {
    NavigationStack {
      Text("Notification Settings")
        .navigationTitle("Notification Settings")
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            Button(action: {
              presentationMode.wrappedValue.dismiss()
            }) {
              Text("Cancel")
            }
          }
        }
    }
  }
}

struct NotificationSettingsModal_Previews: PreviewProvider {
  static var previews: some View {
    NotificationSettingsModal()
  }
}
