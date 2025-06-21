//
//  RHSpeechUtterance.swift
//
//
//  Created by Ihor Shevchuk on 10.03.2024.
//

import Foundation
import RHVoice

public struct RHSpeechUtterance {
    public enum Quality: String {
        case minimum
        case standart
        case maximum
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

    public init(ssml: String?) {
        self.ssml = ssml
    }

    public init(text: String?) {
        self.init(ssml: "<speak>\(text ?? "")</speak>")
    }
}
