//
//  RHSpeechSynthesizer.swift
//
//
//  Created by Ihor Shevchuk on 09.03.2024.
//

import Foundation
import RHVoice.RHVoice
import PlayerLib

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

        var rhVoiceParam: RHVoice_init_params {
            var result = RHVoice_init_params()
            result.data_path = dataPath.toPointer()
            result.config_path = configPath.toPointer()
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

        fileStream = PlayerLib.FilePlaybackStream(path)
        defer {
            fileStream = nil
        }

        let context = Unmanaged.passRetained(self).toOpaque()

        var params = try utterance.synthParams

        let paramsAddress = withUnsafePointer(to: &params) { pointer in
            UnsafePointer<RHVoice_synth_params>(pointer)
        }

        if utterance.isEmpty {
            return
        }

        guard let text: String = utterance.ssml else {
            return
        }
        let message = RHVoice_new_message(rhVoiceEngine,
                                          text,
                                          UInt32(text.count),
                                          RHVoice_message_ssml,
                                          paramsAddress,
                                          context)
        defer {
            RHVoice_delete_message(message)
        }

        let res = RHVoice_speak(message)
        if res == 0 {
            throw SynthesizerError.failToSynthesize
        }
    }

    private var rhVoiceEngine: RHVoice_tts_engine?

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

    private var fileStream: PlayerLib.FilePlaybackStream?
#if canImport(AVFoundation)
    private var player: AVPlayer?
    private var playerContinuation: CheckedContinuation<Void, any Error>?
#endif
}

private extension RHSpeechSynthesizer {
    func createEngine() {
        deleteEngine()
        var params = params.rhVoiceParam
        params.callbacks.play_speech = { samples, count, context in
            guard let context else {
                return 0
            }

            let object = Unmanaged<RHSpeechSynthesizer>.fromOpaque(context).takeUnretainedValue()
            return object.received(samples: samples, count: count)
        }

        params.callbacks.set_sample_rate = { sampleRate, context in
            guard let context else {
                return 0
            }

            let object = Unmanaged<RHSpeechSynthesizer>.fromOpaque(context).takeUnretainedValue()
            return object.changed(sampleRate: sampleRate)
        }

        params.callbacks.done = { context in
            guard let context else {
                return
            }

            let object = Unmanaged<RHSpeechSynthesizer>.fromOpaque(context).takeUnretainedValue()
            return object.finished()
        }

        let address = withUnsafeMutablePointer(to: &params) { pointer in
            UnsafeMutablePointer<RHVoice_init_params>(pointer)
        }

        rhVoiceEngine = RHVoice_new_tts_engine(address)
    }

    func deleteEngine() {
        if let rhVoiceEngine {
            RHVoice_delete_tts_engine(rhVoiceEngine)
        }
    }
}

private extension RHSpeechSynthesizer {
    func changed(sampleRate: Int32) -> Int32 {
        return fileStream?.set_sample_rate(sampleRate) == true ? 1 : 0
    }

    func finished() {
        fileStream?.finish()
    }

    func received(samples: UnsafePointer<Int16>?, count: UInt32) -> Int32 {
        return fileStream?.play_speech(samples, Int(count))  == true ? 1 : 0
    }

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

        let voicesCount = RHVoice_get_number_of_voices(rhVoiceEngine)
        if voicesCount == 0 {
            return []
        }

        guard let voices = RHVoice_get_voices(rhVoiceEngine) else {
            return []
        }

        let voicesSequence = UnsafePointerSequence(start: voices, count: Int(voicesCount))

        var result: [RHSpeechSynthesisVoice] = []

        for voice in voicesSequence {
            result.append(RHSpeechSynthesisVoice(voice: voice.pointee))
        }

        return result
    }

}
