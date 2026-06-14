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
    
    init(songs: [Song]) {
        super.init()
        self.songs = songs
    }
    
    override convenience init() {
        self.init(songs: [])
        Task {
            self.songs = await loadMusicFolder()
        }
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
        self.currentTime = time
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
    @discardableResult
    func previous() -> Bool {
        guard let idx = currentIndex else { return false }
        let previousIdx = idx - 1
        if previousIdx < 0 { return false }
        play(songs[previousIdx])
        return true
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
    
    private func loadBundled(_ name: String, title: String) async -> Song? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else { return nil }
        return await makeSong(from: url, title: title)
    }
    
    private func makeSong(from url: URL, title: String? = nil) async -> Song? {
        guard let probe = try? AVAudioPlayer(contentsOf: url) else { return nil }
        let metadata = await loadMetadata(from: url)   // ← await
        return Song(
            title: title ?? metadata.title ?? url.deletingPathExtension().lastPathComponent,
            url: url,
            duration: probe.duration,
            artist: metadata.artist,
            artwork: metadata.artwork
        )
    }
    
    private func loadMusicFolder() async -> [Song] {
        let fm = FileManager.default
        guard let musicURL = fm.urls(for: .musicDirectory, in: .userDomainMask).first else {
            return []
        }
        let resolvedURL = musicURL.resolvingSymlinksInPath()
        let files = (try? fm.contentsOfDirectory(at: resolvedURL, includingPropertiesForKeys: nil)) ?? []
        let mp3s = files.filter { $0.pathExtension.lowercased() == "mp3" }
        var songs: [Song] = []
        for url in mp3s {
            if let song = await makeSong(from: url) {
                songs.append(song)
            }
        }
        return songs
    }
    
    private func loadMetadata(from url: URL) async ->(title:String?, artist:String?, artwork:Data?) {
        let asset = AVURLAsset(url: url)
        guard let items = try? await asset.load(.commonMetadata) else {
            return (nil, nil, nil)
        }
        
        var title: String?
        var artist: String?
        var artwork: Data?
        
        for item in items {
            switch item.commonKey {
            case .commonKeyTitle:
                title = try? await item.load(.stringValue)
            case .commonKeyArtist:
                artist = try? await item.load(.stringValue)
            case .commonKeyArtwork:
                artwork = try? await item.load(.dataValue)
            default:
                break
            }
        }
        
        return (title, artist, artwork)
    }
}
