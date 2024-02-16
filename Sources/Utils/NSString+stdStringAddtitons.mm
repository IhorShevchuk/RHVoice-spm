//
//  NSString+stdStringAddtitons.m
//  RHVoiceFramework
//
//  Created by Ihor Shevchuk on 24.11.2022.
//
//  Copyright (C) 2022  Olga Yakovleva <olga@rhvoice.org>

#import <Foundation/Foundation.h>

#import "NSString+stdStringAddtitons.h"

NSString *STDStringToNSString(std::string stdString) {
    const char *cString = stdString.c_str();
    if(cString == NULL) {
        return @"";
    }
    return [NSString stringWithUTF8String:cString];
}
