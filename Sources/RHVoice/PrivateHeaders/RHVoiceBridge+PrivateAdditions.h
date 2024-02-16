//
//  RHVoiceBridge+Private.h
//  RHVoice
//
//  Created by Ihor Shevchuk on 03.05.2022.
//
//  Copyright (C) 2022  Olga Yakovleva <olga@rhvoice.org>

#ifndef RHVoiceBridge_Private_h
#define RHVoiceBridge_Private_h

#import <RHVoice/RHVoiceBridge.h>

#include "core/voice.hpp"
#include "core/engine.hpp"

@interface RHVoiceBridge(private_additions)
- (const RHVoice::voice_list &)voices;
- (std::shared_ptr<RHVoice::engine>)engine;

@end

#endif /* RHVoiceBridge_Private_h */
