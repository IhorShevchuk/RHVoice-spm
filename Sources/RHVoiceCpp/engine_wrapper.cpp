//
//  EngineWrapper.cpp
//  RHVoice
//
//  Created by Ihor Shevchuk on 6/20/25.
//

#include "engine_wrapper.h"

#include "core/document.hpp"

using namespace RHVoice;
namespace RHVoiceCpp {
   engine_wrapper::params::params() {
       engine::init_params params;
       data_path = params.data_path;
       config_path = params.config_path;
       pkg_path = params.pkg_path;
       resource_paths = params.resource_paths;
       logger = params.logger;
   }

   RHVoice::engine::init_params engine_wrapper::params::get_init_params() const {
       engine::init_params params;
       params.data_path = data_path;
       params.config_path = config_path;
       params.pkg_path = pkg_path;
       params.resource_paths = resource_paths;
       params.logger = logger;
       return params;
   }

   engine_wrapper::engine_wrapper(const params& params) {
       engine = std::make_shared<RHVoice::engine>(params.get_init_params());
   }

   std::vector<voice_wrapper> engine_wrapper::get_voices() const {
       std::vector<voice_wrapper> result;
       const RHVoice::voice_list &voices = engine->get_voices();
       
       for (auto voice = voices.begin(); voice != voices.end(); ++voice) {
           result.push_back(voice_wrapper(voice));
       }
       
       return result;
   }

   document_wrapper engine_wrapper::create_document(const std::string text, voice_wrapper voice) const {
       RHVoice::voice_profile voice_profile(voice.get_voice_info());
       std::unique_ptr<RHVoice::document> doc = RHVoice::document::create_from_ssml(engine,
                                                                                    text.begin(),
                                                                                    text.end(),
                                                                                    voice_profile);
       return document_wrapper(std::move(doc));
   }
}
