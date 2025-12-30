//
//  engine_wrapper.h
//  RHVoice
//
//  Created by Ihor Shevchuk on 6/20/25.
//
#pragma once

#include <string>
#include <vector>
#include <memory>

#include "voice.h"

#include "core/event_logger.hpp"
#include "core/engine.hpp"
#include "core/document.hpp"

namespace RHVoiceCpp {
   class engine {
       
   public:
       struct params
       {
           params();
           std::string data_path, config_path, pkg_path;
           std::vector<std::string> resource_paths;
           std::shared_ptr<RHVoice::event_logger> logger;
           
           RHVoice::engine::init_params get_init_params() const;
       };
       
       struct synt_param {
           double rate, pitch, volume;
           std::string quality;
       };
       
       explicit engine(const params& param=params());
       std::vector<voice> get_voices() const;
       void synthesize(const std::string text,
                       const std::string path,
                       voice voice,
                       synt_param param) const;      
   private:
       std::shared_ptr<RHVoice::engine> eng;
   };
}
