//
//  ContentView.swift
//  Sample
//
//  Created by Ihor Shevchuk on 28.03.2024.
//

import RHVoiceObjC
import SwiftUI

struct ContentView: View {

    let synthesizer = RHSpeechSynthesizer()

    var body: some View {
        VStack {
            Button {
                let voice = RHSpeechSynthesisVoice.speechVoices().first

                let utterance = RHSpeechUtterance(text: "Sample Text")
                if let voice = voice {
                    utterance.voice = voice
                }
                synthesizer.speak(utterance)
            }  label: {
                Text("Play Sample")
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
