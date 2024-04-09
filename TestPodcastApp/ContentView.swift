//
//  ContentView.swift
//  TestPodcastApp
//
//  Created by Ben Ziegler on 4/5/24.
//

import SwiftUI
import AVFoundation

var playAudio: AVAudioPlayer?

struct ContentView: View {
    
    
    var body: some View {
        VStack {
            Image(systemName: "music.note")
                .padding(.bottom)
                .imageScale(.large)
                .shadow(color: .blue, radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
            
            Text("test")
                .padding(.top)
            
            Button(action: play) {
                Label("Sign In", systemImage: "arrow.up")
            }
            .buttonStyle(.borderedProminent)
        }
        
    }
    
    
}
func play() {
    let path = Bundle.main.path(forResource: "example.mp3", ofType:nil)!
    let url = URL(fileURLWithPath: path)
    do {
        playAudio = try AVAudioPlayer(contentsOf: url)
    } catch {
        
        
    }
}

#Preview {
    ContentView()
}
