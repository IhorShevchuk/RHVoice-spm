//
//  RHVoiceParameters.m
//  RHVoiceFramework
//
//  Created by Ihor Shevchuk on 14.01.2023.
//
//  Copyright (C) 2022  Olga Yakovleva <olga@rhvoice.org>

#import <RHVoice/RHVoiceParameters.h>

#include "core/params.hpp"

@implementation RHVoiceParameters
- (instancetype)initWithMax:(CGFloat)max
                        min:(CGFloat)min
                 andDefault:(CGFloat)defaultValue {
    self = [super init];
    if (self) {
        _max = max;
        _min = min;
        _defaultValue = defaultValue;
    }
    return self;
}

+ (RHVoiceParameters *)volumeParameters {
    RHVoice::voice_params defaultParams;
    return [[RHVoiceParameters alloc] initWithMax:defaultParams.max_volume.get()
                                              min:defaultParams.min_volume.get()
                                       andDefault:defaultParams.default_volume.get()];
}

+ (RHVoiceParameters *)rateParameters {
    RHVoice::voice_params defaultParams;
    return [[RHVoiceParameters alloc] initWithMax:defaultParams.max_rate.get()
                                              min:defaultParams.min_rate.get()
                                       andDefault:defaultParams.default_rate.get()];
}

@end
