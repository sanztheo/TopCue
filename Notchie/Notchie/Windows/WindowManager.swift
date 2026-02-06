//
//  WindowManager.swift
//  Notchie
//
//  Created by Sanz on 06/02/2026.
//

import AppKit
import SwiftUI

/// Gere la creation et l'affichage de la fenetre flottante du prompteur.
/// Heberge la PrompterView SwiftUI dans un NSPanel via NSHostingView.
@Observable
final class WindowManager {

    /// La fenetre flottante du prompteur
    private var panel: FloatingPanel?

    /// Etat partage du prompteur
    let prompterState = PrompterState()

    /// La fenetre est-elle actuellement affichee
    var isPanelVisible: Bool {
        panel?.isVisible ?? false
    }

    // MARK: - Actions

    /// Ouvre la fenetre du prompteur avec le script donne
    func showPrompter(script: Script) {
        prompterState.currentScript = script
        prompterState.scrollOffset = 0
        prompterState.playbackState = .idle

        if panel == nil {
            createPanel()
        }

        guard let panel else { return }

        // Centrer la fenetre sur l'ecran principal
        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            let panelSize = panel.frame.size
            let origin = NSPoint(
                x: screenFrame.midX - panelSize.width / 2,
                y: screenFrame.midY - panelSize.height / 2
            )
            panel.setFrameOrigin(origin)
        }

        panel.makeKeyAndOrderFront(nil)
        prompterState.isWindowVisible = true
    }

    /// Ferme la fenetre du prompteur
    func hidePrompter() {
        prompterState.stop()
        prompterState.isWindowVisible = false
        panel?.orderOut(nil)
    }

    // MARK: - Private

    private func createPanel() {
        let panel = FloatingPanel()

        let prompterView = PrompterView(state: prompterState)
        let hostingView = NSHostingView(rootView: prompterView)
        panel.contentView = hostingView

        self.panel = panel
    }
}
