//
//  RHEventLoggerImpl.cpp
//  RHVoice
//
//  Created by Ihor Shevchuk on 04.05.2022.
//
//  Copyright (C) 2022  Olga Yakovleva <olga@rhvoice.org>

#include "RHEventLoggerImpl.hpp"

#import "RHVoiceLogger.h"
#import "NSString+stdStringAddtitons.h"

void RHEventLoggerImpl::log(const std::string& tag, RHVoice_log_level level, const std::string& message) const {
    
    NSString *nsTag = STDStringToNSString(tag);
    NSString *nsMessage = STDStringToNSString(message);
    
    [RHVoiceLogger logAtRHVoiceLevel:level message:[[NSString alloc] initWithFormat:@"%@ %@",nsTag, nsMessage]];
}
