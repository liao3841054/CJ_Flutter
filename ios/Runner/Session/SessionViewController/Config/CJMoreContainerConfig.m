//
//  CJMoreContainerConfig.m
//  Runner
//
//  Created by chenyn on 2019/9/20.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "CJMoreContainerConfig.h"
#import "CJContactSelectConfig.h"
#import <YouXiPayUISDK/YouXiPayUISDK.h>
#import "CJContactSelectViewController.h"
#import "JRMFHeader.h"
#import "CJPayManager.h"
#import "NTESSessionUtil.h"
#import "CJContactSelectViewController.h"
#import "CJUtilBridge.h"
#import "CJShareMsgInteractor.h"

ZZAvatarModel *cj_convertModel(NIMUser *obj)
{
    ZZAvatarModel *avatar = [ZZAvatarModel new];
    avatar.u_id = obj.userId;
    avatar.avatarUrl = obj.userInfo.avatarUrl;
    avatar.gender = obj.userInfo.gender;
    return avatar;
}

@implementation CJMoreContainerConfig

- (NSArray<NIMMediaItem *> *)mediaItems
{
    NSMutableArray *mediaItems = @[[NIMMediaItem item:@"onTapMediaItemPicture:"
                                         normalImage:[UIImage imageNamed:@"bk_media_picture_normal"]
                                       selectedImage:[UIImage imageNamed:@"bk_media_picture_nomal_pressed"]
                                               title:@"照片"],
                                   
                                  [NIMMediaItem item:@"onTapMediaItemShoot:"
                                         normalImage:[UIImage imageNamed:@"bk_media_shoot_normal"]
                                       selectedImage:[UIImage imageNamed:@"bk_media_shoot_pressed"]
                                               title:@"拍摄"]].mutableCopy;
    
//    NIMMediaItem *cajianRP  = [NIMMediaItem item:@"onTapMediaItemCajianRP:onSessionVC:"
//                                      normalImage:[UIImage imageNamed:@"icon_redpacket_normal"]
//                                    selectedImage:[UIImage imageNamed:@"icon_redpacket_pressed"]
//                                            title:@"红包"];


    NIMMediaItem *cloudRP  = [NIMMediaItem item:@"onTapMediaItemCloudRedPacket:onSessionVC:"
                                     normalImage:[UIImage imageNamed:@"icon_MFRedpacket"]
                                   selectedImage:[UIImage imageNamed:@"icon_MFRedpacket_pressed"]
                                           title:@"云红包"];
    
    NIMMediaItem *yeeRP  = [NIMMediaItem item:@"onTapMediaItemYeePacket:onSessionVC:"
                                     normalImage:[UIImage imageNamed:@"icon_yee_normal"]
                                   selectedImage:[UIImage imageNamed:@"icon_yee_pressed"]
                                           title:@"易红包"];
    
//    NIMMediaItem *yeeTransfer  = [NIMMediaItem item:@"onTapMediaItemYXTransfer:onSessionVC:"
//                                       normalImage:[UIImage imageNamed:@"icon_yee_transfer_normal"]
//                                     selectedImage:[UIImage imageNamed:@"icon_yee_transfer_pressed"]
//                                             title:@"易转账"];
    
    NIMMediaItem *profileCard  = [NIMMediaItem item:@"onTapMediaItemProfileCard:onSessionVC:"
                                       normalImage:[UIImage imageNamed:@"bk_media_card_normal"]
                                     selectedImage:[UIImage imageNamed:@"bk_media_card_pressed"]
                                             title:@"名片"];
    
//    NIMMediaItem *aliPayCode  = [NIMMediaItem item:@"onTapMediaItemAliPayCode:onSessionVC:"
//                                         normalImage:[UIImage imageNamed:@"icon_team_paycode_normal"]
//                                       selectedImage:[UIImage imageNamed:@"icon_team_paycode_pressed"]
//                                               title:@"收款码"];
    
//    NIMMediaItem *personStamp  = [NIMMediaItem item:@"onTapMediaItemPersonalstamp:onSessionVC:"
//                                        normalImage:[UIImage imageNamed:@"icon_team_stamp_normal"]
//                                      selectedImage:[UIImage imageNamed:@"icon_team_stamp_pressed"]
//                                              title:@"抖一抖"];
    
//    NIMMediaItem *teamNotice  = [NIMMediaItem item:@"onTapMediaItemTeamNotice:onSessionVC:"
//                                       normalImage:[UIImage imageNamed:@"icon_team_notice_normal"]
//                                     selectedImage:[UIImage imageNamed:@"icon_team_notice_pressed"]
//                                             title:@"群通知"];
    
//    NIMMediaItem *collection = [NIMMediaItem item:@"onTapMediaItemCollection:onSessionVC:"
//                                            normalImage:[UIImage imageNamed:@"icon_team_collection_normal"]
//                                          selectedImage:[UIImage imageNamed:@"icon_team_collection_pressed"]
//                                                  title:@"收藏"];
    
//    NIMMediaItem *location = [NIMMediaItem item:@"onTapMediaItemLocation:onSessionVC:"
//                                          normalImage:[UIImage imageNamed:@"bk_media_position_normal"]
//                                        selectedImage:[UIImage imageNamed:@"bk_media_position_pressed"]
//                                                title:@"位置"];
    
    [mediaItems addObjectsFromArray:@[yeeRP, cloudRP, profileCard]];
    
    return mediaItems;
}

+ (void)onTapMediaItemCajianRP:(NIMMediaItem *)item
                   onSessionVC:(NIMSessionViewController *)vc
{
    // 擦肩红包
    
}

+ (void)onTapMediaItemCloudRedPacket:(NIMMediaItem *)item
                         onSessionVC:(NIMSessionViewController <MFManagerDelegate>*)vc
{
    // 云红包
    MFPacket *jrmf = [MFPacket new];
    jrmf.delegate = vc;
    NSString *me = [[NIMSDK sharedSDK].loginManager currentAccount];
    NIMSession *session = vc.session;
    NSString *nickName = [NTESSessionUtil showNick:me inSession:session];
    NSString *headUrl = [[NIMKit sharedKit] infoByUser:me option:nil].avatarUrlString;
    
    NIMTeam *team = nil;
    if (session.sessionType == NIMSessionTypeTeam)
    {
        if ([[NIMSDK sharedSDK].teamManager isMyTeam:session.sessionId])
        {
            team = [[NIMSDK sharedSDK].teamManager teamById:session.sessionId];
        }
        else
        {
            [UIViewController showError:@"不在群中，无法发送红包"];
        }
    }
    
    [jrmf doActionPresentSendRedEnvelopeViewController:cj_rootNavigationController()
                                            thirdToken:[JRMFSington GetPacketSington].MFThirdToken
                                             withGroup:(team != nil)
                                             receiveID:session.sessionId
                                          sendUserName:nickName
                                          sendUserHead:headUrl
                                            sendUserID:me
                                           groupNumber:@(team.memberNumber).description];
}

+ (void)onTapMediaItemYeePacket:(NIMMediaItem *)item
                    onSessionVC:(NIMSessionViewController *)vc
{
    // 易红包
    NSInteger num = 0;
    if(vc.session.sessionType != NIMSessionTypeP2P)
    {
        num = [[NIMSDK sharedSDK].teamManager teamById:vc.session.sessionId].memberNumber;
    }
    
    [ZZPayUI showSendRedPEditView:vc
                        sessionId:vc.session.sessionId
                        memberNum:num
                           isTeam:vc.session.sessionType != NIMSessionTypeP2P
         jumpToTeamMemberSelector:^(selectedIds  _Nonnull callBack, NSArray *crtIds)
     {
         
         CJContactTeamMemberSelectConfig *config = [CJContactTeamMemberSelectConfig new];
         config.maxSelectMemberCount = 5;
         config.needMutiSelected = YES;
         config.teamId = vc.session.sessionId;
         config.alreadySelectedMemberId = crtIds;
         config.title = @"选择指定领取人";
         CJContactSelectViewController *vc = [[CJContactSelectViewController alloc] initWithConfig:config];
         
         vc.finished = ^(NSArray * _Nonnull ids) {
              [[NIMSDK sharedSDK].userManager fetchUserInfos:ids completion:^(NSArray<NIMUser *> * _Nullable users, NSError * _Nullable error)
             {
                 
                  NSMutableArray *mutArr = @[].mutableCopy;
                  [users enumerateObjectsUsingBlock:^(NIMUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
                 {
                      [mutArr addObject:cj_convertModel(obj)];
                  }];
                  callBack(mutArr);
              }];
         };
         
         // 指定人选择页
         return vc;
     }];
    
}

+ (void)onTapMediaItemYXTransfer:(NIMMediaItem *)item
                     onSessionVC:(NIMSessionViewController *)vc
{
    // TODO:易转账  CJPayManager
}

+ (void)onTapMediaItemProfileCard:(NIMMediaItem *)item
                      onSessionVC:(NIMSessionViewController *)vc
{
    /// 发送好友名片
    CJContactFriendSelectConfig *config = [CJContactFriendSelectConfig new];
    config.needMutiSelected = NO;
    
    CJContactSelectViewController *selectVC = [[CJContactSelectViewController alloc] initWithConfig:config];
    selectVC.finished = ^(NSArray * _Nonnull ids) {
        if(cj_empty_array(ids)) {
            return;
        }
        /// 发送
        NIMKitInfo *info = [[NIMKit sharedKit] infoByUser:ids.firstObject option:nil];
        CJShareBusinessCardModel *model = [CJShareBusinessCardModel new];
        model.accid = info.infoId;
        model.nickName = info.showName ?: @"";
        model.imageUrl = info.avatarUrlString ?: @"";
        
        [CJShareMsgInteractor shareModel:model to:vc.session];
    };
    
    CJNavigationViewController *nav = [[CJNavigationViewController alloc] initWithRootViewController:selectVC];
    [cj_rootNavigationController() presentViewController:nav
                                                animated:YES
                                              completion:nil];
}

+ (void)onTapMediaItemAliPayCode:(NIMMediaItem *)item
                     onSessionVC:(NIMSessionViewController *)vc
{
    // TODO:收款码
}

+ (void)onTapMediaItemPersonalstamp:(NIMMediaItem *)item
                        onSessionVC:(NIMSessionViewController *)vc
{
    // 抖一抖
    
}

+ (void)onTapMediaItemTeamNotice:(NIMMediaItem *)item
                     onSessionVC:(NIMSessionViewController *)vc
{
    // TODO:群通知
}

+ (void)onTapMediaItemCollection:(NIMMediaItem *)item
onSessionVC:(NIMSessionViewController *)vc
{
    // TODO:发收藏
}

+ (void)onTapMediaItemLocation:(NIMMediaItem *)item
                   onSessionVC:(NIMSessionViewController *)vc
{
    // TODO:发定位
}


@end
