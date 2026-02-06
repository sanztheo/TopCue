//
//  PrompterView.swift
//  Notchie
//
//  Created by Sanz on 06/02/2026.
//

import SwiftUI

/// Vue du teleprompter : affiche le texte en defilement automatique.
/// Fond noir, texte blanc monospace, controles de lecture.
struct PrompterView: View {

    @Bindable var state: PrompterState

    @State private var scrollController: ScrollController?
    @State private var isHovering = false

    @AppStorage("prompterFontSize") private var fontSize: Double = Constants.Prompter.defaultFontSize
    @AppStorage("textColorHex") private var textColorHex: String = "#FFFFFF"

    var body: some View {
        ZStack {
            // Fond noir
            Constants.Colors.prompterBackground
                .ignoresSafeArea()

            if let script = state.currentScript {
                // Texte defilant
                GeometryReader { geometry in
                    ScrollView(.vertical, showsIndicators: false) {
                        Text(script.content)
                            .font(.system(size: fontSize, design: .monospaced))
                            .foregroundStyle(textColor)
                            .lineSpacing(Constants.Prompter.lineSpacing)
                            .padding(Constants.Prompter.textPadding)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            // Padding en bas pour pouvoir scroller au-dela du dernier texte
                            .padding(.bottom, geometry.size.height * 0.8)
                            .offset(y: -state.scrollOffset)
                    }
                    .scrollDisabled(true) // On gere le scroll nous-memes
                }

                // Overlay de controles au hover
                if isHovering || !state.isPlaying {
                    controlsOverlay
                }
            } else {
                Text("Aucun script selectionne")
                    .font(.title2)
                    .foregroundStyle(.gray)
            }
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
            // Pause au hover
            if hovering && state.isPlaying {
                state.pause()
            } else if !hovering && state.isPaused {
                state.play()
            }
        }
        .onAppear {
            let controller = ScrollController(state: state)
            scrollController = controller
            controller.start()
        }
        .onDisappear {
            scrollController?.stop()
        }
    }

    // MARK: - Subviews

    private var controlsOverlay: some View {
        VStack {
            Spacer()
            HStack(spacing: 20) {
                // Vitesse -
                Button {
                    state.decreaseSpeed()
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                }
                .buttonStyle(.plain)

                // Play / Pause
                Button {
                    state.togglePlayPause()
                } label: {
                    Image(systemName: state.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.largeTitle)
                }
                .buttonStyle(.plain)

                // Vitesse +
                Button {
                    state.increaseSpeed()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
                .buttonStyle(.plain)

                // Indicateur de vitesse
                Text(state.speedMultiplier)
                    .font(.caption)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            .foregroundStyle(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(.black.opacity(0.7))
            .clipShape(Capsule())
            .padding(.bottom, 16)
        }
        .transition(.opacity)
    }

    // MARK: - Helpers

    private var textColor: Color {
        Color(hex: textColorHex) ?? Constants.Colors.defaultTextColor
    }
}

// MARK: - Color hex extension

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        guard hexSanitized.count == 6,
              let rgb = UInt64(hexSanitized, radix: 16) else {
            return nil
        }

        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255.0,
            green: Double((rgb >> 8) & 0xFF) / 255.0,
            blue: Double(rgb & 0xFF) / 255.0
        )
    }
}
