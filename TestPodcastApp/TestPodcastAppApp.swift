//
//  TestPodcastAppApp.swift
//  TestPodcastApp
//
//  Created by Ben Ziegler on 4/5/24.
//

import SwiftUI
import AVFoundation

// Copy of UserPreferences for app to compile
// This will be replaced by proper import in a real app
class AppUserPreferences: ObservableObject {
    @Published var skipForwardTime: TimeInterval = 30.0
    @Published var skipBackwardTime: TimeInterval = 15.0 
    @Published var defaultPlaybackSpeed: Float = 1.0
    @Published var autoPlayNext: Bool = true
    @Published var autoDownloadNewEpisodes: Bool = false
    @Published var downloadOnWifiOnly: Bool = true
    @Published var autoDeletePlayedEpisodes: Bool = false
    @Published var sleepTimerDuration: TimeInterval = 1800
    @Published var darkModeEnabled: Bool = false
    @Published var showEpisodeArtwork: Bool = true
    @Published var completedPodcasts: [String] = []
    
    static let availableSkipTimes: [TimeInterval] = [5, 10, 15, 30, 45, 60]
    static let availablePlaybackSpeeds: [Float] = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0]
    static let availableSleepTimers: [TimeInterval] = [300, 600, 900, 1800, 2700, 3600]
    
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
    
    static func formatTime(_ seconds: TimeInterval) -> String {
        if seconds < 60 {
            return "\(Int(seconds))s"
        } else {
            return "\(Int(seconds/60))m"
        }
    }
    
    static func formatSleepTimer(_ seconds: TimeInterval) -> String {
        if seconds == 0 {
            return "Off"
        } else if seconds < 3600 {
            return "\(Int(seconds / 60)) min"
        } else {
            return "\(Int(seconds / 3600)) hr"
        }
    }
}

// Simple PodcastManager for the app to compile
class AppPodcastManager: ObservableObject {
    @Published var currentPodcast: String?
    
    func skipToEnd(audioPlayer: AVAudioPlayer?) {
        guard let player = audioPlayer else { return }
        player.currentTime = max(0, player.duration - 3)
    }
    
    func markAsComplete(podcast: String, preferences: AppUserPreferences) {
        if !preferences.completedPodcasts.contains(podcast) {
            preferences.completedPodcasts.append(podcast)
        }
    }
}

// Simple SettingsView for the app to compile
struct AppSettingsView: View {
    @EnvironmentObject var preferences: AppUserPreferences
    
    var body: some View {
        Text("Settings")
            .font(.largeTitle)
            .padding()
    }
}

// Main app struct
@main
struct TestPodcastAppApp: App {
    @StateObject private var preferences = AppUserPreferences()
    @StateObject private var podcastManager = AppPodcastManager()
    
    var body: some Scene {
        WindowGroup {
            AppSettingsView()
                .environmentObject(preferences)
        }
    }
}

