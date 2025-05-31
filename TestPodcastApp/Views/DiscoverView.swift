//
//  DiscoverView.swift
//  TestPodcastApp
//

import SwiftUI

struct DiscoverView: View {
    @EnvironmentObject var podcastManager: PodcastManager
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Discover Podcasts")
                    .font(.largeTitle)
                    .padding()
                
                Text("Search and browse for new podcasts")
                    .foregroundColor(.secondary)
                
                // Placeholder for search functionality
                Spacer()
            }
            .navigationTitle("Discover")
        }
    }
}

#Preview {
    DiscoverView()
        .environmentObject(PodcastManager())
}
