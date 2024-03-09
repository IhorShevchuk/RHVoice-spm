//
//  RHVersionInfo.h
//  RHVoiceFramework
//
//  Created by Ihor Shevchuk on 18.09.2022.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RHVersionInfo : NSObject
@property (nonatomic, readonly) NSInteger format;
@property (nonatomic, readonly) NSInteger revision;
- (NSString *)string;
@end

NS_ASSUME_NONNULL_END
