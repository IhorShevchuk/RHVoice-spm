//
//  RHVoiceSwiftSample.swift
//
//
//  Created by Ihor Shevchuk on 09.03.2024.
//

import Foundation
import RHVoiceSwift

@main
struct PackDataExecutable {

    static var dataPath: String {
        let fileUrl = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()

        return fileUrl.path + "/RHVoice/RHVoice/data"
    }

    static func main() throws {
        var params = RHVoiceSwift.RHSpeechSynthesizer.Params.default

        params.dataPath = dataPath

        let synthesizer = RHSpeechSynthesizer.shared
        synthesizer.params = params

        Task {
            let voices = RHSpeechSynthesisVoice.speechVoices
            var utterance = RHSpeechUtterance(text: "Hello My name is RHVoice!")
            utterance.voice = voices[0]

            try await synthesizer.speak(utterance: utterance)
        }

        RunLoop.main.run()
    }
}
