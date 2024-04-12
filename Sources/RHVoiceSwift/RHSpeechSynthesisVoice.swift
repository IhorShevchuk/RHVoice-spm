//
//  RHSpeechSynthesisVoice.swift
//
//
//  Created by Ihor Shevchuk on 10.03.2024.
//

import Foundation
import RHVoice

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

    public var name: String {
        String(char: _name)
    }
    public let language: RHLanguage
    public var identifier: String {
        String(char: _identifier)
    }
    public let gender: Gender

    let _name: UnsafePointer<CChar>?
    let _identifier: UnsafePointer<CChar>?

    static public var speechVoices: [RHSpeechSynthesisVoice] {
        return RHSpeechSynthesizer.shared.speechVoices
    }

    init(name: UnsafePointer<CChar>?, language: RHLanguage, identifier: UnsafePointer<CChar>?, gender: Gender) {
        self._name = name
        self.language = language
        self._identifier = identifier
        self.gender = gender
    }

    init(voice: RHVoice_voice_info) {
        self.init(name: voice.name,
                  language: RHLanguage(code: String(char: voice.language),
                                       country: String(char: voice.country),
                                       version: RHVersionInfo(format: 0, revision: 0)),
                  identifier: voice.name,
                  gender: Gender(gender: voice.gender))
    }
}
