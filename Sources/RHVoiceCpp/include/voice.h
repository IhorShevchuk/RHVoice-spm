//
//  voice_wrapper.h
//  RHVoice
//
//  Created by Ihor Shevchuk on 6/20/25.
//
#pragma once

#include <string>

#include "language.h"

#include "core/voice.hpp"

namespace RHVoiceCpp {
    class voice {
    public:
        std::string get_data_path() const {
          return voice_info->get_data_path();
        }
        
        std::string get_name() const {
          return voice_info->get_name();
        }
        
        std::string get_id() const {
          return voice_info->get_id();
        }
        
        const RHVoice_voice_gender get_gender() const {
          return voice_info->get_gender();
        }
        
        language get_language() const {
            return language(voice_info->get_language());
        }
        
        RHVoice::voice_list::const_iterator get_voice_info() const {
            return voice_info;
        }
        
        explicit voice(RHVoice::voice_list::const_iterator voice) {
            voice_info = voice;
        }
        
    private:
        RHVoice::voice_list::const_iterator voice_info;
    };
}
