//
//  RHVoiceBridgeInitParams.h
//  RHVoice
//
//  Created by Ihor Shevchuk on 09.05.2022.
//
//  Copyright (C) 2022  Olga Yakovleva <olga@rhvoice.org>

#import <Foundation/Foundation.h>

@protocol RHVoiceLoggerProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface RHVoiceBridgeParams : NSObject
@property (nonatomic, weak, nullable) id<RHVoiceLoggerProtocol> logger;
@property (nonatomic, strong, nonnull) NSString *dataPath;
@property (nonatomic, strong, nonnull) NSString *configPath;
+ (instancetype)defaultParams;
@end

NS_ASSUME_NONNULL_END
