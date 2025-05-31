//
//  PodcastDetailView.swift
//  TestPodcastApp
//

import SwiftUI

struct PodcastDetailView: View {
    let show: PodcastShow
    @EnvironmentObject var podcastManager: PodcastManager
    
    var body: some View {
        List {
            // Show header
            VStack(alignment: .center, spacing: 10) {
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
                    .frame(width: 200, height: 200)
                    .cornerRadius(8)
                } else {
                    Image(systemName: "music.note")
                        .resizable()
                        .padding()
                        .frame(width: 200, height: 200)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
                
                Text(show.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(show.author)
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text(show.description)
                    .font(.body)
                    .padding(.top, 5)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .listRowInsets(EdgeInsets())
            
            // Episodes
            Section(header: Text("Episodes")) {
                let episodes = podcastManager.allEpisodes.filter { $0.showId == show.id }
                
                if episodes.isEmpty {
                    Text("No episodes available")
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    ForEach(episodes) { episode in
                        Button(action: {
                            podcastManager.play(episode: episode)
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(episode.title)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text(formatDate(episode.publicationDate))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Text(formatDuration(episode.duration))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Podcast Details")
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

#Preview {
    let sampleShow = PodcastShow(
        id: "com.example.podcast",
        title: "Example Podcast",
        author: "Example Author",
        description: "This is an example podcast description that might be a bit longer and wrap to multiple lines.",
        imageUrl: nil,
        feedUrl: "https://example.com/feed",
        category: "Technology",
        lastUpdated: Date()
    )
    
    return NavigationView {
        PodcastDetailView(show: sampleShow)
            .environmentObject(PodcastManager())
    }
}
