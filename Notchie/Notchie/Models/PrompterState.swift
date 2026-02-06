//
//  PrompterState.swift
//  Notchie
//
//  Created by Sanz on 06/02/2026.
//

import Foundation
import SwiftUI

/// Etats possibles du prompteur
enum PlaybackState {
    case idle       // Pas de presentation en cours
    case playing    // Texte en defilement
    case paused     // Pause manuelle
}

/// Etat observable de la presentation en cours
@Observable
final class PrompterState {
    /// Script actuellement presente
    var currentScript: Script?

    /// Etat de lecture
    var playbackState: PlaybackState = .idle

    /// Offset de defilement actuel (en points)
    var scrollOffset: CGFloat = 0

    /// Vitesse de defilement (points par seconde)
    var speed: CGFloat = 50

    /// La fenetre du prompteur est-elle visible
    var isWindowVisible: Bool = false

    // MARK: - Computed

    var isPlaying: Bool {
        playbackState == .playing
    }

    var isPaused: Bool {
        playbackState == .paused
    }

    // MARK: - Actions

    func play() {
        playbackState = .playing
    }

    func pause() {
        playbackState = .paused
    }

    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    func stop() {
        playbackState = .idle
        scrollOffset = 0
    }

    func increaseSpeed() {
        speed = min(speed + 12.5, 200) // Max 4x (200 pts/s)
    }

    func decreaseSpeed() {
        speed = max(speed - 12.5, 12.5) // Min 0.25x (12.5 pts/s)
    }

    /// Multiplicateur de vitesse affichable (ex: "1.0x")
    var speedMultiplier: String {
        String(format: "%.1fx", speed / 50.0)
    }
}
