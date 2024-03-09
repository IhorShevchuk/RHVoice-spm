//
//  RHLanguage.m
//  RHVoiceFramework
//
//  Created by Ihor Shevchuk on 15.09.2022.
//
//  Copyright (C) 2022  Olga Yakovleva <olga@rhvoice.org>

#import <RHVoice/RHLanguage.h>
#import <RHVoice/RHSpeechSynthesisVoice.h>

#import "RHLanguage+Private.h"
#import "RHVersionInfo+Private.h"
#import "NSString+stdStringAddtitons.h"

@interface RHLanguage ()
@property(nonatomic, strong) NSString *code;
@property(nonatomic, strong) NSString *country;
@property(nonatomic, strong) RHVersionInfo *version;

@end

@implementation RHLanguage

- (NSArray<RHSpeechSynthesisVoice *> *)voices {
    
    NSArray<RHSpeechSynthesisVoice *> *result = [[RHSpeechSynthesisVoice speechVoices] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        RHSpeechSynthesisVoice *object = evaluatedObject;
        if(![object isKindOfClass:[RHSpeechSynthesisVoice class]]) {
            return NO;
        }
        return [object.language isEqual:self];
    }]];

    return result;
}

- (BOOL)isEqual:(id)object {
    RHLanguage *other = object;
    if(![other isKindOfClass:[RHLanguage class]]) {
        return NO;
    }
    
    return [[other code] isEqualToString:[self code]] &&
           [[other country] isEqual:[self country]];
}

- (NSUInteger)hash {
    return [[self code] hash] ^ [[self country] hash];
}

#pragma mark - Private

- (instancetype)initWith:(const RHVoice::language_info &)language {
    self = [super init];
    if(self) {
        self.code = STDStringToNSString(language.get_alpha2_code());
        self.country = STDStringToNSString(language.get_name());
        NSString *dataPath = STDStringToNSString(language.get_data_path());
        self.version = [[RHVersionInfo alloc] initWith:[dataPath stringByAppendingPathComponent:@"language.info"]];
    }
    return self;
}

@end
