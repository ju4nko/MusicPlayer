//
//  PlayerViewModelTests.swift
//  MusicPlayer
//
//  Created by Juanjo on 12/06/2026.
//

import Testing
import Foundation
import AVFoundation
@testable import MusicPlayer

final class TestBundleAnchor {}

@MainActor
struct PlayerViewModelTests {

    @Test func initialStateIsEmpty() async throws {
        let sut = PlayerViewModel(songs: [])
        #expect(sut.songs.isEmpty)
        #expect(sut.currentSong == nil)
        #expect(sut.isPlaying == false)
    }
    @Test func initialStateWithInjectedSongs() async throws {
        let cancion1 = Song.fake(title: "Cancion 1")
        let cancion2 = Song.fake(title: "Cancion 2")
        let sut = PlayerViewModel(songs:[cancion1, cancion2])
        #expect(sut.songs.count == 2)
        #expect(sut.currentSong == nil)
    }
    
    @Test func nextReturnsFalseWhenNoCurrentSong() async throws {
        let cancion1 = Song.fake(title: "Cancion 1")
        let cancion2 = Song.fake(title: "Cancion 2")
        let sut = PlayerViewModel(songs:[cancion1, cancion2])
        #expect(sut.currentSong == nil)
        #expect(sut.next() == false)
        
    }
    
    // Tests con audio
    @Test func playSetsCurrentSongAndIsPlaying() async throws {
        let song = loadTestSong(named: "carnaval")
        let sut = PlayerViewModel(songs: [song])
        
        sut.play(song)
        
        #expect(sut.currentSong?.id == song.id)
        #expect(sut.isPlaying == true)
        
        
    }
    
    @Test func togglePlayPausePausesAndResumes() async throws {
        let song = loadTestSong(named: "carnaval")
        let sut = PlayerViewModel(songs: [song])
    
        sut.play(song)
        sut.togglePlayPause()
        #expect(sut.isPlaying == false)
        sut.togglePlayPause()
        #expect(sut.isPlaying == true)
    }
    
    @Test func nextAdvancesToNextSong() async throws {
        let song1 = loadTestSong(named: "carnaval")
        let song2 = loadTestSong(named: "escape_your_love")
        let sut = PlayerViewModel(songs: [song1, song2])
        
        sut.play(song1)
        #expect(sut.next() == true)
        #expect(sut.currentSong?.id == song2.id)
    }
    
    @Test func nextReturnsFalseAtLast() async throws {
        let song1 = loadTestSong(named: "carnaval")
        let song2 = loadTestSong(named: "escape_your_love")
        let sut = PlayerViewModel(songs: [song1, song2])
        
        sut.play(song2)
        #expect(sut.next() == false)
        #expect(sut.currentSong?.id == song2.id)
    }
    
    @Test func previousGoesBack() async throws {
        let song1 = loadTestSong(named: "carnaval")
        let song2 = loadTestSong(named: "escape_your_love")
        let sut = PlayerViewModel(songs: [song1, song2])
        
        sut.play(song2)
        #expect(sut.previous() == true)
        #expect(sut.currentSong?.id == song1.id)
    }
    
    @Test func previousAtFirstDoesNothing() async throws {
        let song1 = loadTestSong(named: "carnaval")
        let song2 = loadTestSong(named: "escape_your_love")
        let sut = PlayerViewModel(songs: [song1, song2])
        
        sut.play(song1)
        #expect(sut.previous() == false)
        #expect(sut.currentSong?.id == song1.id)
    }
    
    @Test func seekUpdatesAudioPlayerTime() async throws {
        let song = loadTestSong(named: "carnaval")
        let sut = PlayerViewModel(songs: [song])
        
        sut.play(song)
        sut.seek(to: 50)
        
        #expect(sut.currentTime == 50)
    }
    
}

private extension Song {
    static func fake(title: String) -> Song {
        Song(
            title: title,
            url: URL(string: "file:///fake/\(title).mp3")!,
            duration: 100,
            artist: nil,
            artwork: nil
        )
    }
}

private func loadTestSong(named name: String, ext: String = "mp3") -> Song {
    let bundle = Bundle(for: TestBundleAnchor.self)
    let url = bundle.url(forResource: name, withExtension: ext)!
    let probe = try! AVAudioPlayer(contentsOf: url)
    return Song(title: name, url: url, duration: probe.duration, artist: nil, artwork: nil)
}
