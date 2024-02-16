//
//  RHLanguage+Private.h
//  RHVoiceFramework
//
//  Created by Ihor Shevchuk on 15.09.2022.
//
//  Copyright (C) 2022  Olga Yakovleva <olga@rhvoice.org>

#ifndef RHLanguage_Private_h
#define RHLanguage_Private_h

#include "core/language.hpp"

#import <RHVoice/RHLanguage.h>

@interface RHLanguage (Private)
- (instancetype)initWith:(const RHVoice::language_info &)language;
@end

#endif /* RHLanguage_Private_h */
