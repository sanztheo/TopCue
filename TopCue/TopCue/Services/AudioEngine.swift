//
//  AudioEngine.swift
//  TopCue
//
//  Created by Sanz on 06/02/2026.
//

import AVFoundation
import Foundation

/// Fournit un flux de niveaux audio RMS a partir du microphone systeme.
final class AudioEngine {

    typealias LevelHandler = (Float) -> Void

    // MARK: - Properties

    /// Callback appelee a chaque buffer avec un niveau RMS entre 0.0 et 1.0.
    /// Le callback est execute sur la queue audio du tap (pas sur le MainActor).
    var onLevel: LevelHandler?

    /// Indique si le moteur audio est actif.
    var isRunning: Bool {
        engine.isRunning
    }

    private let engine = AVAudioEngine()
    private var isTapInstalled = false

    // MARK: - Control

    /// Demarre la capture micro et l'emission des niveaux RMS.
    /// - Throws: `AudioEngineError.microphoneUnavailable` si aucun canal d'entree n'est detecte.
    func start() throws {
        guard !engine.isRunning else { return }

        let inputNode = engine.inputNode
        let inputFormat = inputNode.inputFormat(forBus: 0)
        let levelHandler = onLevel

        guard inputFormat.channelCount > 0 else {
            throw AudioEngineError.microphoneUnavailable
        }

        let tapFormat = preferredTapFormat(from: inputFormat)
        inputNode.removeTap(onBus: 0)

        inputNode.installTap(
            onBus: 0,
            bufferSize: AVAudioFrameCount(Constants.Voice.bufferSize),
            format: tapFormat
        ) { buffer, _ in
            let level = Self.computeRmsLevel(from: buffer)
            Self.emit(level: level, to: levelHandler)
        }

        isTapInstalled = true
        engine.prepare()
        try engine.start()
    }

    /// Arrete la capture micro et nettoie le tap audio.
    func stop() {
        guard engine.isRunning || isTapInstalled else { return }

        if isTapInstalled {
            engine.inputNode.removeTap(onBus: 0)
            isTapInstalled = false
        }

        engine.stop()
        engine.reset()
    }

    // MARK: - Private

    private func preferredTapFormat(from inputFormat: AVAudioFormat) -> AVAudioFormat {
        if let monoFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: inputFormat.sampleRate,
            channels: 1,
            interleaved: false
        ) {
            return monoFormat
        }

        return inputFormat
    }

    nonisolated private static func computeRmsLevel(from buffer: AVAudioPCMBuffer) -> Float {
        guard let channels = buffer.floatChannelData else { return 0 }

        let frameLength = Int(buffer.frameLength)
        guard frameLength > 0 else { return 0 }

        let channelCount = Int(buffer.format.channelCount)
        guard channelCount > 0 else { return 0 }

        var squaredSum: Float = 0

        for frameIndex in 0..<frameLength {
            var monoSample: Float = 0

            for channelIndex in 0..<channelCount {
                monoSample += channels[channelIndex][frameIndex]
            }

            monoSample /= Float(channelCount)
            squaredSum += monoSample * monoSample
        }

        let mean = squaredSum / Float(frameLength)
        let rms = sqrt(mean)
        return min(max(rms, 0), 1)
    }

    nonisolated private static func emit(level: Float, to handler: LevelHandler?) {
        guard let handler else { return }
        let clampedLevel = min(max(level, 0), 1)
        handler(clampedLevel)
    }
}

/// Erreurs liees au cycle de vie du moteur audio.
enum AudioEngineError: Error {
    case microphoneUnavailable
}
