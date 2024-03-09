//
//  RHLanguage.h
//  RHVoiceFramework
//
//  Created by Ihor Shevchuk on 15.09.2022.
//
//  Copyright (C) 2022  Olga Yakovleva <olga@rhvoice.org>

#import <Foundation/Foundation.h>

@class RHVersionInfo;
@class RHSpeechSynthesisVoice;

NS_ASSUME_NONNULL_BEGIN

@interface RHLanguage : NSObject
@property (nonatomic, readonly, strong) NSString *code;
@property (nonatomic, readonly, strong) NSString *country;
@property (nonatomic, readonly, strong, nullable) RHVersionInfo *version;
@property (nonatomic, readonly, strong) NSArray<RHSpeechSynthesisVoice *> *voices;
@end

NS_ASSUME_NONNULL_END
