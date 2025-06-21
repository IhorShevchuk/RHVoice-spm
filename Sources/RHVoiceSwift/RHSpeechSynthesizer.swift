//
//  RHSpeechSynthesizer.swift
//
//
//  Created by Ihor Shevchuk on 09.03.2024.
//

import Foundation
import RHVoice.RHVoice
import RHVoiceCpp
import CxxStdlib

#if canImport(AVFoundation)
import AVFoundation
#endif

public class RHSpeechSynthesizer {
    enum SynthesizerError: Error {
#if canImport(AVFoundation)
        case noPlayer
#endif
        case failToSynthesize
    }


    public struct Params {
        // TODO: have logger protocol(RHVoiceLoggerProtocol) and add variable of it's type here
        public var dataPath: String
        public var configPath: String
        public static var `default`: Params = {
            var pathToData = Bundle.main.path(forResource: "RHVoiceData", ofType: nil)
            if pathToData == nil || pathToData?.isEmpty == true {
                let rhVoiceBundle = Bundle(path: Bundle.main.path(forResource: "RHVoice_RHVoice", ofType: "bundle") ?? "")
                pathToData = rhVoiceBundle?.path(forResource: "data", ofType: nil)
            }
            return Params(dataPath: pathToData ?? "",
                          configPath: FileManager.default.currentDirectoryPath + "/")

        }()

        var rhVoiceParam: RHVoiceCpp.engine_wrapper.params {
            var result = RHVoiceCpp.engine_wrapper.params()
            result.data_path = std.string(dataPath)
            result.config_path = std.string(configPath)
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
            return
        }

        guard let text: String = utterance.ssml else {
            return
        }
        
        guard let voiceIdentifier = utterance.voice?.identifier else {
            return
        }
        
        guard let voice = speechVoices.first(where: { $0.identifier == voiceIdentifier }) else {
            return
        }
        
        let document = rhVoiceEngine?.create_document(std.string(text), voice.voiceInfo)
        document?.set_rate(utterance.rate)
        document?.set_pitch(utterance.pitch)
        document?.set_volume(utterance.volume)
        document?.synthesize(std.string(path))
    }

    private var rhVoiceEngine: RHVoiceCpp.engine_wrapper?

    public static var shared: RHSpeechSynthesizer = {
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

private extension RHSpeechSynthesizer {
    func createEngine() {
        deleteEngine()
        let params = params.rhVoiceParam
        rhVoiceEngine = RHVoiceCpp.engine_wrapper(params)
    }

    func deleteEngine() {
        rhVoiceEngine = nil
    }
}

private extension RHSpeechSynthesizer {

#if canImport(AVFoundation)
    @MainActor
    func playItemAsync(_ item: AVPlayerItem) async throws {
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

            observerEnd = NotificationCenter.default.addObserver(forName: AVPlayerItem.didPlayToEndTimeNotification, object: item, queue: nil) { _ in
                continuation.resume()
            }

            statusObserver = item.observe(\.status, changeHandler: { item, _ in
                if let error = item.error {
                    continuation.resume(throwing: error)
                }
            })

            self?.playerContinuation = continuation

            player.replaceCurrentItem(with: item)
            player.play()
        }

        if let observerEnd {
            NotificationCenter.default.removeObserver(observerEnd, name: .AVPlayerItemDidPlayToEndTime, object: item)
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
