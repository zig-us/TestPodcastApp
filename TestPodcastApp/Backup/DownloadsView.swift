//
//  DownloadsView.swift
//  TestPodcastApp
//

import SwiftUI

struct DownloadsView: View {
    @EnvironmentObject var podcastManager: PodcastManager
    @State private var editMode = EditMode.inactive
    @State private var selectedEpisodes: Set<String> = []
    
    var body: some View {
        VStack {
            if podcastManager.isDownloading {
                // Download progress indicator
                HStack {
                    ProgressView(value: podcastManager.downloadProgress, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle())
                    
                    Text("\(Int(podcastManager.downloadProgress * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            
            List {
                Section(header: Text("Downloaded Episodes")) {
                    let downloadedEpisodes = podcastManager.getDownloadedEpisodes()
                    
                    if downloadedEpisodes.isEmpty {
                        Text("No downloaded episodes")
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        ForEach(downloadedEpisodes) { episode in
                            DownloadedEpisodeRow(episode: episode, isSelected: selectedEpisodes.contains(episode.id))
                                .onTapGesture {
                                    if editMode.isEditing {
                                        toggleSelection(episode.id)
                                    } else {
                                        podcastManager.playEpisode(episode)
                                    }
                                }
                        }
                    }
                }
                
                // Storage section
                Section(header: Text("Storage")) {
                    HStack {
                        Text("Used Space:")
                        Spacer()
                        Text(getStorageUsedText())
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: {
                        deleteSelectedEpisodes()
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Selected Episodes")
                        }
                        .foregroundColor(.red)
                    }
                    .disabled(selectedEpisodes.isEmpty || !editMode.isEditing)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .environment(\.editMode, $editMode)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
    }
    
    // Helper methods
    private func toggleSelection(_ id: String) {
        if selectedEpisodes.contains(id) {
            selectedEpisodes.remove(id)
        } else {
            selectedEpisodes.insert(id)
        }
    }
    
    private func deleteSelectedEpisodes() {
        for id in selectedEpisodes {
            if let episode = podcastManager.allEpisodes.first(where: { $0.id == id }) {
                podcastManager.deleteEpisode(episode)
            }
        }
        selectedEpisodes.removeAll()
        editMode = .inactive
    }
    
    private func getStorageUsedText() -> String {
        let downloadedEpisodes = podcastManager.getDownloadedEpisodes()
        let totalSize = downloadedEpisodes.compactMap { $0.fileSize }.reduce(0, +)
        
        if totalSize < 1024 * 1024 {
            let kb = Double(totalSize) / 1024.0
            return String(format: "%.1f KB", kb)
        } else if totalSize < 1024 * 1024 * 1024 {
            let mb = Double(totalSize) / (1024.0 * 1024.0)
            return String(format: "%.1f MB", mb)
        } else {
            let gb = Double(totalSize) / (1024.0 * 1024.0 * 1024.0)
            return String(format: "%.2f GB", gb)
        }
    }
}

// Downloaded episode row component
struct DownloadedEpisodeRow: View {
    let episode: PodcastEpisode
    let isSelected: Bool
    @EnvironmentObject var podcastManager: PodcastManager
    
    var body: some View {
        HStack {
            if let imageUrl = episode.imageUrl, !imageUrl.isEmpty {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "music.note")
                        .resizable()
                        .padding()
                }
                .frame(width: 50, height: 50)
                .cornerRadius(6)
            } else {
                Image(systemName: "music.note")
                    .resizable()
                    .padding()
                    .frame(width: 50, height: 50)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(6)
            }
            
            VStack(alignment: .leading) {
                Text(episode.title)
                    .font(.headline)
                    .lineLimit(1)
                
                if let show = podcastManager.subscribedShows.first(where: { $0.id == episode.showId }) {
                    Text(show.title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Text(formatSize(episode.fileSize ?? 0))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
            }
        }
    }
    
    // Helper function to format file size
    private func formatSize(_ bytes: Int64) -> String {
        if bytes < 1024 {
            return "\(bytes) B"
        } else if bytes < 1024 * 1024 {
            let kb = Double(bytes) / 1024.0
            return String(format: "%.1f KB", kb)
        } else if bytes < 1024 * 1024 * 1024 {
            let mb = Double(bytes) / (1024.0 * 1024.0)
            return String(format: "%.1f MB", mb)
        } else {
            let gb = Double(bytes) / (1024.0 * 1024.0 * 1024.0)
            return String(format: "%.2f GB", gb)
        }
    }
}

// Preview
struct DownloadsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DownloadsView()
                .environmentObject(PodcastManager())
        }
    }
}
