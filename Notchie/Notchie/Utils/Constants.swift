//
//  Constants.swift
//  Notchie
//
//  Created by Sanz on 06/02/2026.
//

import Foundation
import SwiftUI

enum Constants {

    // MARK: - Prompter

    enum Prompter {
        /// Vitesse de defilement par defaut (points/seconde)
        static let defaultSpeed: CGFloat = 50

        /// Vitesse minimum (0.25x)
        static let minSpeed: CGFloat = 12.5

        /// Vitesse maximum (4x)
        static let maxSpeed: CGFloat = 200

        /// Increment de vitesse
        static let speedStep: CGFloat = 12.5

        /// Taille de police par defaut
        static let defaultFontSize: CGFloat = 24

        /// Taille de police minimum
        static let minFontSize: CGFloat = 14

        /// Taille de police maximum
        static let maxFontSize: CGFloat = 72

        /// Espacement entre les lignes
        static let lineSpacing: CGFloat = 12

        /// Padding du texte
        static let textPadding: CGFloat = 40

        /// Framerate du timer de defilement
        static let frameRate: TimeInterval = 1.0 / 60.0
    }

    // MARK: - Notch

    enum Notch {
        /// Hauteur du notch physique (~32pt)
        static let physicalHeight: CGFloat = 32

        /// Largeur du prompteur (compact, juste un peu plus large que le notch)
        static let openWidth: CGFloat = 310

        /// Hauteur totale : notch (~32pt) + zone texte (~60pt) = ~92pt
        static let openHeight: CGFloat = 92

        /// Rayon des coins du haut (petits, coins du notch)
        static let topCornerRadius: CGFloat = 6

        /// Rayon des coins du bas (effet pilule)
        static let bottomCornerRadius: CGFloat = 12

        /// Padding horizontal interieur
        static let horizontalPadding: CGFloat = 10

        /// Padding bas interieur
        static let bottomPadding: CGFloat = 8
    }

    // MARK: - Window

    enum Window {
        /// Taille minimum de la fenetre prompteur
        static let minSize = NSSize(width: 200, height: 100)

        /// Taille par defaut de la fenetre prompteur
        static let defaultSize = NSSize(width: 600, height: 300)

        /// Taille par defaut de la fenetre editeur
        static let editorSize = NSSize(width: 800, height: 600)
    }

    // MARK: - Colors

    enum Colors {
        /// Couleur de texte par defaut
        static let defaultTextColor: Color = .white

        /// Couleur de fond du prompteur
        static let prompterBackground: Color = .black

        /// Presets de couleurs
        static let presets: [(name: String, color: Color)] = [
            ("White", .white),
            ("Green", Color(red: 0, green: 1, blue: 0.255)),   // #00FF41 Matrix green
            ("Yellow", .yellow),
            ("Cyan", .cyan),
            ("Pink", Color(red: 1, green: 0.412, blue: 0.706)), // #FF69B4
        ]
    }

    // MARK: - Reading Speed

    enum Reading {
        /// Mots par minute pour l'estimation de duree
        static let wordsPerMinute: Double = 150
    }
}
