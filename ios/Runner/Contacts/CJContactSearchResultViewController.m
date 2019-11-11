//
//  CJContactSearchResultViewController.m
//  Runner
//
//  Created by chenyn on 2019/10/15.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "CJContactSearchResultViewController.h"
#import "CJSessionViewController.h"

@interface CJContactSearchResultViewController ()

@end

@implementation CJContactSearchResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

// 跳转聊天
- (void)createSession:(NSArray *)params
{
    NSString *sessionId = params.firstObject;
    NSNumber *type = params[1];
    
    NIMSession *session = [NIMSession session:sessionId type:type.integerValue];
    CJSessionViewController *sessionVC = [[CJSessionViewController alloc] initWithSession:session];
    [self.navigationController pushViewController:sessionVC
                                         animated:YES];
}

@end