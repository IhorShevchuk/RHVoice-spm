//
//  RHSpeechUtterance.swift
//
//
//  Created by Ihor Shevchuk on 10.03.2024.
//

import Foundation
import RHVoice

public struct RHSpeechUtterance {
    public enum Quality {
        case min
        case standart
        case max
    }

    enum UtteranceError: Error {
        case noVoiceProvided
    }

    public let ssml: String?
    var isEmpty: Bool {
        return self.ssml?.isEmpty == true
            || self.ssml == nil
            || self.ssml == "<speak></speak>"
    }

    public var voice: RHSpeechSynthesisVoice?
    public var rate: Double = 1.0
    public var volume: Double = 1.0
    public var pitch: Double = 1.0
    public var quality: Quality = .standart

    var synthParams: RHVoice_synth_params {
        get throws {
            var result = RHVoice_synth_params()
            result.absolute_pitch = 0.0
            result.absolute_rate = 0.0
            result.absolute_volume = 0.0
            result.relative_rate = rate
            result.relative_pitch = pitch
            result.relative_volume = volume
            guard let voice else {
                throw UtteranceError.noVoiceProvided
            }
            result.voice_profile = voice._identifier
            return result
        }
    }

    public init(ssml: String?) {
        self.ssml = ssml
    }

    public init(text: String?) {
        self.init(ssml: "<speak>\(text ?? "")</speak>")
    }
}
