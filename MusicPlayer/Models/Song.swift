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
    let artwork: Data?
    
}

