//
//  EngineWrapper.h
//  RHVoice
//
//  Created by Ihor Shevchuk on 6/20/25.
//

#include <string>
#include <vector>
#include <memory>

#include "voice_wrapper.h"

#include "core/event_logger.hpp"
#include "core/engine.hpp"

namespace RHVoiceCpp {
    class engine_wrapper {
    public:
        
    public:
      struct params
      {
          params();
          std::string data_path, config_path, pkg_path;
          std::vector<std::string> resource_paths;
          std::shared_ptr<RHVoice::event_logger> logger;
          
          RHVoice::engine::init_params get_init_params() const;
      };
      explicit engine_wrapper(const params& param=params());
      const std::vector<voice_wrapper> &get_voices();
        
    private:
        std::shared_ptr<RHVoice::engine> engine;
    };
}
