//
//  FloatingPanel.swift
//  Notchie
//
//  Created by Sanz on 06/02/2026.
//

import AppKit

/// NSPanel subclass pour la fenetre flottante du prompteur.
/// - Non-activating : ne vole pas le focus
/// - Floating : reste au-dessus des autres fenetres
/// - FullScreenAuxiliary : reste visible au-dessus des apps fullscreen
final class FloatingPanel: NSPanel {

    init(contentRect: NSRect = NSRect(
        x: 0, y: 0,
        width: Constants.Window.defaultSize.width,
        height: Constants.Window.defaultSize.height
    )) {
        super.init(
            contentRect: contentRect,
            styleMask: [
                .nonactivatingPanel,
                .titled,
                .resizable,
                .closable,
                .fullSizeContentView
            ],
            backing: .buffered,
            defer: false
        )

        // --- Comportement flottant ---
        isFloatingPanel = true
        level = .floating
        hidesOnDeactivate = false
        isMovableByWindowBackground = true
        titleVisibility = .hidden
        titlebarAppearsTransparent = true

        // --- Comportement Spaces ---
        collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary
        ]

        // --- Apparence ---
        backgroundColor = .black
        isOpaque = false
        hasShadow = true

        // --- Taille ---
        minSize = Constants.Window.minSize

        // --- Coins arrondis ---
        if let contentView = contentView {
            contentView.wantsLayer = true
            contentView.layer?.cornerRadius = 12
            contentView.layer?.masksToBounds = true
        }
    }

    // MARK: - Key handling

    /// Permet de recevoir les evenements clavier meme en non-activating
    override var canBecomeKey: Bool { true }

    /// Fermer la fenetre au lieu de la detruire
    override func close() {
        orderOut(nil)
    }
}
