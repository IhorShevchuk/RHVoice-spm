//
//  language_wrapper.h
//  RHVoice
//
//  Created by Ihor Shevchuk on 6/20/25.
//

#include <string>
#include <vector>
#include <memory>

#include "core/language.hpp"

namespace RHVoiceCpp {
    class language_wrapper {
    public:
        const std::string &get_name() const {
          return language_info->get_name();
        }
        
        const std::string &get_alpha2_code() const {
          return language_info->get_alpha2_code();
        }
        
        const std::string &get_data_path() const {
          return language_info->get_data_path();
        }
        
        explicit language_wrapper(RHVoice::language_list::const_iterator language) {
            language_info = language;
        }
        
    private:
        RHVoice::language_list::const_iterator language_info;
    };
}
