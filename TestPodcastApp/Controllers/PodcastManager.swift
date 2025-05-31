//
//  PodcastManager.swift
//  TestPodcastApp
//

import Foundation
import SwiftUI
import AVFoundation
import Combine

#if os(iOS)
import UIKit
#endif

// Import our models
@_implementationOnly import struct TestPodcastApp.PodcastShow
@_implementationOnly import struct TestPodcastApp.PodcastEpisode
@_implementationOnly import struct TestPodcastApp.PodcastCategory
@_implementationOnly import struct TestPodcastApp.PlaybackQueue
@_implementationOnly import class TestPodcastApp.UserPreferences

class PodcastManager: ObservableObject {
    // MARK: - Published Properties
    @Published var subscribedShows: [PodcastShow] = []
    @Published var allEpisodes: [PodcastEpisode] = []
    @Published var categories: [PodcastCategory] = []
    @Published var playbackQueue = PlaybackQueue()
    @Published var isPlaying = false
    @Published var currentEpisode: PodcastEpisode?
    @Published var playbackProgress: Double = 0.0
    @Published var currentSpeed: Float = 1.0
    @Published var isDownloading = false
    @Published var downloadProgress: Double = 0.0
    
    // For legacy compatibility
    @Published var currentPodcast: PodcastEpisode? {
        didSet {
            if let podcast = currentPodcast {
                currentEpisode = podcast
            }
        }
    }
    
    // Audio player
    private var audioPlayer: AVAudioPlayer?
    private var progressTimer: Timer?
    private var userDefaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadSavedData()
        setupAudioSession()
        
        // Add example data if we're starting fresh
        if subscribedShows.isEmpty {
            addExampleData()
        }
    }
    
    // MARK: - Audio Session Setup
    private func setupAudioSession() {
        #if os(iOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
        #endif
    }
    
    // MARK: - Data Loading and Saving
    private func loadSavedData() {
        // Load shows
        if let data = userDefaults.data(forKey: "subscribedShows"),
           let shows = try? JSONDecoder().decode([PodcastShow].self, from: data) {
            self.subscribedShows = shows
        }
        
        // Load episodes
        if let data = userDefaults.data(forKey: "allEpisodes"),
           let episodes = try? JSONDecoder().decode([PodcastEpisode].self, from: data) {
            self.allEpisodes = episodes
        }
        
        // Load categories
        if let data = userDefaults.data(forKey: "categories"),
           let categories = try? JSONDecoder().decode([PodcastCategory].self, from: data) {
            self.categories = categories
        }
        
        // Load queue
        if let data = userDefaults.data(forKey: "playbackQueue"),
           let queue = try? JSONDecoder().decode(PlaybackQueue.self, from: data) {
            self.playbackQueue = queue
            
            // Load current episode if there is one
            if let currentId = queue.getCurrentEpisodeId(),
               let episode = allEpisodes.first(where: { $0.id == currentId }) {
                self.currentEpisode = episode
                self.currentPodcast = episode
            }
        }
    }
    
    private func saveData() {
        // Save shows
        if let data = try? JSONEncoder().encode(subscribedShows) {
            userDefaults.set(data, forKey: "subscribedShows")
        }
        
        // Save episodes
        if let data = try? JSONEncoder().encode(allEpisodes) {
            userDefaults.set(data, forKey: "allEpisodes")
        }
        
        // Save categories
        if let data = try? JSONEncoder().encode(categories) {
            userDefaults.set(data, forKey: "categories")
        }
        
        // Save queue
        if let data = try? JSONEncoder().encode(playbackQueue) {
            userDefaults.set(data, forKey: "playbackQueue")
        }
    }
    
    // MARK: - Sample Data
    private func addExampleData() {
        // Create a sample podcast show
        let exampleShow = PodcastShow(
            id: "com.example.podcast",
            title: "Example Podcast",
            author: "Example Author",
            description: "This is an example podcast description.",
            imageUrl: nil,
            feedUrl: "https://example.com/feed",
            category: "Technology",
            lastUpdated: Date(),
            isSubscribed: true
        )
        
        // Create a sample podcast episode
        let exampleEpisode = PodcastEpisode(
            id: "ep1",
            showId: exampleShow.id,
            title: "Example Episode",
            description: "This is an example episode description.",
            publicationDate: Date(),
            duration: 1800, // 30 minutes
            audioUrl: "https://example.com/episode.mp3"
        )
        
        // Add sample data
        subscribedShows.append(exampleShow)
        allEpisodes.append(exampleEpisode)
        
        // Add a category
        let techCategory = PodcastCategory(
            id: "technology",
            name: "Technology",
            showIds: [exampleShow.id]
        )
        categories.append(techCategory)
        
        // Save the sample data
        saveData()
    }
    
    // MARK: - Playback Control Methods
    
    func play(episode: PodcastEpisode? = nil) {
        if let episodeToPlay = episode {
            // Stop current playback if any
            if isPlaying {
                stopPlayback()
            }
            
            // Set new episode
            currentEpisode = episodeToPlay
            currentPodcast = episodeToPlay
            
            // Update queue if needed
            if playbackQueue.getCurrentEpisodeId() != episodeToPlay.id {
                if let index = playbackQueue.episodes.firstIndex(of: episodeToPlay.id) {
                    playbackQueue.currentIndex = index
                } else {
                    playbackQueue.add(episodeId: episodeToPlay.id)
                    playbackQueue.currentIndex = playbackQueue.episodes.count - 1
                }
                saveData()
            }
            
            // Start playback
            startPlayback(episode: episodeToPlay)
        } else if let currentEpisode = currentEpisode {
            // Play/pause current episode
            if isPlaying {
                pausePlayback()
            } else {
                startPlayback(episode: currentEpisode)
            }
        }
    }
    
    private func startPlayback(episode: PodcastEpisode) {
        // In a real app, we would load from the actual URL
        // For now, use the bundled example file
        guard let url = Bundle.main.url(forResource: "example", withExtension: "mp3") else {
            print("Audio file not found")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.enableRate = true
            audioPlayer?.prepareToPlay()
            
            // Set saved position if any
            if episode.playbackPosition > 0 {
                audioPlayer?.currentTime = episode.playbackPosition
            }
            
            // Set playback speed
            audioPlayer?.rate = currentSpeed
            
            // Start playback
            audioPlayer?.play()
            isPlaying = true
            
            // Start progress tracking
            startProgressTracking()
        } catch {
            print("Error starting playback: \(error)")
        }
    }
    
    private func pausePlayback() {
        audioPlayer?.pause()
        isPlaying = false
        stopProgressTracking()
        
        // Save current position
        if let episode = currentEpisode, let position = audioPlayer?.currentTime {
            updatePlaybackPosition(for: episode.id, position: position)
        }
    }
    
    private func stopPlayback() {
        audioPlayer?.stop()
        isPlaying = false
        stopProgressTracking()
        
        // Save current position
        if let episode = currentEpisode, let position = audioPlayer?.currentTime {
            updatePlaybackPosition(for: episode.id, position: position)
        }
    }
    
    private func startProgressTracking() {
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.audioPlayer else { return }
            
            // Update progress
            if player.duration > 0 {
                self.playbackProgress = player.currentTime / player.duration
            }
            
            // Save position periodically
            if let episode = self.currentEpisode {
                self.updatePlaybackPosition(for: episode.id, position: player.currentTime)
            }
        }
    }
    
    private func stopProgressTracking() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    private func updatePlaybackPosition(for episodeId: String, position: TimeInterval) {
        if let index = allEpisodes.firstIndex(where: { $0.id == episodeId }) {
            allEpisodes[index].playbackPosition = position
            saveData()
        }
    }
    
    // MARK: - Skip Controls
    
    func skipToEnd(audioPlayer: AVAudioPlayer? = nil) {
        let player = audioPlayer ?? self.audioPlayer
        
        guard let player = player else { return }
        player.currentTime = max(0, player.duration - 3)
    }
    
    func skipForward(seconds: TimeInterval) {
        guard let player = audioPlayer else { return }
        
        let newTime = min(player.duration, player.currentTime + seconds)
        player.currentTime = newTime
    }
    
    func skipBackward(seconds: TimeInterval) {
        guard let player = audioPlayer else { return }
        
        let newTime = max(0, player.currentTime - seconds)
        player.currentTime = newTime
    }
    
    func setPlaybackSpeed(_ speed: Float) {
        guard let player = audioPlayer else { return }
        
        currentSpeed = speed
        player.rate = speed
    }
    
    // MARK: - Playlist Management
    
    func playNext() {
        if let nextEpisodeId = playbackQueue.moveToNext(),
           let nextEpisode = allEpisodes.first(where: { $0.id == nextEpisodeId }) {
            play(episode: nextEpisode)
        }
    }
    
    func playPrevious() {
        if let prevEpisodeId = playbackQueue.moveToPrevious(),
           let prevEpisode = allEpisodes.first(where: { $0.id == prevEpisodeId }) {
            play(episode: prevEpisode)
        }
    }
    
    // MARK: - Episode Management
    
    func markAsComplete(podcast: PodcastEpisode, preferences: UserPreferences) {
        if !preferences.completedPodcasts.contains(podcast.id) {
            preferences.completedPodcasts.append(podcast.id)
        }
        
        // Update episode status
        if let index = allEpisodes.firstIndex(where: { $0.id == podcast.id }) {
            allEpisodes[index].isPlayed = true
            saveData()
        }
    }
    
    // Legacy method for backward compatibility
    func markAsComplete(podcast: String, preferences: UserPreferences) {
        if !preferences.completedPodcasts.contains(podcast) {
            preferences.completedPodcasts.append(podcast)
        }
    }
}
