//
//  CJViewController.h
//  Runner
//
//  Created by chenyn on 2019/8/6.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface CJViewController : FlutterViewController

// 获取当前页面初始化参数
@property (nonatomic, copy, readonly, nullable) NSDictionary *params;
// 获取当前页面openUrl
@property (nonatomic, copy, readonly, nullable) NSString *openUrl;

/**
 初始化一个flutter 页面，以FlutterVC为容器

 \\******
 需要的JSON字符串格式如下
 {
 'container':'CJViewController'     //  容器类名字对应到native的类，不填默认为CJViewController
 'route':'login',
 'channel_name':'com.zqtd.cajian/login',
 'params':{
    'team_id':'298ssdj9238'
    }
 }
 *******\\
 @param openUrl 页面初始化路由和参数
 
 @return 返回VC
 */
- (instancetype)initWithFlutterOpenUrl:(NSString *)openUrl;

@end

NS_ASSUME_NONNULL_END
