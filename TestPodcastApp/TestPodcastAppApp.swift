//
//  TestPodcastAppApp.swift
//  TestPodcastApp
//
//  Created by Ben Ziegler on 4/5/24.
//

import SwiftUI

@main
struct TestPodcastAppApp: App {
    @StateObject private var preferences = UserPreferences()
    @StateObject private var podcastManager = PodcastManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(preferences)
                .environmentObject(podcastManager)
        }
    }
}


#Preview {
    ContentView()
        .environmentObject(UserPreferences())
        .environmentObject(PodcastManager())
}

