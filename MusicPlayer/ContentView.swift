//
//  ContentView.swift
//  MusicPlayer
//
//  Created by Juanjo on 08/06/2026.
//

import SwiftUI

struct ContentView: View {
    
    @Bindable var viewModel: PlayerViewModel
    
    var body: some View {
        VStack {
            Button("Abrir...", systemImage: "folder"){
                viewModel.loadSongs()
            }.labelStyle(.titleAndIcon)
            Text(viewModel.currentSong?.title ?? "Sin canción")
            List(viewModel.songs) { song in
                let esActual = song.id == viewModel.currentSong?.id
                HStack {
                    Text(song.title)
                        .fontWeight(esActual ? .bold : .regular)
                    Spacer()
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundStyle(.tint)
                        .opacity(esActual ? 1 : 0)
                    
                }.contentShape(Rectangle())
                .onTapGesture {
                    viewModel.play(song)
                }
            }
            VStack(spacing: 4) {
                if viewModel.duration > 0 {
                    Slider(value: $viewModel.currentTime, in: 0...viewModel.duration) { editing in
                        if editing {
                            viewModel.beginScrubbing()
                        } else {
                            viewModel.endScrubbing()
                            viewModel.seek(to: viewModel.currentTime)
                        }
                        
                    }
                    HStack {
                        Text(Duration.seconds(viewModel.currentTime).formatted(.time(pattern: .minuteSecond)))
                        Spacer()
                        Text(Duration.seconds(viewModel.duration).formatted(.time(pattern: .minuteSecond)))
                    }
                }
            }.font(.caption)
            
            HStack {
                Button("Previous" , systemImage: "backward.fill") {
                    viewModel.previous()
                }.labelStyle(.iconOnly)
                Button(viewModel.isPlaying ? "Pause" : "Play" , systemImage: viewModel.isPlaying ? "pause.fill" : "play.fill") {
                    viewModel.togglePlayPause()
                }.labelStyle(.iconOnly)
                Button("Next", systemImage: "forward.fill") {
                    viewModel.next()
                }.labelStyle(.iconOnly)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView(viewModel: PlayerViewModel())
}
