//
//  SettingsView.swift
//  TestPodcastApp
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var preferences: UserPreferences
    
    var body: some View {
        NavigationView {
            Form {
                // MARK: - Playback Controls
                Section(header: Text("Playback Controls")) {
                    Picker("Skip Forward", selection: $preferences.skipForwardTime) {
                        ForEach(UserPreferences.availableSkipTimes, id: \.self) { seconds in
                            Text(UserPreferences.formatTime(seconds)).tag(seconds)
                        }
                    }
                    
                    Picker("Skip Backward", selection: $preferences.skipBackwardTime) {
                        ForEach(UserPreferences.availableSkipTimes, id: \.self) { seconds in
                            Text(UserPreferences.formatTime(seconds)).tag(seconds)
                        }
                    }
                    
                    Picker("Default Playback Speed", selection: $preferences.defaultPlaybackSpeed) {
                        ForEach(UserPreferences.availablePlaybackSpeeds, id: \.self) { speed in
                            Text("\(String(format: "%.2f", speed))x").tag(speed)
                        }
                    }
                    
                    Toggle("Auto-play Next Episode", isOn: $preferences.autoPlayNext)
                }
                
                // MARK: - Download Settings
                Section(header: Text("Download Settings")) {
                    Toggle("Auto-download New Episodes", isOn: $preferences.autoDownloadNewEpisodes)
                    
                    Toggle("Download on Wi-Fi Only", isOn: $preferences.downloadOnWifiOnly)
                        .disabled(!preferences.autoDownloadNewEpisodes)
                    
                    Toggle("Auto-delete Played Episodes", isOn: $preferences.autoDeletePlayedEpisodes)
                }
                
                // MARK: - Sleep Timer
                Section(header: Text("Sleep Timer")) {
                    Picker("Sleep Timer Duration", selection: $preferences.sleepTimerDuration) {
                        Text("Off").tag(TimeInterval(0))
                        ForEach(UserPreferences.availableSleepTimers, id: \.self) { seconds in
                            Text(UserPreferences.formatSleepTimer(seconds)).tag(seconds)
                        }
                    }
                }
                
                // MARK: - Appearance
                Section(header: Text("Appearance")) {
                    Toggle("Dark Mode", isOn: $preferences.darkModeEnabled)
                    
                    Toggle("Show Episode Artwork", isOn: $preferences.showEpisodeArtwork)
                }
                
                // MARK: - Reset Settings
                Section {
                    Button(action: {
                        preferences.resetToDefaults()
                    }) {
                        Text("Reset to Defaults")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(UserPreferences())
}
