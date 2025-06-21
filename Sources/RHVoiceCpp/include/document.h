//
//  document_wrapper.h
//  RHVoice
//
//  Created by Ihor Shevchuk on 6/20/25.
//
#pragma once

#include <string>
#include <memory>

#include "voice.h"
#include "engine.h"

#include "core/document.hpp"

namespace RHVoiceCpp {
    class document {
    public:
        explicit document(const std::string text, voice voice, engine eng);
        
        void set_rate(double rate) const {
            docum->speech_settings.relative.rate = rate;
        }
        
        void set_pitch(double pitch) const {
            docum->speech_settings.relative.rate = pitch;
        }
        
        void set_volume(double volume) const {
            docum->speech_settings.relative.volume = volume;
        }
        
        void set_quality(const std::string quality) const {
            docum->quality.set_from_string(quality);
        }
        
        void synthesize(const std::string path) const;
    private:
        std::unique_ptr<RHVoice::document> docum;
    };
}
