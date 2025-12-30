//
//  RHSpeechSynthesizer.swift
//
//
//  Created by Ihor Shevchuk on 09.03.2024.
//

import CxxStdlib
import Foundation
import RHVoice.RHVoice
import RHVoiceCpp

#if canImport(AVFoundation)
    import AVFoundation
#endif

public class RHSpeechSynthesizer: @unchecked Sendable {
    enum SynthesizerError: Error {
        #if canImport(AVFoundation)
            case noPlayer
        #endif
        case failToSynthesize
        case nothingToSynthesize
        case noVoiceProvided
        case cantFindVoice
        case noEngine
    }

    public struct Params {
        public var dataPath: String
        public var configPath: String
        public var logger: RHVoiceLogger?
        @MainActor public static let `default`: Params = {
            var pathToData = Bundle.main.path(forResource: "RHVoiceData", ofType: nil)
            if pathToData == nil || pathToData?.isEmpty == true {
                let rhVoiceBundle = Bundle(
                    path: Bundle.main.path(forResource: "RHVoice_RHVoice", ofType: "bundle") ?? "")
                pathToData = rhVoiceBundle?.path(forResource: "data", ofType: nil)
            }

            let logger = RHVoiceLoggerImpl()

            return Params(
                dataPath: pathToData ?? "",
                configPath: FileManager.default.currentDirectoryPath + "/",
                logger: logger
            )
        }()

        var rhVoiceParam: RHVoiceCpp.engine.params {
            var result = RHVoiceCpp.engine.params()
            result.data_path = std.string(dataPath)
            result.config_path = std.string(configPath)

            if let logger {
                let box = LoggerBox(logger)
                let ctx = Unmanaged.passRetained(box).toOpaque()
                let sharedLogger = RHVoiceCpp.make_event_logger(
                    ctx,
                    logThunk,
                    destroyLogThunk
                )
                result.logger = sharedLogger
            }
            return result
        }
    }

    public var params: Params {
        didSet {
            createEngine()
        }
    }

    #if canImport(AVFoundation)
        public func speak(utterance: RHSpeechUtterance) async throws {
            let path = String.temporaryPath(extesnion: "wav")
            try await synthesize(utterance: utterance, to: path)
            let playerItem = AVPlayerItem(url: URL(fileURLWithPath: path))
            try await playItemAsync(playerItem)
            try FileManager.default.removeItem(atPath: path)
        }

        public func stopAndCancel() async {
            await player?.pause()
            player = nil
            if let playerContinuation {
                playerContinuation.resume()
                self.playerContinuation = nil
            }
        }
    #endif

    public func synthesize(utterance: RHSpeechUtterance, to path: String) async throws {

        if utterance.isEmpty {
            throw SynthesizerError.nothingToSynthesize
        }

        guard let text: String = utterance.ssml else {
            return
        }

        guard let voiceIdentifier = utterance.voice?.identifier else {
            throw SynthesizerError.noVoiceProvided
        }

        guard let voice = speechVoices.first(where: { $0.identifier == voiceIdentifier }) else {
            throw SynthesizerError.cantFindVoice
        }

        guard let engine = rhVoiceEngine else {
            throw SynthesizerError.noEngine
        }

        let params = RHVoiceCpp.engine.synt_param(
            rate: utterance.rate,
            pitch: utterance.pitch,
            volume: utterance.volume,
            quality: std.string(utterance.quality.rawValue))
        engine.synthesize(
            std.string(text),
            std.string(path),
            voice.voiceInfo,
            params)
    }

    private var rhVoiceEngine: RHVoiceCpp.engine?

    @MainActor
    public static let shared: RHSpeechSynthesizer = {
        let instance = RHSpeechSynthesizer(params: .default)
        return instance
    }()

    private init(params: Params) {
        self.params = params
        #if canImport(AVFoundation)
            try? FileManager.default.createTempFolderIfNeeded(at: String.temporaryFolderPath)
        #endif
    }

    deinit {
        deleteEngine()
        #if canImport(AVFoundation)
            try? FileManager.default.removeTempFolderIfNeeded(at: String.temporaryFolderPath)
        #endif
    }

    #if canImport(AVFoundation)
        private var player: AVPlayer?
        private var playerContinuation: CheckedContinuation<Void, any Error>?
    #endif
}

extension RHSpeechSynthesizer {
    fileprivate func createEngine() {
        deleteEngine()
        let params = params.rhVoiceParam
        rhVoiceEngine = RHVoiceCpp.engine(params)
    }

    fileprivate func deleteEngine() {
        rhVoiceEngine = nil
    }
}

extension RHSpeechSynthesizer {

    #if canImport(AVFoundation)
        @MainActor
        fileprivate func playItemAsync(_ item: AVPlayerItem) async throws {
            await stopAndCancel()
            player = AVPlayer()
            var observerEnd: Any?
            var statusObserver: NSKeyValueObservation?
            try await withCheckedThrowingContinuation { [weak self] continuation in

                let continuation = continuation as CheckedContinuation<Void, any Error>
                guard let player = self?.player else {
                    continuation.resume(throwing: SynthesizerError.noPlayer)
                    return
                }

                observerEnd = NotificationCenter.default.addObserver(
                    forName: AVPlayerItem.didPlayToEndTimeNotification, object: item, queue: nil
                ) { _ in
                    continuation.resume()
                }

                statusObserver = item.observe(
                    \.status,
                    changeHandler: { item, _ in
                        if let error = item.error {
                            continuation.resume(throwing: error)
                        }
                    })

                self?.playerContinuation = continuation

                player.replaceCurrentItem(with: item)
                player.play()
            }

            if let observerEnd {
                NotificationCenter.default.removeObserver(
                    observerEnd, name: .AVPlayerItemDidPlayToEndTime, object: item)
            }
            statusObserver?.invalidate()
            self.playerContinuation = nil
            await stopAndCancel()
        }
    #endif

}

extension RHSpeechSynthesizer {

    var speechVoices: [RHSpeechSynthesisVoice] {
        guard let rhVoiceEngine else {
            return []
        }
        let voices = rhVoiceEngine.get_voices()

        var result: [RHSpeechSynthesisVoice] = []

        for voice in voices {
            result.append(RHSpeechSynthesisVoice(voice: voice))
        }

        return result
    }

}
