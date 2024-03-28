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
        case Min
        case Standart
        case Max
    }

    public let ssml: String?
    var empty: Bool {
        return self.ssml?.isEmpty == true
            || self.ssml == nil
            || self.ssml == "<speak></speak>"
    }

    public var voice: RHSpeechSynthesisVoice?
    public var rate: Double = 1.0
    public var volume: Double = 1.0
    public var pitch: Double = 1.0
    public var quality: Quality = .Standart

    var synthParams: RHVoice_synth_params {
        var result = RHVoice_synth_params()
        result.absolute_pitch = 0.0
        result.absolute_rate = 0.0
        result.absolute_volume = 0.0
        result.relative_rate = rate
        result.relative_pitch = pitch
        result.relative_volume = volume
        result.voice_profile = voice!.identifier.toPointer()
        return result
    }

    public init(ssml: String?) {
        self.ssml = ssml
    }

    public init(text: String?) {
        self.init(ssml: "<speak>\(text ?? "")</speak>")
    }
}
