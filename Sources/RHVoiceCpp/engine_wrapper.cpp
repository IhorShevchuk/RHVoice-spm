//
//  EngineWrapper.cpp
//  RHVoice
//
//  Created by Ihor Shevchuk on 6/20/25.
//

#include "engine_wrapper.h"

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
}
