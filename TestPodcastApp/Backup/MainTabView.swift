//
//  MainTabView.swift
//  TestPodcastApp
//

import SwiftUI
import AVFoundation

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Content View tab
            Text("Now Playing")
                .tabItem {
                    Label("Now Playing", systemImage: "play.circle")
                }
                .tag(0)
            
            // Settings tab
            Text("Settings")
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(1)
        }
    }
}

#Preview {
    MainTabView()
}
