//
//  ContentView.swift
//  TestPodcastApp
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    
    @State private var buttonPlayTitle = "Play"
    @State private var speed = 100.0
    @State private var isEditing = false
    @EnvironmentObject var preferences: UserPreferences
    @EnvironmentObject var podcastManager: PodcastManager
    @State private var showSettings = false
    @State private var showCompleteConfirmation = false
    @State private var audioPlayer: AVAudioPlayer?
    
    enum Speed: String, CaseIterable, Identifiable {
        case half, normal, onepointfive, two
        var id: Self { self }
    }
    @State private var selectedSpeed: Speed = .normal
    
    var body: some View {
        VStack {
            Image(systemName: "music.note")
                .padding(.bottom)
                .imageScale(.large)
                .shadow(color: .blue, radius: 10)
            
            if let currentEpisode = podcastManager.currentEpisode {
                Text(currentEpisode.title)
                    .font(.headline)
                    .padding(.top)
            } else {
                Text("No podcast available")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.top)
            }
            
            // Main playback controls
            HStack(spacing: 20) {
                Button(action: play) {
                    Label(buttonPlayTitle, systemImage: buttonPlayTitle == "Play" ? "play.fill" : "pause.fill")
                }
                .buttonStyle(.borderedProminent)
                
                Button(action: skipForward) {
                    Label("Skip \(UserPreferences.formatTime(preferences.skipForwardTime))", 
                          systemImage: "goforward")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.vertical)
            
            // Additional controls
            HStack(spacing: 20) {
                Button(action: skipToEnd) {
                    Label("Skip to End", systemImage: "forward.end.fill")
                }
                .buttonStyle(.bordered)
                .tint(.orange)
                
                Button(action: {
                    showCompleteConfirmation = true
                }) {
                    Label("Mark Complete", systemImage: "checkmark.circle.fill")
                }
                .buttonStyle(.bordered)
                .tint(.green)
            }
            
            Button(action: {
                showSettings = true
            }) {
                Label("Settings", systemImage: "gear")
            }
            .padding(.top, 8)
            
            List {
                Picker("Speed", selection: $selectedSpeed) {
                    Text("Half").tag(Speed.half)
                    Text("Normal").tag(Speed.normal)
                    Text("One and a Half").tag(Speed.onepointfive)
                    Text("Two").tag(Speed.two)
                }.onReceive([self.selectedSpeed].publisher.first()) { value in
                    self.changeRate()
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .confirmationDialog(
            "Mark podcast as complete?",
            isPresented: $showCompleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Mark Complete & Delete", role: .destructive) {
                markAsComplete()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will mark the podcast as complete and remove it from your library.")
        }
    }
    
    func changeRate() {
        guard let player = audioPlayer else {
            return
        }
            if selectedSpeed == .half {
                player.rate = 0.5
            } else if selectedSpeed == .normal {
                player.rate = 1.0
            } else if selectedSpeed == .onepointfive {
                player.rate = 1.5
            } else if selectedSpeed == .two {
                player.rate = 2.0
            }
    }
    
    func skipToEnd() {
        guard let player = audioPlayer, player.isPlaying else {
            // Start playing if not currently playing
            play()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.podcastManager.skipToEnd(audioPlayer: self.audioPlayer)
            }
            return
        }
        
        podcastManager.skipToEnd(audioPlayer: audioPlayer)
    }
    
    func markAsComplete() {
        // Stop playback if active
        if let player = audioPlayer, player.isPlaying {
            player.stop()
            buttonPlayTitle = "Play"
        }
        
        // Mark the podcast as complete
        if let currentEpisode = podcastManager.currentEpisode {
            podcastManager.markAsComplete(podcast: currentEpisode, preferences: preferences)
            
            // Provide feedback
            #if os(iOS)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            #endif
        }
    }
    
    func skipForward() {
        guard let player = audioPlayer, player.isPlaying else {
            // Can't skip if not playing
            return
        }
        
        let currentTime = player.currentTime
        let duration = player.duration
        
        // Calculate new time after skipping forward
        let newTime = currentTime + preferences.skipForwardTime
        
        // Make sure we don't skip past the end
        if newTime < duration {
            player.currentTime = newTime
        } else {
            // If skipping would go past the end, go to end minus a tiny bit
            player.currentTime = duration - 0.1
        }
    }
    
    func play() {
        if let player = audioPlayer, player.isPlaying {
            player.pause()
            buttonPlayTitle = "Play"
            return
        }
        
        let url = Bundle.main.url(forResource: "example", withExtension: "mp3")
        
        guard url != nil else {
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url!)
            audioPlayer?.enableRate = true
            audioPlayer?.prepareToPlay()
            
            #if os(iOS)
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay])
                print("Playback OK")
                try AVAudioSession.sharedInstance().setActive(true)
                print("Session is Active")
            } catch {
                print(error)
            }
            #endif
            
            audioPlayer?.rate = 1.0
            audioPlayer?.play()
            
            buttonPlayTitle = "Pause"
        } catch {
            print("\(error)")
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(UserPreferences())
        .environmentObject(PodcastManager())
}
