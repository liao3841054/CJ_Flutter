//
//  NTESSessionUtil.m
//  NIMDemo
//
//  Created by ght on 15-1-27.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESSessionUtil.h"
#import "NIMKitInfoFetchOption.h"
#import "NIMExtensionHelper.h"
#import "CJCustomAttachmentDefines.h"

double OnedayTimeIntervalValue = 24*60*60;  //一天的秒数

static NSString *const NTESRecentSessionAtMark  = @"NTESRecentSessionAtMark";
static NSString *const NTESRecentSessionTopMark = @"NTESRecentSessionTopMark";


@implementation NTESSessionUtil

+ (CGSize)getImageSizeWithImageOriginSize:(CGSize)originSize
                                  minSize:(CGSize)imageMinSize
                                  maxSize:(CGSize)imageMaxSiz
{
    CGSize size;
    NSInteger imageWidth = originSize.width ,imageHeight = originSize.height;
    NSInteger imageMinWidth = imageMinSize.width, imageMinHeight = imageMinSize.height;
    NSInteger imageMaxWidth = imageMaxSiz.width, imageMaxHeight = imageMaxSiz.height;
    if (imageWidth > imageHeight) //宽图
    {
        size.height = imageMinHeight;  //高度取最小高度
        size.width = imageWidth * imageMinHeight / imageHeight;
        if (size.width > imageMaxWidth)
        {
            size.width = imageMaxWidth;
        }
    }
    else if(imageWidth < imageHeight)//高图
    {
        size.width = imageMinWidth;
        size.height = imageHeight *imageMinWidth / imageWidth;
        if (size.height > imageMaxHeight)
        {
            size.height = imageMaxHeight;
        }
    }
    else//方图
    {
        if (imageWidth > imageMaxWidth)
        {
            size.width = imageMaxWidth;
            size.height = imageMaxHeight;
        }
        else if(imageWidth > imageMinWidth)
        {
            size.width = imageWidth;
            size.height = imageHeight;
        }
        else
        {
            size.width = imageMinWidth;
            size.height = imageMinHeight;
        }
    }
    return size;
}

                                                 
+(BOOL)isTheSameDay:(NSTimeInterval)currentTime compareTime:(NSDateComponents*)older
{
    NSCalendarUnit currentComponents = (NSCalendarUnit)(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour | NSCalendarUnitMinute);
    NSDateComponents *current = [[NSCalendar currentCalendar] components:currentComponents fromDate:[NSDate dateWithTimeIntervalSinceNow:currentTime]];
    
    return current.year == older.year && current.month == older.month && current.day == older.day;
}

+(NSString*)weekdayStr:(NSInteger)dayOfWeek
{
    static NSDictionary *daysOfWeekDict = nil;
    daysOfWeekDict = @{@(1):@"星期日",
                       @(2):@"星期一",
                       @(3):@"星期二",
                       @(4):@"星期三",
                       @(5):@"星期四",
                       @(6):@"星期五",
                       @(7):@"星期六",};
    return [daysOfWeekDict objectForKey:@(dayOfWeek)];
}


+(NSDateComponents*)stringFromTimeInterval:(NSTimeInterval)messageTime components:(NSCalendarUnit)components
{
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:components fromDate:[NSDate dateWithTimeIntervalSince1970:messageTime]];
    return dateComponents;
}


+ (NSString *)showNick:(NSString*)uid inSession:(NIMSession*)session{
    
    NSString *nickname = nil;
    if (session.sessionType == NIMSessionTypeTeam)
    {
        NIMTeamMember *member = [[NIMSDK sharedSDK].teamManager teamMember:uid inTeam:session.sessionId];
        nickname = member.nickname;
    }
    if (!nickname.length) {
        NIMKitInfo *info = [[NIMKit sharedKit] infoByUser:uid option:nil];
        nickname = info.showName;
    }
    return nickname;
}


+(NSString*)showTime:(NSTimeInterval) msglastTime showDetail:(BOOL)showDetail
{
    //今天的时间
    NSDate * nowDate = [NSDate date];
    NSDate * msgDate = [NSDate dateWithTimeIntervalSince1970:msglastTime];
    NSString *result = nil;
    NSCalendarUnit components = (NSCalendarUnit)(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitHour | NSCalendarUnitMinute);
    NSDateComponents *nowDateComponents = [[NSCalendar currentCalendar] components:components fromDate:nowDate];
    NSDateComponents *msgDateComponents = [[NSCalendar currentCalendar] components:components fromDate:msgDate];

    NSInteger hour = msgDateComponents.hour;
    
    result = [NTESSessionUtil getPeriodOfTime:hour withMinute:msgDateComponents.minute];
    if (hour > 12)
    {
        hour = hour - 12;
    }
    if(nowDateComponents.day == msgDateComponents.day) //同一天,显示时间
    {
        result = [[NSString alloc] initWithFormat:@"%@ %zd:%02d",result,hour,(int)msgDateComponents.minute];
    }
    else if(nowDateComponents.day == (msgDateComponents.day+1))//昨天
    {
        result = showDetail?  [[NSString alloc] initWithFormat:@"昨天%@ %zd:%02d",result,hour,(int)msgDateComponents.minute] : @"昨天";
    }
    else if(nowDateComponents.day == (msgDateComponents.day+2)) //前天
    {
        result = showDetail? [[NSString alloc] initWithFormat:@"前天%@ %zd:%02d",result,hour,(int)msgDateComponents.minute] : @"前天";
    }
    else if([nowDate timeIntervalSinceDate:msgDate] < 7 * OnedayTimeIntervalValue)//一周内
    {
        NSString *weekDay = [NTESSessionUtil weekdayStr:msgDateComponents.weekday];
        result = showDetail? [weekDay stringByAppendingFormat:@"%@ %zd:%02d",result,hour,(int)msgDateComponents.minute] : weekDay;
    }
    else//显示日期
    {
        NSString *day = [NSString stringWithFormat:@"%zd-%zd-%zd", msgDateComponents.year, msgDateComponents.month, msgDateComponents.day];
        result = showDetail? [day stringByAppendingFormat:@"%@ %zd:%02d",result,hour,(int)msgDateComponents.minute]:day;
    }
    return result;
}

+ (NSString *)getPeriodOfTime:(NSInteger)time withMinute:(NSInteger)minute
{
    NSInteger totalMin = time *60 + minute;
    NSString *showPeriodOfTime = @"";
    if (totalMin > 0 && totalMin <= 5 * 60)
    {
        showPeriodOfTime = @"凌晨";
    }
    else if (totalMin > 5 * 60 && totalMin < 12 * 60)
    {
        showPeriodOfTime = @"上午";
    }
    else if (totalMin >= 12 * 60 && totalMin <= 18 * 60)
    {
        showPeriodOfTime = @"下午";
    }
    else if ((totalMin > 18 * 60 && totalMin <= (23 * 60 + 59)) || totalMin == 0)
    {
        showPeriodOfTime = @"晚上";
    }
    return showPeriodOfTime;
}


+ (void)sessionWithInputURL:(NSURL*)inputURL
                  outputURL:(NSURL*)outputURL
               blockHandler:(void (^)(AVAssetExportSession*))handler
{
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:asset
                                                                     presetName:AVAssetExportPresetMediumQuality];
    session.outputURL = outputURL;
    session.outputFileType = AVFileTypeMPEG4;   // 支持安卓某些机器的视频播放
    session.shouldOptimizeForNetworkUse = YES;
    [session exportAsynchronouslyWithCompletionHandler:^(void)
     {
         handler(session);
     }];
}


+ (NSDictionary *)dictByJsonData:(NSData *)data
{
    NSDictionary *dict = nil;
    if ([data isKindOfClass:[NSData class]])
    {
        NSError *error = nil;
        dict = [NSJSONSerialization JSONObjectWithData:data
                                               options:0
                                                 error:&error];
        if (error) {
            
        }
    }
    return [dict isKindOfClass:[NSDictionary class]] ? dict : nil;
}


+ (NSDictionary *)dictByJsonString:(NSString *)jsonString
{
    if (!jsonString.length) {
        return nil;
    }
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    return [NTESSessionUtil dictByJsonData:data];
}


+ (NSString *)tipOnMessageRevoked:(NIMRevokeMessageNotification *)notification
{
    NSString *tip = @"";
    do {
        if (!notification || ![notification isKindOfClass:[NIMRevokeMessageNotification class]]) {
            tip = @"你";
            break;
        }
        //
        NIMSession *session = notification.session;
        if (session.sessionType == NIMSessionTypeTeam) {
            tip = [self tipTitleFromMessageRevokeNotificationTeam:notification];
            break;
        }
        //
        tip = [self tipTitleFromMessageRevokeNotificationP2P:notification];
    } while (false);
    
    return [NSString stringWithFormat:@"%@撤回了一条消息", tip];
}

+ (NSString *)tipTitleFromMessageRevokeNotificationP2P:(NIMRevokeMessageNotification *)notification {
    NSString *fromUid = notification.messageFromUserId;
    BOOL fromMe = [fromUid isEqualToString:[[NIMSDK sharedSDK].loginManager currentAccount]];
    return fromMe ? @"你" : @"对方";
}

+ (NSString *)tipTitleFromMessageRevokeNotificationTeam:(NIMRevokeMessageNotification *)notification {
    NSString *tipTitle = @"";
    
    do {
        NSString *fromUid = notification.messageFromUserId;
        NSString *operatorUid = notification.fromUserId;
        BOOL revokeBySender = !operatorUid || [operatorUid isEqualToString:fromUid];
        BOOL fromMe = [fromUid isEqualToString:[[NIMSDK sharedSDK].loginManager currentAccount]];
        
        // 自己撤回自己的
        if (revokeBySender && fromMe) {
            tipTitle = @"你";
            break;
        }
        
        NIMSession *session = notification.session;
        NIMKitInfoFetchOption *option = [[NIMKitInfoFetchOption alloc] init];
        option.session = session;
        NIMKitInfo *info = [[NIMKit sharedKit] infoByUser:(revokeBySender ? fromUid : operatorUid) option:option];
        
        // 别人撤回自己的
        if (revokeBySender) {
            tipTitle = info.showName;
            break;
        }
        
        NIMTeamMember *member = [[NIMSDK sharedSDK].teamManager teamMember:operatorUid inTeam:session.sessionId];
        // 被群主/管理员撤回的
        if (member.type == NIMTeamMemberTypeOwner) {
            tipTitle = [@"群主" stringByAppendingString:info.showName];
        }
        else if (member.type == NIMTeamMemberTypeManager) {
            tipTitle = [@"管理员" stringByAppendingString:info.showName];
        }
    } while (false);
    
    return tipTitle;
}


+ (BOOL)canMessageBeForwarded:(NIMMessage *)message
{
    if (!message.isReceivedMsg && message.deliveryState == NIMMessageDeliveryStateFailed) {
        return NO;
    }
    id<NIMMessageObject> messageObject = message.messageObject;
    if ([messageObject isKindOfClass:[NIMCustomObject class]])
    {
        id<CJCustomAttachmentInfo> attach = (id<CJCustomAttachmentInfo>)[(NIMCustomObject *)message.messageObject attachment];
        return [attach canBeForwarded];
    }
    if ([messageObject isKindOfClass:[NIMNotificationObject class]]) {
        return NO;
    }
    if ([messageObject isKindOfClass:[NIMTipObject class]]) {
        return NO;
    }
    if ([messageObject isKindOfClass:[NIMRobotObject class]]) {
        NIMRobotObject *robotObject = (NIMRobotObject *)messageObject;
        return !robotObject.isFromRobot;
    }
    return YES;
}

+ (BOOL)canMessageBeRevoked:(NIMMessage *)message
{
    BOOL canRevokeMessageByRole  = [self canRevokeMessageByRole:message];
    BOOL isDeliverFailed = !message.isReceivedMsg && message.deliveryState == NIMMessageDeliveryStateFailed;
    if (!canRevokeMessageByRole || isDeliverFailed) {
        return NO;
    }
    id<NIMMessageObject> messageObject = message.messageObject;
    if ([messageObject isKindOfClass:[NIMTipObject class]]
        || [messageObject isKindOfClass:[NIMNotificationObject class]]) {
        return NO;
    }
    if ([messageObject isKindOfClass:[NIMCustomObject class]])
    {
        id<CJCustomAttachmentInfo> attach = (id<CJCustomAttachmentInfo>)[(NIMCustomObject *)message.messageObject attachment];
        return [attach canBeRevoked];
    }
    return YES;
}

+ (BOOL)canMessageBeCanceled:(NIMMessage *)message
{
    return [self canMessageBeRevoked:message] &&
    message.deliveryState == NIMMessageDeliveryStateDelivering;
}


+ (BOOL)canRevokeMessageByRole:(NIMMessage *)message
{
    BOOL isFromMe  = [message.from isEqualToString:[[NIMSDK sharedSDK].loginManager currentAccount]];
    BOOL isToMe        = [message.session.sessionId isEqualToString:[[NIMSDK sharedSDK].loginManager currentAccount]];
    BOOL isTeamManager = NO;
    if (message.session.sessionType == NIMSessionTypeTeam)
    {
        NIMTeamMember *member = [[NIMSDK sharedSDK].teamManager teamMember:[NIMSDK sharedSDK].loginManager.currentAccount inTeam:message.session.sessionId];
        isTeamManager = member.type == NIMTeamMemberTypeOwner || member.type == NIMTeamMemberTypeManager;
    }
    
    BOOL isRobotMessage = NO;
    id<NIMMessageObject> messageObject = message.messageObject;
    if ([messageObject isKindOfClass:[NIMRobotObject class]]) {
        NIMRobotObject *robotObject = (NIMRobotObject *)messageObject;
        isRobotMessage = robotObject.isFromRobot;
    }
    //我发出去的消息并且不是发给我的电脑的消息，可以撤回
    //群消息里如果我是管理员可以撤回以上所有消息
    return (isFromMe && !isToMe && !isRobotMessage) || isTeamManager;
}


+ (void)addRecentSessionMark:(NIMSession *)session type:(NTESRecentSessionMarkType)type
{
    NIMRecentSession *recent = [[NIMSDK sharedSDK].conversationManager recentSessionBySession:session];
    if (recent)
    {
        NSDictionary *localExt = recent.localExt?:@{};
        NSMutableDictionary *dict = [localExt mutableCopy];
        NSString *key = [NTESSessionUtil keyForMarkType:type];
        [dict setObject:@(YES) forKey:key];
        [[NIMSDK sharedSDK].conversationManager updateRecentLocalExt:dict recentSession:recent];
    }


}

+ (void)removeRecentSessionMark:(NIMSession *)session type:(NTESRecentSessionMarkType)type
{
    NIMRecentSession *recent = [[NIMSDK sharedSDK].conversationManager recentSessionBySession:session];
    if (recent) {
        NSMutableDictionary *localExt = [recent.localExt mutableCopy];
        NSString *key = [NTESSessionUtil keyForMarkType:type];
        [localExt removeObjectForKey:key];
        [[NIMSDK sharedSDK].conversationManager updateRecentLocalExt:localExt recentSession:recent];
    }
}

+ (BOOL)recentSessionIsMark:(NIMRecentSession *)recent type:(NTESRecentSessionMarkType)type
{
    NSDictionary *localExt = recent.localExt;
    NSString *key = [NTESSessionUtil keyForMarkType:type];
    return [localExt[key] boolValue] == YES;
}

+ (NSString *)keyForMarkType:(NTESRecentSessionMarkType)type
{
    static NSDictionary *keys;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keys = @{
                 @(NTESRecentSessionMarkTypeAt)  : NTESRecentSessionAtMark,
                 @(NTESRecentSessionMarkTypeTop) : NTESRecentSessionTopMark
                 };
    });
    return [keys objectForKey:@(type)];
}

@end
