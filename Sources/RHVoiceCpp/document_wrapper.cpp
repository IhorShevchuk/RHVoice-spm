//
//  document_wrapper.cpp
//  RHVoice
//
//  Created by Ihor Shevchuk on 6/20/25.
//

#include "document_wrapper.h"

#include "FilePlaybackStream.h"

namespace RHVoiceCpp {
   void document_wrapper::synthesize(const std::string path) const {
       PlayerLib::FilePlaybackStream player(path.c_str());
       player.set_buffer_size(20);
       player.set_sample_rate(24000);
       document->set_owner(player);
       document->synthesize();
       player.finish();
   }
}
