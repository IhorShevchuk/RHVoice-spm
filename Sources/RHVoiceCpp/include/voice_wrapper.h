//
//  VoiceWrapper.h
//  RHVoice
//
//  Created by Ihor Shevchuk on 6/20/25.
//

#include <string>
#include <vector>
#include <memory>

#include "language_wrapper.h"

#include "core/voice.hpp"

namespace RHVoiceCpp {
    class voice_wrapper {
    public:
        const std::string &get_data_path() const {
          return voice_info->get_data_path();
        }
        
        const std::string &get_name() const {
          return voice_info->get_name();
        }
        
        const std::string &get_id() const {
          return voice_info->get_id();
        }
        
        const RHVoice_voice_gender get_gender() const {
          return voice_info->get_gender();
        }
        
        language_wrapper get_language() const {
            return language_wrapper(voice_info->get_language());
        }
        
        explicit voice_wrapper(RHVoice::voice_list::const_iterator voice) {
            voice_info = voice;
        }
        
    private:
        RHVoice::voice_list::const_iterator voice_info;
    };
}
