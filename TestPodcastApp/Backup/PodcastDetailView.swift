//
//  PodcastDetailView.swift
//  TestPodcastApp
//

import SwiftUI

struct PodcastDetailView: View {
    let show: PodcastShow
    @EnvironmentObject var podcastManager: PodcastManager
    @State private var showUnsubscribeConfirmation = false
    
    var body: some View {
        List {
            // Header with show info
            VStack(alignment: .center, spacing: 12) {
                if let imageUrl = show.imageUrl, !imageUrl.isEmpty {
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Image(systemName: "music.note")
                            .resizable()
                            .padding()
                    }
                    .frame(width: 160, height: 160)
                    .cornerRadius(12)
                } else {
                    Image(systemName: "music.note")
                        .resizable()
                        .padding()
                        .frame(width: 160, height: 160)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                }
                
                Text(show.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(show.author)
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text(show.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .foregroundColor(.secondary)
                
                // Unsubscribe button
                Button(action: {
                    showUnsubscribeConfirmation = true
                }) {
                    Label("Unsubscribe", systemImage: "minus.circle")
                        .foregroundColor(.red)
                }
                .padding(.top, 8)
            }
            .padding()
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            
            // Episodes section
            Section(header: Text("Episodes")) {
                let episodes = podcastManager.getEpisodesForShow(showId: show.id)
                
                if episodes.isEmpty {
                    Text("No episodes available")
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    ForEach(episodes) { episode in
                        EpisodeRow(episode: episode)
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(show.title)
        .confirmationDialog(
            "Unsubscribe from \(show.title)?",
            isPresented: $showUnsubscribeConfirmation,
            titleVisibility: .visible
        ) {
            Button("Unsubscribe", role: .destructive) {
                podcastManager.unsubscribeFromShow(show)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You will no longer receive new episodes from this podcast.")
        }
    }
}

// Episode row component
struct EpisodeRow: View {
    let episode: PodcastEpisode
    @EnvironmentObject var podcastManager: PodcastManager
    @State private var showingOptions = false
    
    var body: some View {
        Button(action: {
            showingOptions = true
        }) {
            HStack {
                VStack(alignment: .leading) {
                    Text(episode.title)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text(formatDate(episode.publicationDate))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(formatDuration(episode.duration))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Status indicators
                HStack(spacing: 4) {
                    if episode.isPlayed {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                    
                    if episode.isDownloaded {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(.blue)
                    }
                    
                    if episode.isInQueue {
                        Image(systemName: "list.number")
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .actionSheet(isPresented: $showingOptions) {
            ActionSheet(
                title: Text(episode.title),
                buttons: [
                    .default(Text("Play")) {
                        podcastManager.playEpisode(episode)
                    },
                    .default(Text("Add to Queue")) {
                        podcastManager.addToQueue(episode: episode)
                    },
                    .default(Text(episode.isDownloaded ? "Delete Download" : "Download")) {
                        if episode.isDownloaded {
                            podcastManager.deleteEpisode(episode)
                        } else {
                            podcastManager.downloadEpisode(episode) { _ in }
                        }
                    },
                    .default(Text(episode.isPlayed ? "Mark as Unplayed" : "Mark as Played")) {
                        if episode.isPlayed {
                            podcastManager.markEpisodeAsUnplayed(episode)
                        } else {
                            podcastManager.markEpisodeAsPlayed(episode)
                        }
                    },
                    .cancel()
                ]
            )
        }
    }
    
    // Helper functions
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: seconds) ?? ""
    }
}

// Preview
struct PodcastDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleShow = PodcastShow(
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
        
        return NavigationView {
            PodcastDetailView(show: sampleShow)
                .environmentObject(PodcastManager())
        }
    }
}
