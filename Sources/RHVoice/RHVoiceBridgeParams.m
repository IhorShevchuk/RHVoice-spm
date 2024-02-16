//
//  RHVoiceBridgeInitParams.m
//  RHVoice
//
//  Created by Ihor Shevchuk on 09.05.2022.
//
//  Copyright (C) 2022  Olga Yakovleva <olga@rhvoice.org>

#import <RHVoice/RHVoiceBridgeParams.h>
#import <RHVoice/RHVoiceLoggerProtocol.h>

@implementation RHVoiceBridgeParams
+ (instancetype)defaultParams {
    NSString *pathToData = [[NSBundle mainBundle] pathForResource:@"RHVoiceData" ofType:nil];
    if(pathToData.length == 0) {
        NSBundle *rhVoiceBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"RHVoice_RHVoice" ofType:@"bundle"]];
        pathToData = [rhVoiceBundle pathForResource:@"data" ofType:nil];
    }

    RHVoiceBridgeParams *result = [[RHVoiceBridgeParams alloc] init];
    result.dataPath = pathToData;
    result.configPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return result;
}

- (BOOL)isEqual:(id)object {
    RHVoiceBridgeParams *anotherObject = object;
    if(![anotherObject isKindOfClass:[self class]]) {
        return NO;
    }
    
    return [anotherObject.dataPath isEqualToString:self.dataPath] &&
           [anotherObject.logger isEqual:self.logger];
}

- (NSUInteger)hash {
    return [self.dataPath hash] ^ [self.logger hash];
}
@end
