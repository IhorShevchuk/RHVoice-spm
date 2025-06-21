//
//  document_wrapper.cpp
//  RHVoice
//
//  Created by Ihor Shevchuk on 6/20/25.
//

#include "document.h"

#include "FilePlaybackStream.h"

#include "engine.h"
#include "voice.h"

namespace RHVoiceCpp {
   document::document(const std::string text, voice voice, engine eng) {
       docum = std::move(eng.create_document(text, voice));
   }

   void document::synthesize(const std::string path) const {
       PlayerLib::FilePlaybackStream player(path.c_str());
       player.set_buffer_size(20);
       player.set_sample_rate(24000);
       docum->set_owner(player);
       docum->synthesize();
       player.finish();
   }
}
