//
//  RHVersionInfo.m
//  RHVoiceFramework
//
//  Created by Ihor Shevchuk on 18.09.2022.
//
//  Copyright (C) 2022  Olga Yakovleva <olga@rhvoice.org>

#import <RHVoice/RHVersionInfo.h>

#import "RHVoiceLogger.h"
#import "NSString+Additions.h"

@interface RHVersionInfo() {
    NSInteger _format;
    NSInteger _revision;
}
@end

@implementation RHVersionInfo

- (instancetype __nullable)initWith:(NSString *)pathToInfoFile {

    NSDictionary *map = [pathToInfoFile RHFileAtPathToDictionary];
    NSString *format = [map valueForKey:@"format"];
    NSString *revision = [map valueForKey:@"revision"];
    if(format.length > 0 &&
       revision.length > 0) {
        return [self initWith:[format integerValue] revision:[revision integerValue]];
    }
    
    [RHVoiceLogger logAtLevel:RHVoiceLogLevelError format:@"There is no format and revision values in file at path:%@", pathToInfoFile];
    return nil;
}

- (instancetype)initWith:(NSInteger)format
                revision:(NSInteger)revision {
    self = [super init];
    if (self) {
        _format = format;
        _revision = revision;
    }
    return self;
}

#pragma mark - Public

- (NSInteger)format {
    return _format;
}

- (NSInteger)revision {
    return _revision;
}

- (NSString *)string {
    return [NSString stringWithFormat:@"%li.%li", self.format, self.revision];
}
@end
