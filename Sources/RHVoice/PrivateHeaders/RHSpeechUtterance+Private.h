//
//  RHSpeechUtterance+Private.h
//  RHVoice
//
//  Created by Ihor Shevchuk on 13.09.2022.
//
//  Copyright (C) 2022  Olga Yakovleva <olga@rhvoice.org>

#ifndef RHSpeechUtterance_Private_h
#define RHSpeechUtterance_Private_h

#include "core/voice_profile.hpp"
#include "core/quality_setting.hpp"
#include "core/document.hpp"

#import <RHVoice/RHSpeechUtterance.h>

@interface RHSpeechUtterance (Private)
- (std::unique_ptr<RHVoice::document>)rhVoiceDocument;
@end

#endif /* RHSpeechUtterance_Private_h */
