//
//  PrompterView.swift
//  Notchie
//
//  Created by Sanz on 06/02/2026.
//

import SwiftUI

/// Vue du teleprompter qui s'integre visuellement dans le notch MacBook.
///
/// Architecture :
/// - La fenetre (FloatingPanel) est 100% transparente
/// - Le contenu est un ZStack noir clippe avec NotchShape
/// - Le noir du contenu fusionne avec le noir du notch physique
/// - Effet : le texte semble "sortir" du notch
struct PrompterView: View {

    @Bindable var state: PrompterState

    @State private var scrollController: ScrollController?
    @State private var isHovering = false

    @AppStorage("prompterFontSize") private var fontSize: Double = Constants.Prompter.defaultFontSize
    @AppStorage("textColorHex") private var textColorHex: String = "#FFFFFF"

    var body: some View {
        // Fond completement transparent (laisse voir le bureau)
        Color.clear
            .overlay(alignment: .top) {
                notchContent
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

    // MARK: - Notch Content

    /// Le contenu noir qui fusionne avec le notch physique
    private var notchContent: some View {
        ZStack(alignment: .top) {
            // Texte defilant
            if let script = state.currentScript {
                GeometryReader { geometry in
                    ScrollView(.vertical, showsIndicators: false) {
                        Text(script.content)
                            .font(.system(size: fontSize, design: .monospaced))
                            .foregroundStyle(textColor)
                            .lineSpacing(Constants.Prompter.lineSpacing)
                            .padding(.top, Constants.Notch.closedHeight + 8)
                            .padding(.horizontal, Constants.Notch.horizontalPadding + Constants.Notch.topCornerRadius)
                            .padding(.bottom, geometry.size.height * 0.6)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .offset(y: -state.scrollOffset)
                    }
                    .scrollDisabled(true)
                }
            } else {
                VStack {
                    Spacer()
                    Text("Aucun script selectionne")
                        .font(.title2)
                        .foregroundStyle(.gray)
                    Spacer()
                }
            }

            // Controles au hover
            if isHovering || !state.isPlaying {
                controlsOverlay
            }
        }
        .frame(
            width: Constants.Notch.openWidth,
            height: Constants.Notch.openHeight
        )
        .background(.black)
        .clipShape(NotchShape())
        .shadow(
            color: .black.opacity(isHovering ? 0.6 : 0.3),
            radius: 10
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
    }

    // MARK: - Controls Overlay

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
            .padding(.bottom, Constants.Notch.bottomPadding + 8)
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
