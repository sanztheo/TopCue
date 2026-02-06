//
//  NotionSettingsPopover.swift
//  TopCue
//
//  Created by Sanz on 06/02/2026.
//

import SwiftUI

/// Panneau de reglages compact inspire du style Notion.
struct NotionSettingsPopover: View {

    // MARK: - Properties

    @Bindable var state: PrompterState
    @Bindable var voiceDetector: VoiceDetector

    let onToggleMode: () -> Void
    let onToggleInvisibility: () -> Void
    let onToggleVoiceMode: () -> Void

    @AppStorage("prompterFontSize") private var fontSize: Double = Constants.Prompter.defaultFontSize
    @AppStorage("textColorHex") private var textColorHex: String = "#FFFFFF"

    private let presetColors: [(name: String, hex: String)] = [
        ("White", "#FFFFFF"),
        ("Green", "#00FF41"),
        ("Yellow", "#FFFF00"),
        ("Cyan", "#00FFFF"),
        ("Pink", "#FF69B4"),
    ]

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header
            previewSection
            displaySection
            voiceSection
            sharingSection
        }
        .padding(14)
        .frame(width: 340)
        .background(NotionTheme.sidebar)
    }

    // MARK: - Sections

    private var header: some View {
        HStack {
            Text("Settings")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(NotionTheme.text)
            Spacer()
            Image(systemName: "gearshape")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(NotionTheme.secondaryText)
        }
    }

    private var displaySection: some View {
        sectionCard(title: "Display") {
            modeButtons

            settingRow(label: "Taille du texte") {
                Text("\(Int(fontSize)) pt")
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundStyle(NotionTheme.secondaryText)
            }

            Slider(value: $fontSize, in: 14...72, step: 1)
                .tint(NotionTheme.accent)

            settingRow(label: "Couleur du texte") {
                Circle()
                    .fill(color(forHex: textColorHex))
                    .frame(width: 10, height: 10)
            }

            colorPresets
        }
    }

    private var previewSection: some View {
        sectionCard(title: "Apercu") {
            previewCanvas

            HStack(spacing: 8) {
                Text("Mise a jour en direct")
                    .font(.system(size: 10))
                    .foregroundStyle(NotionTheme.secondaryText)

                Spacer()

                Text(state.isFloatingMode ? "Mode Floating" : "Mode Notch")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(NotionTheme.tertiaryText)
            }
        }
    }

    private var voiceSection: some View {
        sectionCard(title: "Voice") {
            Toggle(isOn: voiceModeBinding) {
                Text("Mode voix")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(NotionTheme.text)
            }
            .toggleStyle(.switch)

            settingRow(label: "Sensibilite micro") {
                Text(sensitivityLabel)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(NotionTheme.secondaryText)
            }

            Slider(value: $voiceDetector.sensitivity, in: 0...1, step: 0.01)
                .tint(NotionTheme.accent)

            Text("Tres sensible \u{2190} \u{2192} Peu sensible")
                .font(.system(size: 10))
                .foregroundStyle(NotionTheme.tertiaryText)
        }
    }

    private var sharingSection: some View {
        sectionCard(title: "Sharing") {
            Toggle(isOn: invisibilityBinding) {
                Text("Invisible pendant le partage")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(NotionTheme.text)
            }
            .toggleStyle(.switch)
        }
    }

    // MARK: - Subviews

    private var modeButtons: some View {
        HStack(spacing: 6) {
            modeButton(title: "Notch", isSelected: !state.isFloatingMode) {
                guard state.isFloatingMode else { return }
                onToggleMode()
            }

            modeButton(title: "Floating", isSelected: state.isFloatingMode) {
                guard !state.isFloatingMode else { return }
                onToggleMode()
            }
        }
    }

    private var colorPresets: some View {
        HStack(spacing: 6) {
            ForEach(presetColors, id: \.hex) { preset in
                Button {
                    textColorHex = preset.hex
                } label: {
                    Circle()
                        .fill(color(forHex: preset.hex))
                        .frame(width: 16, height: 16)
                        .overlay(
                            Circle()
                                .stroke(borderColor(for: preset.hex), lineWidth: 1)
                        )
                        .overlay {
                            if textColorHex == preset.hex {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundStyle(checkmarkColor(for: preset.hex))
                            }
                        }
                }
                .buttonStyle(.plain)
                .help(preset.name)
            }
        }
    }

    private var previewCanvas: some View {
        ZStack {
            Color.black

            VStack(spacing: 0) {
                if !state.isFloatingMode {
                    Color.clear.frame(height: 18)
                }

                Text("TopCue garde vos yeux pres de la camera")
                    .font(previewFont)
                    .foregroundStyle(color(forHex: textColorHex))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .padding(.horizontal, 14)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

                if state.voiceModeEnabled {
                    VoiceBeamView(audioLevel: previewAudioLevel)
                        .padding(.bottom, 6)
                }
            }
        }
        .frame(height: 84)
        .clipShape(previewShape)
        .overlay(
            previewShape
                .stroke(.white.opacity(0.08), lineWidth: 1)
        )
    }

    private func sectionCard<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(NotionTheme.secondaryText)
                .textCase(.uppercase)
                .tracking(0.4)

            content()
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(NotionTheme.content)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(NotionTheme.subtleDivider, lineWidth: 1)
        )
    }

    private func settingRow<Accessory: View>(
        label: String,
        @ViewBuilder accessory: () -> Accessory
    ) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(NotionTheme.text)

            Spacer()
            accessory()
        }
    }

    private func modeButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(isSelected ? .white : NotionTheme.secondaryText)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isSelected ? NotionTheme.accent : NotionTheme.hover)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Computed

    private var voiceModeBinding: Binding<Bool> {
        Binding(
            get: { state.voiceModeEnabled },
            set: { newValue in
                guard newValue != state.voiceModeEnabled else { return }
                onToggleVoiceMode()
            }
        )
    }

    private var invisibilityBinding: Binding<Bool> {
        Binding(
            get: { state.isInvisible },
            set: { newValue in
                guard newValue != state.isInvisible else { return }
                onToggleInvisibility()
            }
        )
    }

    private var sensitivityLabel: String {
        switch voiceDetector.sensitivity {
        case 0..<0.33:
            return "Elevee"
        case 0.33..<0.66:
            return "Moyenne"
        default:
            return "Faible"
        }
    }

    private var previewFont: Font {
        let size = min(max(fontSize * 0.55, 12), 24)
        return .system(size: size, weight: .medium, design: .monospaced)
    }

    private var previewAudioLevel: Float {
        guard state.voiceModeEnabled else { return 0 }
        let level = 0.25 + ((1 - voiceDetector.sensitivity) * 0.6)
        return Float(min(max(level, 0), 1))
    }

    private var previewShape: AnyShape {
        if state.isFloatingMode {
            return AnyShape(RoundedRectangle(cornerRadius: Constants.Floating.cornerRadius, style: .continuous))
        }

        return AnyShape(
            NotchShape(
                topCornerRadius: Constants.Notch.topCornerRadius,
                bottomCornerRadius: Constants.Notch.bottomCornerRadius
            )
        )
    }

    // MARK: - Color Helpers

    private func borderColor(for hex: String) -> Color {
        if textColorHex == hex {
            return NotionTheme.accent
        }

        return NotionTheme.subtleDivider
    }

    private func checkmarkColor(for hex: String) -> Color {
        if hex == "#FFFFFF" || hex == "#FFFF00" {
            return .black.opacity(0.75)
        }

        return .white
    }

    private func color(forHex hex: String) -> Color {
        var value = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        value = value.replacingOccurrences(of: "#", with: "")

        guard value.count == 6,
              let rgb = UInt64(value, radix: 16) else {
            return .white
        }

        return Color(
            red: Double((rgb >> 16) & 0xFF) / 255.0,
            green: Double((rgb >> 8) & 0xFF) / 255.0,
            blue: Double(rgb & 0xFF) / 255.0
        )
    }
}

#Preview {
    let state = PrompterState()
    let detector = VoiceDetector()

    NotionSettingsPopover(
        state: state,
        voiceDetector: detector,
        onToggleMode: { state.toggleMode() },
        onToggleInvisibility: { state.toggleInvisibility() },
        onToggleVoiceMode: { state.toggleVoiceMode() }
    )
    .padding()
}
