//
//  RHLanguage.swift
//
//
//  Created by Ihor Shevchuk on 10.03.2024.
//

import Foundation
import RHVoiceCpp

public struct RHLanguage {
    internal(set) public var code: String
    internal(set) public var country: String
    internal(set) public var version: RHVersionInfo
    private var dataPath: String
    init(language: RHVoiceCpp.language) {
        code = String(language.get_alpha2_code())
        country = String(language.get_name())
        dataPath = String(language.get_data_path())
        version = RHVersionInfo(format: 0, revision: 0)
    }
    
    @MainActor
    public var voices: [RHSpeechSynthesisVoice] {
        return RHSpeechSynthesisVoice.speechVoices.filter { voice in
            voice.language.country == country
        }
    }
}
