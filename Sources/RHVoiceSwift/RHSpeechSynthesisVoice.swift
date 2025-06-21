//
//  RHSpeechSynthesisVoice.swift
//
//
//  Created by Ihor Shevchuk on 10.03.2024.
//

import Foundation
import RHVoice
import RHVoiceCpp

public struct RHSpeechSynthesisVoice {

    public enum Gender {
        case female
        case male
        case unknown

        init(gender: RHVoice_voice_gender) {
            switch gender {
            case   RHVoice_voice_gender_unknown:
                self = .unknown
            case RHVoice_voice_gender_female:
                self = .female
            case  RHVoice_voice_gender_male:
                self = .male
            default:
                self = .unknown
            }
        }
    }

    public let language: RHLanguage
    public let gender: Gender

    public let name: String
    public let identifier: String
    
    let voiceInfo: RHVoiceCpp.voice

    @MainActor
    static public var speechVoices: [RHSpeechSynthesisVoice] {
        return RHSpeechSynthesizer.shared.speechVoices
    }

    init(voice: RHVoiceCpp.voice) {
        self.name = String(voice.get_name())
        self.language = RHLanguage(language: voice.get_language())
        self.identifier = String(voice.get_id())
        self.gender = Gender(gender: voice.get_gender())
        self.voiceInfo = voice
    }
}
