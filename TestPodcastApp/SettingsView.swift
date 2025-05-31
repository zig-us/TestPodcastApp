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
                Section(header: Text("Playback Controls")) {
                    // Skip Forward
                    Picker("Skip Forward", selection: $preferences.skipForwardTime) {
                        ForEach(UserPreferences.availableSkipTimes, id: \.self) { seconds in
                            Text(UserPreferences.formatTime(seconds))
                                .tag(seconds)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    // Skip Backward
                    Picker("Skip Backward", selection: $preferences.skipBackwardTime) {
                        ForEach(UserPreferences.availableSkipTimes, id: \.self) { seconds in
                            Text(UserPreferences.formatTime(seconds))
                                .tag(seconds)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    // Default Playback Speed
                    Picker("Default Speed", selection: $preferences.defaultPlaybackSpeed) {
                        ForEach(UserPreferences.availablePlaybackSpeeds, id: \.self) { speed in
                            Text("\(String(format: "%.2f", speed))x")
                                .tag(speed)
                        }
                    }
                    
                    // Auto-play Next
                    Toggle("Auto-play Next Episode", isOn: $preferences.autoPlayNext)
                }
                
                Section(header: Text("Download Settings")) {
                    Toggle("Auto-download New Episodes", isOn: $preferences.autoDownloadNewEpisodes)
                    Toggle("Download on Wi-Fi Only", isOn: $preferences.downloadOnWifiOnly)
                    Toggle("Auto-delete Played Episodes", isOn: $preferences.autoDeletePlayedEpisodes)
                }
                
                Section(header: Text("Sleep Timer")) {
                    Picker("Default Sleep Timer", selection: $preferences.sleepTimerDuration) {
                        Text("Off").tag(TimeInterval(0))
                        ForEach(UserPreferences.availableSleepTimers, id: \.self) { duration in
                            Text(UserPreferences.formatSleepTimer(duration))
                                .tag(duration)
                        }
                    }
                }
                
                Section(header: Text("Appearance")) {
                    Toggle("Dark Mode", isOn: $preferences.darkModeEnabled)
                    Toggle("Show Episode Artwork", isOn: $preferences.showEpisodeArtwork)
                }
                
                Section {
                    Button("Reset to Defaults") {
                        preferences.resetToDefaults()
                    }
                    .foregroundColor(.red)
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
