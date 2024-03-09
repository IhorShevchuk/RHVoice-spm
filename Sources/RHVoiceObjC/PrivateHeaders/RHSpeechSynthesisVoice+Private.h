//
//  RHSpeechSynthesisVoice+Private.h
//  RHVoice
//
//  Created by Ihor Shevchuk on 03.05.2022.
//
//  Copyright (C) 2022  Olga Yakovleva <olga@rhvoice.org>

#ifndef RHSpeechSynthesisVoice_Private_h
#define RHSpeechSynthesisVoice_Private_h

#import <RHVoice/RHSpeechSynthesisVoice.h>

#include "core/voice.hpp"

@interface RHSpeechSynthesisVoice(private_additions)

- (RHVoice::voice_list::const_iterator)voiceInfo;

@end

#endif /* RHSpeechSynthesisVoice_Private_h */
