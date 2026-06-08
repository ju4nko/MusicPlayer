//
//  ContentView.swift
//  MusicPlayer
//
//  Created by Juanjo on 08/06/2026.
//

import SwiftUI

struct ContentView: View {
    let viewModel: PlayerViewModel
    var body: some View {
        VStack {
            Text(viewModel.currentSong?.title ?? "Sin canción")
            HStack {
                Button("Play carnaval") {
                    guard let url = Bundle.main.url(forResource:"carnaval", withExtension: ".mp3") else { return }
                    let song: Song = Song(title: "Carnaval", url: url, duration: 0, artist: nil, artwork: nil)
                    viewModel.play(song)
                }
                Button(viewModel.isPlaying ? "Pause" : "Play" ) {
                    viewModel.togglePlayPause()
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView(viewModel: PlayerViewModel())
}
