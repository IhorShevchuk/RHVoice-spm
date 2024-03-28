//
//  RHLanguage.swift
//
//
//  Created by Ihor Shevchuk on 10.03.2024.
//

import Foundation

public struct RHLanguage {
    internal(set) public var code: String
    internal(set) public var country: String
    internal(set) public var version: RHVersionInfo
    public var voices: [RHSpeechSynthesisVoice] {
        return RHSpeechSynthesisVoice.speechVoices.filter { voice in
            voice.language.country == country
        }
    }
}
