//
//  NSString+Additions.m
//  RHVoice
//
//  Created by Ihor Shevchuk on 29.04.2022.
//
//  Copyright (C) 2022  Olga Yakovleva <olga@rhvoice.org>

#import "NSString+Additions.h"

#import "RHVoiceLogger.h"

#include <string>

@implementation NSString (Additions)

- (size_t)RHutf8Size {
    std::string string = self.UTF8String;
    return string.size();
}

- (NSRange)RHutf16RangeFromUTF8:(NSRange)range
                 utf8StartIndex:(NSInteger)utf8Index
                utf16StartIndex:(NSInteger)utf16Index
{
    NSUInteger location = NSNotFound;
    NSUInteger length = 0;
    
    NSUInteger len = [self length];
    unichar buffer[len+1];
    [self getCharacters:buffer range:NSMakeRange(0, len)];
    
    NSInteger index = utf8Index;
    NSInteger size = 0;
    
    for(NSInteger i = utf16Index; i < len; i++) {
        unichar uniChar = buffer[i];
        NSString *nsChar = [NSString stringWithFormat:@"%C", uniChar];
        const size_t sizeOfCharacter = nsChar.RHutf8Size;
        index += sizeOfCharacter;
        
        const BOOL isLocationFound = location != NSNotFound;
        
        if(isLocationFound) {
            size += sizeOfCharacter;
        }
        
        if(index == range.location) {
            location = i + 1;
            size = 0;
        }
        
        if(isLocationFound && size == range.length) {
            length = i - location + 1;
            break;
        }
    }
    
    if(length == 0) {
        return NSMakeRange(NSNotFound, 0);
    }
    
    return NSMakeRange(location, length);
}

- (NSRange)RHutf16RangeFromUTF8:(NSRange)range {
    return [self RHutf16RangeFromUTF8:range
                       utf8StartIndex:0
                      utf16StartIndex:0];
}

- (NSDictionary<NSString *, NSString *> * __nullable)RHFileAtPathToDictionary {
    NSError *error = nil;
    NSString *stringInfo = [NSString stringWithContentsOfFile:self encoding:NSUTF8StringEncoding error: &error];
    if(error) {
        [RHVoiceLogger logAtLevel:RHVoiceLogLevelError format:@"Can not read file due to the error:%@", error];
        return nil;
    }
    NSArray <NSString *> *arrayOfPairs = [stringInfo componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
    if(arrayOfPairs.count == 0) {
        [RHVoiceLogger logAtLevel:RHVoiceLogLevelError format:@"File is empty. Returning nil"];
        return nil;
    }
    NSMutableArray<NSString *> *keys = [[NSMutableArray alloc] initWithCapacity:arrayOfPairs.count];
    NSMutableArray<NSString *> *values = [[NSMutableArray alloc] initWithCapacity:arrayOfPairs.count];
    for(NSString *pair in arrayOfPairs) {
        if(pair.length == 0) {
            continue;
        }
        NSArray *keyValue = [pair componentsSeparatedByString:@"="];
        
        NSString *key = [keyValue firstObject];
        NSString *value = [keyValue lastObject];
        
        if(keyValue.count == 2 &&
           key.length > 0 &&
           value.length > 0) {
            [keys addObject:key];
            [values addObject:value];
        } else {
            [RHVoiceLogger logAtLevel:RHVoiceLogLevelWarning format:@"Skipping pair(%@) because it does not contain required format: key=value", pair];
        }
    }
    
    return [[NSDictionary alloc] initWithObjects:values forKeys:keys];;
}

+ (NSString *)RHTemporaryFolderPath {
    return [NSTemporaryDirectory() stringByAppendingPathComponent:@"RHVoice"];
}

+ (NSString *)RHTemporaryPathWithExtesnion:(NSString *)extesnion {
    NSString *uuidString = [NSUUID UUID].UUIDString;
    return [[self RHTemporaryFolderPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", uuidString, extesnion]];
}
@end
