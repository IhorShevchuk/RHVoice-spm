//
//  NSString+Additions.h
//  RHVoice
//
//  Created by Ihor Shevchuk on 29.04.2022.
//
//  Copyright (C) 2022  Olga Yakovleva <olga@rhvoice.org>

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Additions)
+ (NSString *)RHTemporaryFolderPath;
+ (NSString *)RHTemporaryPathWithExtesnion:(NSString *)extesnion;
- (NSDictionary<NSString *, NSString *> * __nullable)RHFileAtPathToDictionary;
@end

NS_ASSUME_NONNULL_END
