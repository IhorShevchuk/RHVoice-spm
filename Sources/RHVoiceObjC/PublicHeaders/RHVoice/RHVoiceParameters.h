//
//  RHVoiceParameters.h
//  RHVoiceFramework
//
//  Created by Ihor Shevchuk on 14.01.2023.
//
//  Copyright (C) 2022  Olga Yakovleva <olga@rhvoice.org>

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RHVoiceParameters : NSObject
@property (nonatomic, readonly) CGFloat max;
@property (nonatomic, readonly) CGFloat min;
@property (nonatomic, readonly) CGFloat defaultValue;
+ (RHVoiceParameters *)volumeParameters;
+ (RHVoiceParameters *)rateParameters;
@end

NS_ASSUME_NONNULL_END
