//
//  PodcastManager.swift
//  TestPodcastApp
//

import Foundation
import SwiftUI
import AVFoundation
import Combine

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
            author: "John Doe",
            description: "This is a sample podcast for testing purposes",
            imageUrl: nil,
            feedUrl: "https://example.com/feed",
            category: "Technology",
            lastUpdated: Date(),
            isSubscribed: true
        )
        
        // Create a sample episode
        let exampleEpisode = PodcastEpisode(
            id: "com.example.podcast.ep1",
            showId: exampleShow.id,
            title: "Introduction to Podcasting",
            description: "Learn the basics of podcasting in this episode",
            publicationDate: Date(),
            duration: 1800, // 30 minutes
            audioUrl: "example",
            fileSize: 10 * 1024 * 1024, // 10MB
            imageUrl: nil,
            isPlayed: false,
            playbackPosition: 0,
            isDownloaded: true,
            localFilePath: "example"
        )
        
        // Create a sample category
        let techCategory = PodcastCategory(
            id: "technology",
            name: "Technology",
            showIds: [exampleShow.id]
        )
        
        // Add to our collections
        subscribedShows.append(exampleShow)
        allEpisodes.append(exampleEpisode)
        categories.append(techCategory)
        
        // Add to queue
        playbackQueue.add(episodeId: exampleEpisode.id)
        playbackQueue.currentIndex = 0
        currentEpisode = exampleEpisode
        
        // Save the initial data
        saveData()
    }
    
    // MARK: - Audio Session Setup
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    // MARK: - Playback Control
    func playEpisode(_ episode: PodcastEpisode) {
        // If this is a different episode than what's currently playing, stop current playback
        if currentEpisode?.id != episode.id {
            stopPlayback()
            currentEpisode = episode
            
            // Update queue if needed
            if let index = playbackQueue.episodes.firstIndex(of: episode.id) {
                playbackQueue.currentIndex = index
            } else {
                playbackQueue.add(episodeId: episode.id)
                playbackQueue.currentIndex = playbackQueue.episodes.count - 1
            }
        }
        
        // Get the audio file
        guard let audioPath = getAudioPath(for: episode) else {
            print("Could not find audio file")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioPath)
            audioPlayer?.enableRate = true
            audioPlayer?.prepareToPlay()
            
            // Set the playback position if we have one saved
            if episode.playbackPosition > 0 {
                audioPlayer?.currentTime = episode.playbackPosition
            }
            
            // Set the playback rate
            audioPlayer?.rate = currentSpeed
            
            // Start playback
            audioPlayer?.play()
            isPlaying = true
            
            // Start progress tracking
            startProgressTracking()
            
            saveData()
        } catch {
            print("Failed to play episode: \(error)")
        }
    }
    
    func pausePlayback() {
        audioPlayer?.pause()
        isPlaying = false
        saveCurrentPosition()
        stopProgressTracking()
    }
    
    func resumePlayback() {
        audioPlayer?.play()
        isPlaying = true
        startProgressTracking()
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        isPlaying = false
        saveCurrentPosition()
        stopProgressTracking()
        audioPlayer = nil
    }
    
    func togglePlayPause() {
        if isPlaying {
            pausePlayback()
        } else if currentEpisode != nil {
            resumePlayback()
        } else if let firstEpisode = getNextEpisodeFromQueue() {
            playEpisode(firstEpisode)
        }
    }
    
    func skipForward(_ seconds: TimeInterval) {
        guard let player = audioPlayer else { return }
        
        let newTime = min(player.duration, player.currentTime + seconds)
        player.currentTime = newTime
        updateProgress()
    }
    
    func skipBackward(_ seconds: TimeInterval) {
        guard let player = audioPlayer else { return }
        
        let newTime = max(0, player.currentTime - seconds)
        player.currentTime = newTime
        updateProgress()
    }
    
    func skipToEnd() {
        guard let player = audioPlayer else { return }
        
        player.currentTime = max(0, player.duration - 3)
        updateProgress()
    }
    
    func setPlaybackSpeed(_ speed: Float) {
        currentSpeed = speed
        audioPlayer?.rate = speed
    }
    
    func seekTo(progress: Double) {
        guard let player = audioPlayer else { return }
        
        let newTime = player.duration * progress
        player.currentTime = newTime
        updateProgress()
    }
    
    // MARK: - Progress Tracking
    private func startProgressTracking() {
        stopProgressTracking() // Stop any existing timers
        
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.updateProgress()
        }
    }
    
    private func stopProgressTracking() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    private func updateProgress() {
        guard let player = audioPlayer, let episode = currentEpisode else { return }
        
        // Update progress
        playbackProgress = player.currentTime / player.duration
        
        // Check if episode has finished
        if player.duration > 0 && player.currentTime >= player.duration - 0.5 {
            markEpisodeAsPlayed(episode)
            playNextEpisode()
        }
    }
    
    private func saveCurrentPosition() {
        guard let player = audioPlayer, let episode = currentEpisode else { return }
        
        // Update the episode's position
        if var updatedEpisode = allEpisodes.first(where: { $0.id == episode.id }) {
            updatedEpisode.playbackPosition = player.currentTime
            
            // Mark as played if we're near the end
            if player.currentTime >= player.duration * 0.9 {
                updatedEpisode.isPlayed = true
            }
            
            // Update in our collection
            if let index = allEpisodes.firstIndex(where: { $0.id == episode.id }) {
                allEpisodes[index] = updatedEpisode
            }
            
            // Save data
            saveData()
        }
    }
    
    // MARK: - Queue Management
    func playNextEpisode() {
        if let nextEpisodeId = playbackQueue.moveToNext(),
           let nextEpisode = allEpisodes.first(where: { $0.id == nextEpisodeId }) {
            playEpisode(nextEpisode)
        } else {
            stopPlayback()
            currentEpisode = nil
        }
    }
    
    func playPreviousEpisode() {
        if let prevEpisodeId = playbackQueue.moveToPrevious(),
           let prevEpisode = allEpisodes.first(where: { $0.id == prevEpisodeId }) {
            playEpisode(prevEpisode)
        }
    }
    
    func getNextEpisodeFromQueue() -> PodcastEpisode? {
        if let currentId = playbackQueue.getCurrentEpisodeId() {
            return allEpisodes.first(where: { $0.id == currentId })
        } else if !playbackQueue.isEmpty, let firstId = playbackQueue.episodes.first {
            playbackQueue.currentIndex = 0
            return allEpisodes.first(where: { $0.id == firstId })
        }
        return nil
    }
    
    func addToQueue(episode: PodcastEpisode) {
        playbackQueue.add(episodeId: episode.id)
        saveData()
    }
    
    func removeFromQueue(episode: PodcastEpisode) {
        playbackQueue.remove(episodeId: episode.id)
        saveData()
    }
    
    func clearQueue() {
        playbackQueue = PlaybackQueue()
        saveData()
    }
    
    // MARK: - Episode Management
    func markEpisodeAsPlayed(_ episode: PodcastEpisode) {
        if var updatedEpisode = allEpisodes.first(where: { $0.id == episode.id }) {
            updatedEpisode.isPlayed = true
            updatedEpisode.playbackPosition = 0
            
            // Update in our collection
            if let index = allEpisodes.firstIndex(where: { $0.id == episode.id }) {
                allEpisodes[index] = updatedEpisode
            }
            
            // Save data
            saveData()
        }
    }
    
    func markEpisodeAsUnplayed(_ episode: PodcastEpisode) {
        if var updatedEpisode = allEpisodes.first(where: { $0.id == episode.id }) {
            updatedEpisode.isPlayed = false
            updatedEpisode.playbackPosition = 0
            
            // Update in our collection
            if let index = allEpisodes.firstIndex(where: { $0.id == episode.id }) {
                allEpisodes[index] = updatedEpisode
            }
            
            // Save data
            saveData()
        }
    }
    
    func deleteEpisode(_ episode: PodcastEpisode) {
        // Remove from queue if needed
        if playbackQueue.episodes.contains(episode.id) {
            playbackQueue.remove(episodeId: episode.id)
        }
        
        // Remove from downloaded files if needed
        if episode.isDownloaded, let localPath = episode.localFilePath {
            deleteDownloadedFile(at: localPath)
        }
        
        // Remove from episodes list
        allEpisodes.removeAll(where: { $0.id == episode.id })
        
        // Save data
        saveData()
    }
    
    // MARK: - Show Management
    func subscribeToShow(_ show: PodcastShow) {
        var updatedShow = show
        updatedShow.isSubscribed = true
        
        // Add to our subscribed shows
        if let index = subscribedShows.firstIndex(where: { $0.id == show.id }) {
            subscribedShows[index] = updatedShow
        } else {
            subscribedShows.append(updatedShow)
        }
        
        // Update categories
        if let category = show.category {
            if let index = categories.firstIndex(where: { $0.name == category }) {
                var updatedCategory = categories[index]
                if !updatedCategory.showIds.contains(show.id) {
                    updatedCategory.showIds.append(show.id)
                    categories[index] = updatedCategory
                }
            } else {
                let newCategory = PodcastCategory(id: UUID().uuidString, name: category, showIds: [show.id])
                categories.append(newCategory)
            }
        }
        
        saveData()
    }
    
    func unsubscribeFromShow(_ show: PodcastShow) {
        // Remove from subscribed shows
        subscribedShows.removeAll(where: { $0.id == show.id })
        
        // Update categories
        for (index, category) in categories.enumerated() {
            if category.showIds.contains(show.id) {
                var updatedCategory = category
                updatedCategory.showIds.removeAll(where: { $0 == show.id })
                categories[index] = updatedCategory
            }
        }
        
        saveData()
    }
    
    // MARK: - File Management
    private func getAudioPath(for episode: PodcastEpisode) -> URL? {
        // If we have a local file, use that
        if episode.isDownloaded, let localPath = episode.localFilePath {
            // For demo purposes, we'll use the bundled file
            if localPath == "example" {
                return Bundle.main.url(forResource: "example", withExtension: "mp3")
            }
            
            // Otherwise use the file URL
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            return documentsDirectory.appendingPathComponent(localPath)
        }
        
        // If no local file and for our example, use the bundled file
        if episode.audioUrl == "example" {
            return Bundle.main.url(forResource: "example", withExtension: "mp3")
        }
        
        // Otherwise, we'd need to download or stream
        return nil
    }
    
    private func deleteDownloadedFile(at path: String) {
        // Don't delete bundled resources
        if path == "example" {
            return
        }
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(path)
        
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print("Error deleting file: \(error)")
        }
    }
    
    // MARK: - Downloading
    func downloadEpisode(_ episode: PodcastEpisode, completion: @escaping (Bool) -> Void) {
        // Skip for example episode which is already "downloaded"
        if episode.audioUrl == "example" {
            if var updatedEpisode = allEpisodes.first(where: { $0.id == episode.id }) {
                updatedEpisode.isDownloaded = true
                updatedEpisode.localFilePath = "example"
                
                if let index = allEpisodes.firstIndex(where: { $0.id == episode.id }) {
                    allEpisodes[index] = updatedEpisode
                }
                
                saveData()
                completion(true)
            }
            return
        }
        
        // Here we would implement actual downloading logic
        // For demo purposes, we'll simulate a download
        isDownloading = true
        downloadProgress = 0.0
        
        // Simulate download progress
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            self.downloadProgress += 0.05
            
            if self.downloadProgress >= 1.0 {
                timer.invalidate()
                self.isDownloading = false
                
                // Update episode as downloaded
                if var updatedEpisode = self.allEpisodes.first(where: { $0.id == episode.id }) {
                    updatedEpisode.isDownloaded = true
                    updatedEpisode.localFilePath = "downloaded_\(episode.id).mp3"
                    
                    if let index = self.allEpisodes.firstIndex(where: { $0.id == episode.id }) {
                        self.allEpisodes[index] = updatedEpisode
                    }
                    
                    self.saveData()
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
        RunLoop.current.add(timer, forMode: .common)
    }
    
    // MARK: - Helper Methods
    func getEpisodesForShow(showId: String) -> [PodcastEpisode] {
        return allEpisodes.filter { $0.showId == showId }
    }
    
    func getNewEpisodes() -> [PodcastEpisode] {
        return allEpisodes.filter { !$0.isPlayed }
    }
    
    func getDownloadedEpisodes() -> [PodcastEpisode] {
        return allEpisodes.filter { $0.isDownloaded }
    }
    
    func getEpisodesInQueue() -> [PodcastEpisode] {
        return playbackQueue.episodes.compactMap { episodeId in
            allEpisodes.first(where: { $0.id == episodeId })
        }
    }
}
