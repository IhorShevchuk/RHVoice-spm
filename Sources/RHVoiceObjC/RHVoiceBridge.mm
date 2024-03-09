//
//  RHVoiceBridge.m
//  RHVoice
//
//  Created by Ihor Shevchuk on 02.05.2022.
//
//  Copyright (C) 2022  Olga Yakovleva <olga@rhvoice.org>

#import <RHVoice/RHVoiceBridge.h>
#import <RHVoice/RHSpeechSynthesisVoice.h>
#import <RHVoice/RHVoiceBridgeParams.h>

#import "RHVoiceBridge+PrivateAdditions.h"
#import "RHLanguage+Private.h"

#import <AVFAudio/AVAudioSession.h>
#import <AVFAudio/AVAudioPlayer.h>
#import <AVFAudio/AVSpeechSynthesis.h>

#import "NSFileManager+Additions.h"
#import "NSString+Additions.h"
#import "NSString+stdStringAddtitons.h"
#import "RHVoiceLogger.h"



#include "RHEventLoggerImpl.hpp"
#include "core/engine.hpp"
#include "../../RHVoice/RHVoice/src/include/RHVoice.h"

@interface RHVoiceBridge () {
    std::shared_ptr<RHVoice::engine> RHEngine;
}
@end

@implementation RHVoiceBridge

#pragma mark - Public

+ (instancetype)sharedInstance {
    static RHVoiceBridge *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RHVoiceBridge alloc] init];
    });
    return sharedInstance;
}

- (void)setParams:(RHVoiceBridgeParams *)params {
    if(![self.params isEqual:params]) {
        _params = params;
    }
}

- (NSString *)version {
    return STDStringToNSString(RHVoice_get_version());
}

- (NSArray <RHLanguage *> *)languages {
    if(![self engine].get()) {
        return @[];
    }
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (auto language = [self engine]->get_languages().begin(); language != [self engine]->get_languages().end(); ++language) {
        [result addObject:[[RHLanguage alloc] initWith:*language]];
    }
    return [result copy];
}

- (std::shared_ptr<RHVoice::engine>)engine {
    @synchronized (self) {
        if(RHEngine.get() == nil) {
            [self createRHEngineWithParams:self.params];
        }
        
        return RHEngine;
    }
}

#pragma mark - Private

+ (void)load {
    [[NSFileManager defaultManager] RHRemoveTempFolderIfNeededPath:[NSString RHTemporaryFolderPath]];
}

- (instancetype)init {
    self = [super init];
    if(self) {
        self.params = [RHVoiceBridgeParams defaultParams];
    }
    return self;
}

- (void)createRHEngineWithParams:(RHVoiceBridgeParams *)params {
    try {
        RHVoice::engine::init_params param;
        param.data_path = params.dataPath.UTF8String;
        param.config_path = params.configPath.UTF8String;
        if(params.logger != nil && [params.logger respondsToSelector:@selector(logAtLevel:message:)]) {
            param.logger = std::make_shared<RHEventLoggerImpl>();
        }
        
        RHEngine = std::make_shared<RHVoice::engine>(param);
    } catch (...) {
        [RHVoiceLogger logAtLevel:RHVoiceLogLevelError format:@"No Languages folder is located at: %@",params.dataPath];
        [RHVoiceLogger logAtLevel:RHVoiceLogLevelError format:@"Please set  valid 'dataPath' property for %@ object. This folder has to contain 'languages' and 'voices' folders."];
    }
}

- (const RHVoice::voice_list &)voices {
    return [self engine]->get_voices();
}
@end
