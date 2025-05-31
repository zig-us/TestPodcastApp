//
//  SettingsView.swift
//  TestPodcastApp
//

import SwiftUI

// Importing necessary models and utilities
class UserPreferences: ObservableObject {
    // MARK: - Playback Settings
    @Published var skipForwardTime: TimeInterval = 30.0 {
        didSet {
            UserDefaults.standard.set(skipForwardTime, forKey: "skipForwardTime")
        }
    }
    
    @Published var skipBackwardTime: TimeInterval = 15.0 {
        didSet {
            UserDefaults.standard.set(skipBackwardTime, forKey: "skipBackwardTime")
        }
    }
    
    @Published var defaultPlaybackSpeed: Float = 1.0 {
        didSet {
            UserDefaults.standard.set(defaultPlaybackSpeed, forKey: "defaultPlaybackSpeed")
        }
    }
    
    @Published var autoPlayNext: Bool = true {
        didSet {
            UserDefaults.standard.set(autoPlayNext, forKey: "autoPlayNext")
        }
    }
    
    // MARK: - Download Settings
    @Published var autoDownloadNewEpisodes: Bool = false {
        didSet {
            UserDefaults.standard.set(autoDownloadNewEpisodes, forKey: "autoDownloadNewEpisodes")
        }
    }
    
    @Published var downloadOnWifiOnly: Bool = true {
        didSet {
            UserDefaults.standard.set(downloadOnWifiOnly, forKey: "downloadOnWifiOnly")
        }
    }
    
    @Published var autoDeletePlayedEpisodes: Bool = false {
        didSet {
            UserDefaults.standard.set(autoDeletePlayedEpisodes, forKey: "autoDeletePlayedEpisodes")
        }
    }
    
    // MARK: - Sleep Timer
    @Published var sleepTimerDuration: TimeInterval = 1800 {
        didSet {
            UserDefaults.standard.set(sleepTimerDuration, forKey: "sleepTimerDuration")
        }
    }
    
    // MARK: - UI Settings
    @Published var darkModeEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(darkModeEnabled, forKey: "darkModeEnabled")
        }
    }
    
    @Published var showEpisodeArtwork: Bool = true {
        didSet {
            UserDefaults.standard.set(showEpisodeArtwork, forKey: "showEpisodeArtwork")
        }
    }
    
    // MARK: - History Settings
    @Published var completedPodcasts: [String] = [] {
        didSet {
            if let encoded = try? JSONEncoder().encode(completedPodcasts) {
                UserDefaults.standard.set(encoded, forKey: "completedPodcasts")
            }
        }
    }
    
    // Available preset values
    static let availableSkipTimes: [TimeInterval] = [5, 10, 15, 30, 45, 60]
    static let availablePlaybackSpeeds: [Float] = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0]
    static let availableSleepTimers: [TimeInterval] = [300, 600, 900, 1800, 2700, 3600, 5400, 7200]
    
    init() {
        // Load from UserDefaults or use defaults
        if let skipForward = UserDefaults.standard.object(forKey: "skipForwardTime") as? TimeInterval, skipForward > 0 {
            self.skipForwardTime = skipForward
        }
        
        if let skipBackward = UserDefaults.standard.object(forKey: "skipBackwardTime") as? TimeInterval, skipBackward > 0 {
            self.skipBackwardTime = skipBackward
        }
        
        if let playbackSpeed = UserDefaults.standard.object(forKey: "defaultPlaybackSpeed") as? Float, playbackSpeed > 0 {
            self.defaultPlaybackSpeed = playbackSpeed
        }
        
        if let sleepTimer = UserDefaults.standard.object(forKey: "sleepTimerDuration") as? TimeInterval {
            self.sleepTimerDuration = sleepTimer
        }
        
        self.autoPlayNext = UserDefaults.standard.bool(forKey: "autoPlayNext")
        self.autoDownloadNewEpisodes = UserDefaults.standard.bool(forKey: "autoDownloadNewEpisodes")
        self.downloadOnWifiOnly = UserDefaults.standard.bool(forKey: "downloadOnWifiOnly")
        self.autoDeletePlayedEpisodes = UserDefaults.standard.bool(forKey: "autoDeletePlayedEpisodes")
        self.darkModeEnabled = UserDefaults.standard.bool(forKey: "darkModeEnabled")
        self.showEpisodeArtwork = UserDefaults.standard.bool(forKey: "showEpisodeArtwork")
        
        // Load completed podcasts
        if let savedPodcastsData = UserDefaults.standard.data(forKey: "completedPodcasts"),
           let decodedPodcasts = try? JSONDecoder().decode([String].self, from: savedPodcastsData) {
            self.completedPodcasts = decodedPodcasts
        }
    }
    
    // MARK: - Helper Methods
    
    // Format seconds into human-readable string
    static func formatTime(_ seconds: TimeInterval) -> String {
        if seconds < 60 {
            return "\(Int(seconds))s"
        } else if seconds < 3600 {
            return "\(Int(seconds/60))m"
        } else {
            let hours = Int(seconds / 3600)
            let minutes = Int((seconds.truncatingRemainder(dividingBy: 3600)) / 60)
            return "\(hours)h \(minutes)m"
        }
    }
    
    // Format duration for sleep timer display
    static func formatSleepTimer(_ seconds: TimeInterval) -> String {
        if seconds == 0 {
            return "Off"
        } else if seconds < 60 {
            return "\(Int(seconds)) seconds"
        } else if seconds < 3600 {
            return "\(Int(seconds / 60)) minutes"
        } else {
            let hours = Int(seconds / 3600)
            let minutes = Int((seconds.truncatingRemainder(dividingBy: 3600)) / 60)
            if minutes == 0 {
                return "\(hours) hour\(hours > 1 ? "s" : "")"
            } else {
                return "\(hours)h \(minutes)m"
            }
        }
    }
    
    // Reset all preferences to defaults
    func resetToDefaults() {
        skipForwardTime = 30.0
        skipBackwardTime = 15.0
        defaultPlaybackSpeed = 1.0
        autoPlayNext = true
        autoDownloadNewEpisodes = false
        downloadOnWifiOnly = true
        autoDeletePlayedEpisodes = false
        sleepTimerDuration = 1800
        darkModeEnabled = false
        showEpisodeArtwork = true
    }
}

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
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                #endif
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(UserPreferences())
}
