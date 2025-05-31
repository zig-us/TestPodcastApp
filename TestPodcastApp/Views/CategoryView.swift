//
//  CategoryView.swift
//  TestPodcastApp
//

import SwiftUI

struct CategoryView: View {
    let category: PodcastCategory
    @EnvironmentObject var podcastManager: PodcastManager
    
    var body: some View {
        List {
            Section(header: Text("Shows in \(category.name)")) {
                let shows = podcastManager.subscribedShows.filter { category.showIds.contains($0.id) }
                
                if shows.isEmpty {
                    Text("No shows in this category")
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    ForEach(shows) { show in
                        NavigationLink(destination: PodcastDetailView(show: show)) {
                            HStack {
                                if let imageUrl = show.imageUrl, !imageUrl.isEmpty {
                                    AsyncImage(url: URL(string: imageUrl)) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Image(systemName: "music.note")
                                            .resizable()
                                            .padding()
                                    }
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(8)
                                } else {
                                    Image(systemName: "music.note")
                                        .resizable()
                                        .padding()
                                        .frame(width: 60, height: 60)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(8)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(show.title)
                                        .font(.headline)
                                    Text(show.author)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(category.name)
    }
}

#Preview {
    let sampleCategory = PodcastCategory(
        id: "technology",
        name: "Technology",
        showIds: ["com.example.podcast"]
    )
    
    return NavigationView {
        CategoryView(category: sampleCategory)
            .environmentObject(PodcastManager())
    }
}
