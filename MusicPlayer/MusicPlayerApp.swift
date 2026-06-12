//
//  MusicPlayerApp.swift
//  MusicPlayer
//
//  Created by Juanjo on 08/06/2026.
//

import SwiftUI

@main
struct MusicPlayerApp: App {
    @State private var viewModel = PlayerViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
    }
}
