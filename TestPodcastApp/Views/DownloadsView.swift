//
//  DownloadsView.swift
//  TestPodcastApp
//

import SwiftUI

struct DownloadsView: View {
    @EnvironmentObject var podcastManager: PodcastManager
    
    var body: some View {
        NavigationView {
            VStack {
                if podcastManager.isDownloading {
                    ProgressView(value: podcastManager.downloadProgress, total: 1.0)
                        .padding()
                    
                    Text("Downloading...")
                        .foregroundColor(.secondary)
                } else {
                    Text("No active downloads")
                        .foregroundColor(.secondary)
                        .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Downloads")
        }
    }
}

#Preview {
    DownloadsView()
        .environmentObject(PodcastManager())
}
