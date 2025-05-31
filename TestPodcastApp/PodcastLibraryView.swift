//
//  PodcastLibraryView.swift
//  TestPodcastApp
//

import SwiftUI

struct PodcastLibraryView: View {
    @EnvironmentObject var podcastManager: PodcastManager
    
    var body: some View {
        List {
            Section(header: Text("Subscribed Shows")) {
                if podcastManager.subscribedShows.isEmpty {
                    Text("No subscribed podcasts")
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    ForEach(podcastManager.subscribedShows) { show in
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
            
            Section(header: Text("Categories")) {
                if podcastManager.categories.isEmpty {
                    Text("No categories")
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    ForEach(podcastManager.categories) { category in
                        NavigationLink(destination: CategoryView(category: category)) {
                            HStack {
                                Image(systemName: "folder")
                                    .foregroundColor(.blue)
                                Text(category.name)
                                Spacer()
                                Text("\(category.showIds.count)")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

#Preview {
    NavigationView {
        PodcastLibraryView()
            .environmentObject(PodcastManager())
    }
}
