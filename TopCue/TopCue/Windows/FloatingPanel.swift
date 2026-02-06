//
//  FloatingPanel.swift
//  TopCue
//
//  Created by Sanz on 06/02/2026.
//

import AppKit

/// NSPanel completement transparent qui se fusionne avec le notch physique.
///
/// Inspiré de boring.notch / Atoll :
/// - Fond transparent, pas de barre de titre, pas d'ombre
/// - Niveau au-dessus de la menu bar (.mainMenu + 3)
/// - Immobile, collé au haut de l'ecran
/// - Visible sur tous les Spaces
final class FloatingPanel: NSPanel {

    init() {
        super.init(
            contentRect: .zero,
            styleMask: [
                .nonactivatingPanel,
                .borderless,
                .fullSizeContentView
            ],
            backing: .buffered,
            defer: false
        )

        // --- Fenetre flottante ---
        isFloatingPanel = true
        hidesOnDeactivate = false

        // --- Pas de barre de titre ---
        titleVisibility = .hidden
        titlebarAppearsTransparent = true

        // --- Visible partout ---
        collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary,
            .ignoresCycle
        ]

        isReleasedWhenClosed = false
        configureForNotchMode()
        configureInvisible()
    }

    // MARK: - Key handling

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    /// Cache la fenetre au lieu de la detruire
    override func close() {
        orderOut(nil)
    }

    // MARK: - Configuration

    /// Configure la fenetre pour le mode notch (transparent, immobile, sans ombre).
    func configureForNotchMode() {
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        isMovable = false
        isMovableByWindowBackground = false
        collectionBehavior.insert(.stationary)
    }

    /// Configure la fenetre pour le mode flottant (opaque, movable, ombre active).
    func configureForFloatingMode() {
        isOpaque = true
        backgroundColor = .black
        hasShadow = true
        isMovable = true
        isMovableByWindowBackground = true
        collectionBehavior.remove(.stationary)
    }

    /// Rend la fenetre invisible dans le partage d'ecran.
    func configureInvisible() {
        sharingType = .none
        level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.assistiveTechHighWindow)))
        collectionBehavior.insert(.ignoresCycle)
    }

    /// Rend la fenetre visible dans le partage d'ecran.
    func configureVisible() {
        sharingType = .readOnly
        level = .mainMenu + 3
    }
}
