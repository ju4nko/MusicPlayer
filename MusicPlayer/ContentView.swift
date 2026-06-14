//
//  ContentView.swift
//  MusicPlayer
//
//  Created by Juanjo on 08/06/2026.
//

import SwiftUI
import AppKit

struct ContentView: View {
    
    @Bindable var viewModel: PlayerViewModel
    
    var body: some View {
        VStack {
            HStack(spacing: 12) {
                // Carátula grande (o placeholder)
                if let data = viewModel.currentSong?.artwork, let nsImage = NSImage(data: data) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .frame(width: 64, height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.gray.opacity(0.2))
                        .frame(width: 64, height: 64)
                        .overlay(
                            Image(systemName: "music.note")
                                .font(.title)
                                .foregroundStyle(.secondary)
                        )
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.currentSong?.title ?? "Sin canción")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    if let artist = viewModel.currentSong?.artist {
                        Text(artist)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                Spacer()
            }
            .padding()
            .glassEffect(.regular, in: .rect(cornerRadius: 20))
            
            List(viewModel.songs) { song in
                let esActual = song.id == viewModel.currentSong?.id
                HStack {
                    // Carátula o placeholder
                    if let data = song.artwork, let nsImage = NSImage(data: data) {
                        Image(nsImage: nsImage)
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    } else {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.gray.opacity(0.2))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "music.note")
                                    .foregroundStyle(.secondary)
                            )
                    }
            
                    // Título + artista
                    VStack(alignment: .leading) {
                        Text(song.title)
                            .fontWeight(esActual ? .bold : .regular)
                        if let artist = song.artist {
                            Text(artist)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundStyle(.tint)
                        .opacity(esActual ? 1 : 0)
                    
                }.contentShape(Rectangle())
                .onTapGesture {
                    viewModel.play(song)
                }
            }
            .listStyle(.inset)
            .scrollContentBackground(.hidden)
            .padding(.vertical, 4)
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
            
            GlassEffectContainer(spacing: 16) {
                HStack(spacing: 16) {
                    Button("Previous", systemImage: "backward.fill") {
                        viewModel.previous()
                    }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.glass)
                    
                    Button(viewModel.isPlaying ? "Pause" : "Play",
                           systemImage: viewModel.isPlaying ? "pause.fill" : "play.fill") {
                        viewModel.togglePlayPause()
                    }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.glassProminent)        // ← el central destaca más
                    
                    Button("Next", systemImage: "forward.fill") {
                        viewModel.next()
                    }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.glass)
                }
                .font(.title2)
                .padding(.vertical, 4)
            }
        }
        .padding(20)
        .background {
            if let data = viewModel.currentSong?.artwork,
               let nsImage = NSImage(data: data) {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFill()
                    .blur(radius: 60)
                    .opacity(0.6)
                    .ignoresSafeArea()
            } else {
                LinearGradient(
                    colors: [.indigo.opacity(0.4), .purple.opacity(0.25)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }
        }
    }
}

#Preview {
    ContentView(viewModel: PlayerViewModel())
}
