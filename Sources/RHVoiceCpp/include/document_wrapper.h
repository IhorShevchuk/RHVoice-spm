//
//  document_wrapper.h
//  RHVoice
//
//  Created by Ihor Shevchuk on 6/20/25.
//
#pragma once

#include <string>
#include <memory>

#include "core/document.hpp"

namespace RHVoiceCpp {
    class document_wrapper {
    public:
        explicit document_wrapper(std::unique_ptr<RHVoice::document> doc) {
            document = std::move(doc);
        }
        
        void set_rate(double rate) const {
            document->speech_settings.relative.rate = rate;
        }
        
        void set_pitch(double pitch) const {
            document->speech_settings.relative.rate = pitch;
        }
        
        void set_volume(double volume) const {
            document->speech_settings.relative.volume = volume;
        }
        
        void set_quality(const std::string quality) const {
            document->quality.set_from_string(quality);
        }
        
        void synthesize(const std::string path) const;
    private:
        std::unique_ptr<RHVoice::document> document;
    };
}
