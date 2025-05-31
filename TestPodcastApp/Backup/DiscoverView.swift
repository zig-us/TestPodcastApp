//
//  DiscoverView.swift
//  TestPodcastApp
//

import SwiftUI

struct DiscoverView: View {
    @EnvironmentObject var podcastManager: PodcastManager
    @State private var searchText = ""
    @State private var searchResults: [PodcastShow] = []
    @State private var isSearching = false
    
    var body: some View {
        VStack {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search podcasts", text: $searchText)
                    .onSubmit {
                        searchPodcasts()
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        searchResults = []
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            
            if isSearching {
                ProgressView("Searching...")
                    .padding()
            } else if !searchText.isEmpty {
                List {
                    if searchResults.isEmpty {
                        Text("No results found")
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        ForEach(searchResults) { show in
                            PodcastSearchRow(show: show)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            } else {
                // Featured content when not searching
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Featured Podcasts")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(getFeaturedPodcasts()) { show in
                                    FeaturedPodcastCard(show: show)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Text("Popular Categories")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                            .padding(.top)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
                            ForEach(getPopularCategories(), id: \.self) { category in
                                CategoryCard(name: category)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
        }
    }
    
    // Function to simulate search
    private func searchPodcasts() {
        guard !searchText.isEmpty else { return }
        
        isSearching = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // In a real app, this would be an API call
            searchResults = getFeaturedPodcasts().filter {
                $0.title.lowercased().contains(searchText.lowercased()) ||
                $0.author.lowercased().contains(searchText.lowercased())
            }
            isSearching = false
        }
    }
    
    // Helper function to get featured podcasts
    private func getFeaturedPodcasts() -> [PodcastShow] {
        return [
            PodcastShow(
                id: "com.example.podcast1",
                title: "Tech Talk Weekly",
                author: "John Doe",
                description: "Weekly discussions on the latest tech news",
                imageUrl: nil,
                feedUrl: "https://example.com/feed1",
                category: "Technology",
                lastUpdated: Date(),
                isSubscribed: false
            ),
            PodcastShow(
                id: "com.example.podcast2",
                title: "Science Today",
                author: "Jane Smith",
                description: "Exploring the world of science",
                imageUrl: nil,
                feedUrl: "https://example.com/feed2",
                category: "Science",
                lastUpdated: Date(),
                isSubscribed: false
            ),
            PodcastShow(
                id: "com.example.podcast3",
                title: "True Crime Stories",
                author: "Crime Network",
                description: "Investigating famous crime cases",
                imageUrl: nil,
                feedUrl: "https://example.com/feed3",
                category: "True Crime",
                lastUpdated: Date(),
                isSubscribed: false
            )
        ]
    }
    
    // Helper function to get popular categories
    private func getPopularCategories() -> [String] {
        return ["Technology", "Comedy", "News", "True Crime", "Business", "Health", "Education", "Fiction"]
    }
}

// Featured podcast card component
struct FeaturedPodcastCard: View {
    let show: PodcastShow
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 150)
                    .cornerRadius(8)
                
                Image(systemName: "music.note")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50)
                    .foregroundColor(.white)
            }
            
            Text(show.title)
                .font(.headline)
                .lineLimit(1)
                .frame(width: 150, alignment: .leading)
            
            Text(show.author)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
                .frame(width: 150, alignment: .leading)
        }
        .onTapGesture {
            // Navigate to detail view (in a real app)
        }
    }
}

// Category card component
struct CategoryCard: View {
    let name: String
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.blue.opacity(0.2))
                .frame(height: 100)
                .cornerRadius(8)
            
            Text(name)
                .font(.headline)
                .foregroundColor(.primary)
        }
        .onTapGesture {
            // Navigate to category (in a real app)
        }
    }
}

// Search result row component
struct PodcastSearchRow: View {
    let show: PodcastShow
    @EnvironmentObject var podcastManager: PodcastManager
    
    var body: some View {
        HStack {
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                
                Image(systemName: "music.note")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading) {
                Text(show.title)
                    .font(.headline)
                
                Text(show.author)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                podcastManager.subscribeToShow(show)
            }) {
                Text("Subscribe")
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding(.vertical, 4)
    }
}

// Preview
struct DiscoverView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DiscoverView()
                .environmentObject(PodcastManager())
        }
    }
}
