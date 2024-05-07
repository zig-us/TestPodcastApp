//
//  ContentView.swift
//  TestPodcastApp
//
//  Created by Ben Ziegler on 4/5/24.
//

import SwiftUI
import AVFoundation
var audioPlayer: AVAudioPlayer!

struct ContentView: View {
    
    @State var buttonPlayTitle = "Play"
    @State private var speed = 100.0
    @State private var isEditing = false
    
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
                .shadow(color: .blue, radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
            
            Text("test")
                .padding(.top)
            
            Button(action: play) {
                Label(buttonPlayTitle, systemImage: "arrow.up")
            }
            .buttonStyle(.borderedProminent)
            
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
        
    }
    func changeRate() {
        print("this worked")
        guard audioPlayer != nil else {
            return
        }
            if selectedSpeed == .half {
                
                audioPlayer.rate = 0.5
            } else if selectedSpeed == .normal {
                audioPlayer.rate = 1.0
            } else if selectedSpeed == .onepointfive {
                audioPlayer.rate = 1.5
            } else if selectedSpeed == .two {
                audioPlayer.rate = 2.0
            }
        
        
        
    }
    
    func play() {
        
        if let audioPlayer = audioPlayer, audioPlayer.isPlaying {
            audioPlayer.pause()
            buttonPlayTitle = "Play"
            return;
        }
        let url = Bundle.main.url(forResource: "example", withExtension: "mp3")
        
        guard url != nil else {
            return;
        }
        
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url!)
            audioPlayer.enableRate = true
            audioPlayer.prepareToPlay()
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay])
                print("Playback OK")
                try AVAudioSession.sharedInstance().setActive(true)
                print("Session is Active")
            } catch {
                print(error)
            }
            audioPlayer.rate = 1.0
            audioPlayer?.play()
            
            buttonPlayTitle = "Pause"
        } catch {
            print("\(error)")
        }
        
        
    }

}

#Preview {
    ContentView()
}
