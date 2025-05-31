//
//  UserPreferences.swift
//  TestPodcastApp
//

import Foundation
import SwiftUI

class UserPreferences: ObservableObject {
    // MARK: - Playback Settings
    @Published var skipForwardTime: TimeInterval {
        didSet {
            UserDefaults.standard.set(skipForwardTime, forKey: "skipForwardTime")
        }
    }
    
    @Published var skipBackwardTime: TimeInterval {
        didSet {
            UserDefaults.standard.set(skipBackwardTime, forKey: "skipBackwardTime")
        }
    }
    
    @Published var defaultPlaybackSpeed: Float {
        didSet {
            UserDefaults.standard.set(defaultPlaybackSpeed, forKey: "defaultPlaybackSpeed")
        }
    }
    
    @Published var autoPlayNext: Bool {
        didSet {
            UserDefaults.standard.set(autoPlayNext, forKey: "autoPlayNext")
        }
    }
    
    // MARK: - Download Settings
    @Published var autoDownloadNewEpisodes: Bool {
        didSet {
            UserDefaults.standard.set(autoDownloadNewEpisodes, forKey: "autoDownloadNewEpisodes")
        }
    }
    
    @Published var downloadOnWifiOnly: Bool {
        didSet {
            UserDefaults.standard.set(downloadOnWifiOnly, forKey: "downloadOnWifiOnly")
        }
    }
    
    @Published var autoDeletePlayedEpisodes: Bool {
        didSet {
            UserDefaults.standard.set(autoDeletePlayedEpisodes, forKey: "autoDeletePlayedEpisodes")
        }
    }
    
    // MARK: - History Settings
    @Published var completedPodcasts: [String] {
        didSet {
            if let encoded = try? JSONEncoder().encode(completedPodcasts) {
                UserDefaults.standard.set(encoded, forKey: "completedPodcasts")
            }
        }
    }
    
    // MARK: - Sleep Timer
    @Published var sleepTimerDuration: TimeInterval {
        didSet {
            UserDefaults.standard.set(sleepTimerDuration, forKey: "sleepTimerDuration")
        }
    }
    
    // MARK: - UI Settings
    @Published var darkModeEnabled: Bool {
        didSet {
            UserDefaults.standard.set(darkModeEnabled, forKey: "darkModeEnabled")
        }
    }
    
    @Published var showEpisodeArtwork: Bool {
        didSet {
            UserDefaults.standard.set(showEpisodeArtwork, forKey: "showEpisodeArtwork")
        }
    }
    
    // Available preset skip times (in seconds)
    static let availableSkipTimes: [TimeInterval] = [5, 10, 15, 30, 45, 60]
    
    // Available playback speeds
    static let availablePlaybackSpeeds: [Float] = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0]
    
    // Available sleep timer durations
    static let availableSleepTimers: [TimeInterval] = [300, 600, 900, 1800, 2700, 3600, 5400, 7200]
    
    init() {
        // Load all saved preferences
        self.skipForwardTime = UserDefaults.standard.double(forKey: "skipForwardTime")
        self.skipBackwardTime = UserDefaults.standard.double(forKey: "skipBackwardTime")
        self.defaultPlaybackSpeed = UserDefaults.standard.float(forKey: "defaultPlaybackSpeed")
        self.autoPlayNext = UserDefaults.standard.bool(forKey: "autoPlayNext")
        self.autoDownloadNewEpisodes = UserDefaults.standard.bool(forKey: "autoDownloadNewEpisodes")
        self.downloadOnWifiOnly = UserDefaults.standard.bool(forKey: "downloadOnWifiOnly")
        self.autoDeletePlayedEpisodes = UserDefaults.standard.bool(forKey: "autoDeletePlayedEpisodes")
        self.sleepTimerDuration = UserDefaults.standard.double(forKey: "sleepTimerDuration")
        self.darkModeEnabled = UserDefaults.standard.bool(forKey: "darkModeEnabled")
        self.showEpisodeArtwork = UserDefaults.standard.bool(forKey: "showEpisodeArtwork")
        
        // Load completed podcasts
        if let savedPodcastsData = UserDefaults.standard.data(forKey: "completedPodcasts"),
           let decodedPodcasts = try? JSONDecoder().decode([String].self, from: savedPodcastsData) {
            self.completedPodcasts = decodedPodcasts
        } else {
            self.completedPodcasts = []
        }
        
        // Set default values for any uninitialized settings
        if self.skipForwardTime == 0 {
            self.skipForwardTime = 30.0
        }
        
        if self.skipBackwardTime == 0 {
            self.skipBackwardTime = 15.0
        }
        
        if self.defaultPlaybackSpeed == 0 {
            self.defaultPlaybackSpeed = 1.0
        }
        
        if self.sleepTimerDuration == 0 {
            self.sleepTimerDuration = 1800 // 30 minutes
        }
        
        // Set defaults for boolean values (they default to false if not set)
        if !UserDefaults.standard.object(forKey: "autoPlayNext").safelyUnwrapped {
            self.autoPlayNext = true
        }
        
        if !UserDefaults.standard.object(forKey: "showEpisodeArtwork").safelyUnwrapped {
            self.showEpisodeArtwork = true
        }
        
        if !UserDefaults.standard.object(forKey: "downloadOnWifiOnly").safelyUnwrapped {
            self.downloadOnWifiOnly = true
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

// Helper extension for safely unwrapping Optional<Any>
extension Optional where Wrapped == Any {
    var safelyUnwrapped: Bool {
        return self != nil
    }
}
