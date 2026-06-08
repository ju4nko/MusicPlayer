//
//  PlayerViewModel.swift
//  MusicPlayer
//
//  Created by Juanjo on 08/06/2026.
//

import Foundation
import Observation

@MainActor
@Observable
class PlayerViewModel {
    var songs: [Song] = []
    var currentSong: Song?
    var isPlaying: Bool = false
    var currentTime: TimeInterval = 0
    
    func loadSongs() {}
    func play(_ song: Song) {}
    func togglePlayPause() {}
    func seek(to time: TimeInterval) {}
}


                      
                      
