//
//  PodcastModel.swift
//  TestPodcastApp
//

import Foundation

// MARK: - Podcast Show
struct PodcastShow: Identifiable, Codable, Equatable {
    var id: String // Usually the feed URL
    var title: String
    var author: String
    var description: String
    var imageUrl: String?
    var feedUrl: String
    var category: String?
    var lastUpdated: Date
    var isSubscribed: Bool = false
    
    static func == (lhs: PodcastShow, rhs: PodcastShow) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Podcast Episode
struct PodcastEpisode: Identifiable, Codable, Equatable {
    var id: String // Usually the guid from RSS
    var showId: String // Reference to parent show
    var title: String
    var description: String
    var publicationDate: Date
    var duration: TimeInterval
    var audioUrl: String
    var fileSize: Int64?
    var imageUrl: String?
    
    // Playback state
    var isPlayed: Bool = false
    var playbackPosition: TimeInterval = 0
    var isDownloaded: Bool = false
    var localFilePath: String?
    var isInQueue: Bool = false
    var queuePosition: Int?
    
    static func == (lhs: PodcastEpisode, rhs: PodcastEpisode) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Category
struct PodcastCategory: Identifiable, Codable, Equatable {
    var id: String
    var name: String
    var showIds: [String] = []
    
    static func == (lhs: PodcastCategory, rhs: PodcastCategory) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Playback Queue
struct PlaybackQueue: Codable {
    var episodes: [String] = [] // Episode IDs in queue order
    var currentIndex: Int = -1
    
    var isEmpty: Bool {
        return episodes.isEmpty
    }
    
    var hasNext: Bool {
        return !isEmpty && currentIndex < episodes.count - 1
    }
    
    var hasPrevious: Bool {
        return !isEmpty && currentIndex > 0
    }
    
    mutating func add(episodeId: String) {
        if !episodes.contains(episodeId) {
            episodes.append(episodeId)
        }
    }
    
    mutating func remove(episodeId: String) {
        if let index = episodes.firstIndex(of: episodeId) {
            episodes.remove(at: index)
            if index <= currentIndex && currentIndex > 0 {
                currentIndex -= 1
            }
        }
    }
    
    mutating func moveToNext() -> String? {
        guard hasNext else { return nil }
        currentIndex += 1
        return episodes[currentIndex]
    }
    
    mutating func moveToPrevious() -> String? {
        guard hasPrevious else { return nil }
        currentIndex -= 1
        return episodes[currentIndex]
    }
    
    func getCurrentEpisodeId() -> String? {
        guard !isEmpty && currentIndex >= 0 && currentIndex < episodes.count else {
            return nil
        }
        return episodes[currentIndex]
    }
}
