//
//  PlayerViewModel.swift
//  MusicPlayer
//
//  Created by Juanjo on 08/06/2026.
//

import Foundation
import Observation
import AVFoundation
import AppKit
import UniformTypeIdentifiers

@MainActor
@Observable
class PlayerViewModel: NSObject, AVAudioPlayerDelegate {
    var songs: [Song] = []
    var currentSong: Song?
    var isPlaying: Bool = false
    var currentTime: TimeInterval = 0
    
    
    @ObservationIgnored
    private var audioPlayer: AVAudioPlayer?
    @ObservationIgnored
    private var timer: Timer?
    @ObservationIgnored
    private var isDragging = false
    
    var duration: TimeInterval {
        currentSong?.duration ?? 0
    }
    
    override init() {
        super.init()
        self.songs = [
            self.loadBundled("carnaval", title:"Carnaval"),
            self.loadBundled("escape_your_love", title: "Escape Your Love"),
            self.loadBundled("kontraa_water", title: "Kontraa - Water")
        ].compactMap { $0 } // elimina los nils
    }
    
    func loadSongs() {
        // Creamos y configuramos el panel
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.audio]
        // Ejecutamos el Modal
        guard panel.runModal() == .OK else { return }
        let urls = panel.urls // [URL] de lo que eligió el usuario
        let newSongs = urls.compactMap { makeSong(from: $0) }
        songs.append(contentsOf: newSongs)
        
    }
    
    func play(_ song: Song) {
        do {
            let player = try AVAudioPlayer(contentsOf: song.url)
            player.delegate = self
            player.prepareToPlay() // Precargamos el buffer
            audioPlayer = player
            player.play() // Empezamos con la reproducción
            // Actualizamos el estado observable del VM
            currentSong = song
            isPlaying = true
            startTimer()
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
        if isPlaying { startTimer() } else { stopTimer() }
        
    }
    
    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = time
    }
    
    func beginScrubbing() { isDragging = true}
    func endScrubbing() { isDragging = false}
    
    @discardableResult
    func next() -> Bool {
        guard let idx = currentIndex else { return false }
        let nextIdx = idx + 1
        if nextIdx >= songs.count { return false }
        play(songs[nextIdx])
        return true
    }
    func previous() {
        guard let idx = currentIndex else { return }
        let previousIdx = idx - 1
        if previousIdx < 0 { return }
        play(songs[previousIdx])
    }
    
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            if !self.next() {
                self.isPlaying = false
                self.currentTime = 0
                self.stopTimer()
            }
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                guard !self.isDragging else { return }
                self.currentTime = self.audioPlayer?.currentTime ?? 0
            }
        }
    }
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private var currentIndex: Int? {
        guard let currentSong else { return nil }
        return songs.firstIndex(where: { $0.id == currentSong.id })
    }
    
    private func loadBundled(_ name: String, title: String) -> Song? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else { return nil }
        return makeSong(from: url, title: title)
    }
    
    private func makeSong(from url: URL, title: String? = nil) -> Song? {
        let finalTitle = title ?? url.deletingPathExtension().lastPathComponent
        guard let probe = try? AVAudioPlayer(contentsOf: url) else {return nil}
        let song: Song = Song(title: finalTitle, url: url, duration: probe.duration, artist: nil, artwork: nil)
        return song
    }
}
