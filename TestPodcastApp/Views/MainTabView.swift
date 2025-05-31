//
//  MainTabView.swift
//  TestPodcastApp
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var podcastManager: PodcastManager
    @EnvironmentObject var preferences: UserPreferences
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Now Playing tab
            ContentView()
                .tabItem {
                    Label("Now Playing", systemImage: "play.circle")
                }
                .tag(0)
            
            // Library tab
            PodcastLibraryView()
                .tabItem {
                    Label("Library", systemImage: "books.vertical")
                }
                .tag(1)
            
            // Discover tab
            DiscoverView()
                .tabItem {
                    Label("Discover", systemImage: "magnifyingglass")
                }
                .tag(2)
            
            // Downloads tab
            DownloadsView()
                .tabItem {
                    Label("Downloads", systemImage: "arrow.down.circle")
                }
                .tag(3)
            
            // Settings tab
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(4)
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(PodcastManager())
        .environmentObject(UserPreferences())
}
