//
//  RHSpeechUtterance.h
//  RHVoice
//
//  Created by Ihor Shevchuk on 03.05.2022.
//
//  Copyright (C) 2022  Olga Yakovleva <olga@rhvoice.org>

#import <Foundation/Foundation.h>

@class RHSpeechSynthesisVoice;

typedef enum RHSpeechUtteranceQuality : NSInteger {
    RHSpeechUtteranceQualityMin,
    RHSpeechUtteranceQualityStandart,
    RHSpeechUtteranceQualityMax
} RHSpeechUtteranceQuality;

NS_ASSUME_NONNULL_BEGIN

@interface RHSpeechUtterance : NSObject
@property (nonatomic, strong, nullable, readonly) NSString *ssml;
@property (nonatomic, readonly) BOOL isEmpty;
@property (nonatomic, strong) RHSpeechSynthesisVoice *voice;
@property (nonatomic, assign) double rate;
@property (nonatomic, assign) double volume;
@property (nonatomic, assign) RHSpeechUtteranceQuality quality;

- (instancetype)initWithText:(NSString * _Nullable)text;
- (instancetype)initWithSSML:(NSString * _Nullable)ssml;
@end

NS_ASSUME_NONNULL_END
