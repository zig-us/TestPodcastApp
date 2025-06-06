//
//  TestPodcastAppApp.swift
//  TestPodcastApp
//
//  Created by Ben Ziegler on 4/5/24.
//

import SwiftUI
import AVFoundation
import Foundation
import Combine

// MARK: - App Entry Point
struct TestPodcastAppApp: App {
    // Create our main model objects as StateObjects so they persist for the app's lifetime
    @StateObject private var preferences = UserPreferences()
    @StateObject private var podcastManager = PodcastManager()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(preferences)
                .environmentObject(podcastManager)
        }
    }
}

// MARK: - Model Definitions (These will be replaced with proper imports)
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

// MARK: - View Definitions (These will be replaced with proper imports)
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

// MARK: - App Entry Point
// Cannot use @main directly due to top-level code issue
struct TestPodcastAppApp: App {
    // Create our main model objects as StateObjects so they persist for the app's lifetime
    @StateObject private var preferences = UserPreferences()
    @StateObject private var podcastManager = PodcastManager()
    
    init() {
        // Initialize any app-wide settings or configurations here
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(preferences)
                .environmentObject(podcastManager)
        }
    }
}

// Manual entry point
@main 
struct AppLauncher {
    static func main() {
        if #available(iOS 14.0, macOS 11.0, *) {
            TestPodcastAppApp.main()
        } else {
            print("Unsupported OS version")
        }
    }
}

