//
//  PlayerViewModel.swift
//  MusicPlayer
//
//  Created by Juanjo on 08/06/2026.
//

import Foundation
import Observation
import AVFoundation

@MainActor
@Observable
class PlayerViewModel {
    var songs: [Song] = []
    var currentSong: Song?
    var isPlaying: Bool = false
    var currentTime: TimeInterval = 0
    
    @ObservationIgnored
    private var audioPlayer: AVAudioPlayer?
    
    func loadSongs() {}
    
    func play(_ song: Song) {
        do {
            let player = try AVAudioPlayer(contentsOf: song.url)
            player.prepareToPlay() // Precargamos el buffer
            audioPlayer = player
            player.play() // Empezamos con la reproducción
            // Actualizamos el estado observable del VM
            currentSong = song
            isPlaying = true
            
            
        } catch {
            print("Error cargando audio \(error)")
        }
    }
    
    func togglePlayPause() {
        guard let player = audioPlayer else { return }
        if player.isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying = player.isPlaying
    }
    func seek(to time: TimeInterval) {}
}
