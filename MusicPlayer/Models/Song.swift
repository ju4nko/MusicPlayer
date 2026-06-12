//
//  Song.swift
//  MusicPlayer
//
//  Created by Juanjo on 08/06/2026.
//
import Foundation

struct Song: Identifiable, Hashable {
    
    let id: UUID = UUID()
    let title: String
    let url: URL
    let duration: TimeInterval
    let artist: String?
    let artwork: URL?
    
    
    static func bundled(_ resource: String, title: String, artist: String? = nil) -> Song? {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "mp3") else { return nil }
        let song: Song = Song(title: title, url: url, duration: 0, artist: artist, artwork: nil)
        return song
    }
    
}

