//
//  TestPodcastAppApp.swift
//  TestPodcastApp
//
//  Created by Ben Ziegler on 4/5/24.
//

import SwiftUI
import AVFoundation

@main
struct TestPodcastAppApp: App {
    // Create our main model objects as StateObjects so they persist for the app's lifetime
    @StateObject private var preferences = UserPreferences()
    @StateObject private var podcastManager = PodcastManager()
    
    init() {
        // Initialize any app-wide settings or configurations here
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(preferences)
                .environmentObject(podcastManager)
        }
    }
}

