//
//  CJNotificationCenter.h
//  Runner
//
//  Created by chenyn on 2019/9/23.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CJNotificationCenter : NSObject

+ (instancetype)sharedCenter;
- (void)start;

@end

NS_ASSUME_NONNULL_END
