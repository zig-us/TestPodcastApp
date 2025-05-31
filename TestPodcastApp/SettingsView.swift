//
//  SettingsView.swift
//  TestPodcastApp
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var preferences: UserPreferences
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Skip Forward Time")) {
                    Picker("Jump Forward", selection: $preferences.skipForwardTime) {
                        ForEach(UserPreferences.availableSkipTimes, id: \.self) { seconds in
                            Text(UserPreferences.formatTime(seconds))
                                .tag(seconds)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    HStack {
                        Text("Currently set to:")
                        Spacer()
                        Text(UserPreferences.formatTime(preferences.skipForwardTime))
                            .bold()
                            .foregroundColor(.blue)
                    }
                }
                
                Section(header: Text("About")) {
                    Text("Configure how far ahead the podcast will skip when you tap the forward button.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(UserPreferences())
}
