//
//  EngineWrapper.cpp
//  RHVoice
//
//  Created by Ihor Shevchuk on 6/20/25.
//

#include "engine.h"

#include "core/document.hpp"

#include "FilePlaybackStream.h"

namespace RHVoiceCpp {
   engine::params::params() {
       RHVoice::engine::init_params params;
       data_path = params.data_path;
       config_path = params.config_path;
       pkg_path = params.pkg_path;
       resource_paths = params.resource_paths;
       logger = params.logger;
   }

   RHVoice::engine::init_params engine::params::get_init_params() const {
       RHVoice::engine::init_params params;
       params.data_path = data_path;
       params.config_path = config_path;
       params.pkg_path = pkg_path;
       params.resource_paths = resource_paths;
       params.logger = logger;
       return params;
   }

   engine::engine(const params& params) {
       eng = std::make_shared<RHVoice::engine>(params.get_init_params());
   }

   std::vector<voice> engine::get_voices() const {
       std::vector<voice> result;
       const RHVoice::voice_list &voices = eng->get_voices();
       
       for (auto voice_element = voices.begin(); voice_element != voices.end(); ++voice_element) {
           result.push_back(voice(voice_element));
       }
       
       return result;
   }

   void engine::synthesize(const std::string text,
                           const std::string path,
                           voice voice,
                           synt_param param) const {
       if (path.empty() || text.empty()) {
           return;
       }
       
       
       RHVoice::voice_profile voice_profile(voice.get_voice_info());
       std::unique_ptr<RHVoice::document> doc = RHVoice::document::create_from_ssml(eng,
                                                                                    text.begin(),
                                                                                    text.end(),
                                                                                    voice_profile);
       if (param.pitch != 0) {
           doc->speech_settings.relative.pitch = param.pitch;
       }
       
       if (param.rate != 0) {
           doc->speech_settings.relative.rate = param.rate;
       }
       
       if (param.volume != 0) {
           doc->speech_settings.relative.rate = param.volume;
       }
       
       if (!param.quality.empty()) {
           doc->quality.set_from_string(param.quality);
       }
       
       PlayerLib::FilePlaybackStream player(path.c_str());
       player.set_buffer_size(20);
       player.set_sample_rate(24000);
       doc->set_owner(player);
       doc->synthesize();
       player.finish();
   }
}
