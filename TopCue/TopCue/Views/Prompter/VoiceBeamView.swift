//
//  VoiceBeamView.swift
//  TopCue
//
//  Created by Sanz on 06/02/2026.
//

import SwiftUI

/// Arc anime affichant le niveau vocal courant du mode voix.
struct VoiceBeamView: View {

    // MARK: - Properties

    let audioLevel: Float

    private var clampedLevel: CGFloat {
        min(max(CGFloat(audioLevel), 0), 1)
    }

    private var beamWidth: CGFloat {
        48 + (clampedLevel * 70)
    }

    private var beamHeight: CGFloat {
        1.5 + (clampedLevel * Constants.Voice.beamMaxHeight)
    }

    // MARK: - Body

    var body: some View {
        VoiceBeamShape(intensity: clampedLevel)
            .stroke(
                LinearGradient(
                    colors: [beamColor(for: clampedLevel * 0.6), beamColor(for: clampedLevel)],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: beamHeight, lineCap: .round, lineJoin: .round)
            )
            .frame(width: beamWidth, height: Constants.Voice.beamMaxHeight + 2)
            .opacity(0.35 + (clampedLevel * 0.6))
            .animation(.easeOut(duration: 0.1), value: clampedLevel)
            .accessibilityLabel("Niveau audio")
    }

    // MARK: - Private

    private func beamColor(for level: CGFloat) -> Color {
        let blue = SIMD3<Double>(0.149, 0.455, 0.961)
        let violet = SIMD3<Double>(0.584, 0.302, 1.0)
        let red = SIMD3<Double>(0.969, 0.231, 0.2)

        if level < 0.5 {
            return interpolatedColor(from: blue, to: violet, progress: Double(level / 0.5))
        }

        return interpolatedColor(from: violet, to: red, progress: Double((level - 0.5) / 0.5))
    }

    private func interpolatedColor(from: SIMD3<Double>, to: SIMD3<Double>, progress: Double) -> Color {
        let clampedProgress = min(max(progress, 0), 1)
        let red = from.x + ((to.x - from.x) * clampedProgress)
        let green = from.y + ((to.y - from.y) * clampedProgress)
        let blue = from.z + ((to.z - from.z) * clampedProgress)
        return Color(red: red, green: green, blue: blue)
    }
}

// MARK: - VoiceBeamShape

private struct VoiceBeamShape: Shape {

    var intensity: CGFloat

    var animatableData: CGFloat {
        get { intensity }
        set { intensity = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let baselineY = rect.maxY - 1
        let leftPoint = CGPoint(x: rect.minX, y: baselineY)
        let rightPoint = CGPoint(x: rect.maxX, y: baselineY)
        let controlY = baselineY - max(0.8, rect.height * (0.25 + (0.65 * intensity)))
        let controlPoint = CGPoint(x: rect.midX, y: controlY)

        path.move(to: leftPoint)
        path.addQuadCurve(to: rightPoint, control: controlPoint)
        return path
    }
}

#Preview("Voice Beam") {
    VStack(spacing: 10) {
        VoiceBeamView(audioLevel: 0.1)
        VoiceBeamView(audioLevel: 0.5)
        VoiceBeamView(audioLevel: 0.95)
    }
    .padding()
    .background(.black)
}
