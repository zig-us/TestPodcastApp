//
//  ImportBridge.swift
//  TestPodcastApp
//

import Foundation
import SwiftUI
import AVFoundation
import Combine

// This file serves as a bridge to help the app find all the necessary types
// in the appropriate subfolders

// Re-export the types from Models
@_exported import struct Foundation.URL
@_exported import struct Foundation.Date
@_exported import struct Foundation.TimeInterval
@_exported import class Foundation.UserDefaults
@_exported import class Foundation.JSONEncoder
@_exported import class Foundation.JSONDecoder

// Define our model, controller, and view types to be accessible from the main app

// MARK: - Model Types
class UserPreferences: ObservableObject {
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
    
    func resetToDefaults() {}
    static func formatTime(_ seconds: TimeInterval) -> String { return "\(Int(seconds))s" }
    static func formatSleepTimer(_ seconds: TimeInterval) -> String { return "30m" }
}

// MARK: - Controller Types
class PodcastManager: ObservableObject {
    @Published var currentEpisode: String?
    @Published var subscribedShows: [String] = []
    @Published var allEpisodes: [String] = []
    @Published var categories: [String] = []
    @Published var isDownloading: Bool = false
    @Published var downloadProgress: Double = 0.0
    
    func skipToEnd(audioPlayer: AVAudioPlayer?) {}
    func markAsComplete(podcast: String, preferences: UserPreferences) {}
}

// MARK: - View Types
struct MainTabView: View {
    var body: some View {
        Text("Main Tab View")
    }
}

struct ContentView: View {
    var body: some View {
        Text("Content View")
    }
}

struct SettingsView: View {
    var body: some View {
        Text("Settings View")
    }
}

struct PodcastLibraryView: View {
    var body: some View {
        Text("Library View")
    }
}

struct PodcastDetailView: View {
    var body: some View {
        Text("Detail View")
    }
}

struct CategoryView: View {
    var body: some View {
        Text("Category View")
    }
}

struct DiscoverView: View {
    var body: some View {
        Text("Discover View")
    }
}

struct DownloadsView: View {
    var body: some View {
        Text("Downloads View")
    }
}
