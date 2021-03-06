//
//  CJSessionViewController.m
//  Runner
//
//  Created by chenyn on 2019/9/20.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "CJSessionViewController.h"
#import "NIMInputMoreContainerView.h"
#import "CJMoreContainerConfig.h"
#import "CJCustomAttachmentDefines.h"
#import "CJShareMsgInteractor.h"

@interface CJSessionViewController ()

@property (nonatomic,strong) CJMoreContainerConfig *sessionConfig;

@end

@implementation CJSessionViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// flutter boost 协议
- (instancetype)initWithBoostParams:(NSDictionary *)boost_params
{
    NIMSession *session = [NIMSession session:boost_params[@"id"]
                   type:[boost_params[@"type"] integerValue]];
    self = [super initWithSession:session];
    if(self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    /* 配置导航条按钮 */
    [self setUpNavBarItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCJUpdateMessageNotification:)
                                                 name:CJUpdateMessageNotification
                                               object:nil];
    
    /// 处理分享数据
    [self handleShareData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 判断我是否还在这个群
    if(self.session.sessionType != 0) {
        bool isMyTeam = [[NIMSDK sharedSDK].teamManager isMyTeam:self.session.sessionId];
        if(!isMyTeam) {
            self.navigationItem.rightBarButtonItems = @[];
        }
    }
}

/// 处理分享数据
- (void)handleShareData
{
    if(self.shareModel) {
        [CJShareMsgInteractor shareModel:self.shareModel to:self.session];
        self.shareModel = nil;
    }
}

/* 重新修改session配置 */
- (id<NIMSessionConfig>)sessionConfig
{
    if (_sessionConfig == nil) {
        _sessionConfig = [[CJMoreContainerConfig alloc] init];
        _sessionConfig.session = self.session;
    }
    return _sessionConfig;
}

- (void)setUpNavBarItem
{
    UIButton *enterTeamCard = [UIButton buttonWithType:UIButtonTypeCustom];
    [enterTeamCard addTarget:self action:@selector(enterSessionInfoPage:) forControlEvents:UIControlEventTouchUpInside];
    [enterTeamCard setImage:[UIImage imageNamed:@"icon_session_info_normal"] forState:UIControlStateNormal];
    [enterTeamCard setImage:[UIImage imageNamed:@"icon_session_info_pressed"] forState:UIControlStateHighlighted];
    [enterTeamCard sizeToFit];
    
    UIBarButtonItem *enterTeamCardItem = [[UIBarButtonItem alloc] initWithCustomView:enterTeamCard];
    
    self.navigationItem.rightBarButtonItems = @[enterTeamCardItem];
}

#pragma mark - override
- (BOOL)onTapCell:(NIMKitEvent *)event
{
    BOOL handle = NO;
    if([event.messageModel.message.messageObject isKindOfClass:NIMCustomObject.class])
    {
        // 自定义消息事件分发
        NIMCustomObject *object = (NIMCustomObject *)event.messageModel.message.messageObject;
        id<CJCustomAttachment> attachment = (id<CJCustomAttachment>)object.attachment;
        if([attachment respondsToSelector:@selector(handleTapCellEvent:onSession:)])
        {
            [attachment handleTapCellEvent:event onSession:self];
        }
    }else {
        handle = [super onTapCell:event];
    }
    
    return handle;
}


#pragma mark - NIMMeidaButton
- (BOOL)onTapMediaItem:(NIMMediaItem *)item
{
    BOOL handled = NO;
    SEL sel = item.selctor;
    
    // 将代理方法抽离到CJMoreContainerConfig 配置类中
    handled = sel && [CJMoreContainerConfig respondsToSelector:sel];
    if (handled) {
        [CJMoreContainerConfig performSelector:sel withObject:item withObject:self];
        handled = YES;
    }else if(sel && [super respondsToSelector:sel])
    {
        CJ_SuppressPerformSelectorLeakWarning([super performSelector:sel withObject:item]);
        handled = YES;
    }
    return handled;
}

#pragma mark ---- MFManagerDelegate 云红包服务协议

/// 调服务端接口发送云红包 / 服务端收到jrmf通知也会发
- (void)doMFActionSendRedPacketWith:(MFPacketModel *)model withStatus:(MFSendStatus)status
{
    if(status == kMFStatSucess) {
        co_launch(^{
            [self sendCloudRedPacket:model];
        });
    }
}

- (void)sendCloudRedPacket:(MFPacketModel *)model
{
    NSString *uid = [[NIMSDK sharedSDK].loginManager currentAccount];
    NIMSession *session = self.session;
    
    if(!uid || ! session.sessionId) {
        return;
    }
    /* 0:成功 -1:失败 1:取消
     {"from":"a", "ope":0, "to":"b", "tag_id":"1", "request_body":"body", "status": 0}
     */
    
    NSString *number = [NSString stringWithFormat:@"%@", @(model.numberOfPackets)];
    NSString *money_str = @"";
    if (model.packetType == RedPacketTypeGroupNormal) {
        money_str = [NSString stringWithFormat:@"%@",@([model.numberOfMoney integerValue]*model.numberOfPackets*0.01)];
    }else{
        money_str = [NSString stringWithFormat:@"%@",@([model.numberOfMoney integerValue]*0.01)];
    }
    NSDictionary *dic = @{@"custUid": cj_not_nil_object(uid),
                          @"isGroup": [NSString stringWithFormat:@"%@", @(MIN(session.sessionType, 1))],
                          @"groupId": cj_not_nil_object(session.sessionType? session.sessionId : @""),
                          @"receiveCustUid": cj_not_nil_object(session.sessionType? @"": session.sessionId),
                          @"redEnvelopeId": cj_not_nil_object(model.packetId?:@""),
                          @"content": cj_not_nil_object(model.packetSummary?:@""),
                          @"money": cj_not_nil_object(money_str ? : @""),
                          @"number": cj_not_nil_object(number),
                          @"tradeType":@"0"
                          };
    
//    [UIViewController showLoadingWithMessage:@"正在发送红包..."];
    await([HttpHelper post:@"https://api.youxi2018.cn/g2/lq/packet/send" params:dic]);
//    [UIViewController hideHUD];
}


#pragma mark - private
/// 进入聊天详情页
- (void)enterSessionInfoPage:(id)sender
{
    [FlutterBoostPlugin open:@"session_info"
                   urlParams:@{@"id": self.session.sessionId, @"type": @(self.session.sessionType)}
                        exts:@{@"animated": @(YES)}
              onPageFinished:^(NSDictionary *result) {}
                  completion:nil];
}

// 刷新消息
- (void)onCJUpdateMessageNotification:(NSNotification *)n
{
    id  object = n.object;
    if (object != nil && [object isKindOfClass:[NIMMessage class]]) {
        NIMMessage* message = (NIMMessage*)object;
        if (message) {
            // 更新消息内容
            [self uiUpdateMessage:message];
        }
    }
}


@end
