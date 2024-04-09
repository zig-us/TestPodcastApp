//
//  ContentView.swift
//  TestPodcastApp
//
//  Created by Ben Ziegler on 4/5/24.
//

import SwiftUI


struct ContentView: View {
    
    var body: some View {
        VStack {
            Image(systemName: "music.note")
                .imageScale(.large)
                .shadow(color: .blue, radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
            
            Text("Podcast App")
            
            
            
            
            
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
