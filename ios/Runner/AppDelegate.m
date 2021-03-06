#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import "CJFlutterViewController.h"
#import "CJLoginViewController.h"
#import "CJFlutterViewController.h"
#import <nim_sdk_util/NimSdkUtilPlugin.h>
#import <WxSdkPlugin.h>
#import "CJCustomAttachmentDecoder.h"
#import "CJCellLayoutConfig.h"
#import "CJNotificationCenter.h"
#import "CJPayManager.h"
#import "PlatformRouterImp.h"
#import "CJUtilBridge.h"
#import "CJTabbarController.h"

@interface AppDelegate ()

@property (nonatomic, strong)PlatformRouterImp *router;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 注册微信sdk
    [WXApi registerApp:CJWxAppKey];
    // 配置云信服务
    [self configNIMServices];
    // 注册推送服务
    [self registerPushService];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didLogout)
                                                 name:@"didLogout"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didLogin)
                                                 name:@"didLogin"
                                               object:nil];
    
    /* 登录回调代理 */
    [[NIMSDK sharedSDK].loginManager addDelegate:self];
    
    /*根据登录状态初始化登录页面 vc*/
    NSString *accid = [[NSUserDefaults standardUserDefaults] objectForKey:@"flutter.accid"];
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"flutter.token"];
    
    // 初始化flutter
    _router = [PlatformRouterImp new];
    [FlutterBoostPlugin.sharedInstance startFlutterWithPlatform:_router
                                                        onStart:^(FlutterEngine *engine) {
        [[CJUtilBridge alloc] initBridge];
    }];
    if(accid && token) {
        [NimSdkUtilPlugin autoLogin:accid token:token];
    }else {
        [self showDidLogoutRootVC];
    }
    
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)configNIMServices
{
    // 注册云信sdk
    [NimSdkUtilPlugin registerSDK];
    //注册自定义消息的解析器
    [NIMCustomObject registerCustomDecoder:[CJCustomAttachmentDecoder new]];
    //注入 NIMKit 自定义排版配置
    [[NIMKit sharedKit] registerLayoutConfig:[CJCellLayoutConfig new]];
    //启动消息通知
    [[CJNotificationCenter sharedCenter] start];
}

- (BOOL)application:(UIApplication *)application
      handleOpenURL:(NSURL *)url {
    return  [WXApi handleOpenURL:url delegate:[WxSdkPlugin new]];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [WXApi handleOpenURL:url delegate:[WxSdkPlugin new]];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    return [WXApi handleOpenURL:url delegate:[WxSdkPlugin new]];
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[NIMSDK sharedSDK] updateApnsToken:deviceToken];
}

/// 注册推送服务
- (void)registerPushService
{
    if (@available(iOS 11.0, *))
    {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (!granted)
            {
                cj_dispatch_async_main_safe(^{
                    [UIViewController showMessage:@"请开启推送功能否则无法收到推送通知" afterDelay:2.0f];
                })
            }
        }];
    }
    else
    {
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

#pragma mark - 登录，这里只做UI和第三方库处理

- (void)didLogout
{
    // 接收通知回调
    [[CJPayManager sharedManager] didLogout];
    
    [self showDidLogoutRootVC];
}

- (void)didLogin
{
    [self showDidLoginSuccessRootVC];
}

// 展示登录成功的页面根视图
- (void)showDidLoginSuccessRootVC
{
    CJTabbarController *tabbar = [[CJTabbarController alloc] initWithRootViewControllers];
    
    CJNavigationViewController *root = [[CJNavigationViewController alloc] initWithRootViewController:tabbar];
    
    self.window.rootViewController = root;
    self.tabbar = tabbar;
    
    _router.navigationController = root;
}

// 展示登出成功的页面根视图
- (void)showDidLogoutRootVC
{
    CJLoginViewController *loginVC = [[CJLoginViewController alloc] init];
    CJNavigationViewController *root = [[CJNavigationViewController alloc] initWithRootViewController:loginVC];
    
    self.window.rootViewController = root;
    _router.navigationController = root;
}

#pragma mark - NIMLoginManagerDelegate

- (void)onLogin:(NIMLoginStep)step
{
    switch (step) {
        case NIMLoginStepLinking:
            [UIViewController showLoadingWithMessage:@"正在连接服务器～"];
            break;
        case NIMLoginStepLinkFailed:
            [UIViewController showError:@"连接服务器失败"];
            break;
        case NIMLoginStepLoginOK:
            [[CJPayManager sharedManager] didLogin];
            [UIViewController showSuccess:@"登录成功"];
            break;
        case NIMLoginStepLoginFailed:
            [UIViewController showError:@"登录失败"];
            break;
        default:
            break;
    }
    
}

- (void)onAutoLoginFailed:(NSError *)error
{
    [self showDidLogoutRootVC];
}

- (void)onKick:(NIMKickReason)code
    clientType:(NIMLoginClientType)clientType
{
    NSString *reason = @"你被踢下线";
    switch (code) {
        case NIMKickReasonByClient:
        case NIMKickReasonByClientManually:{
            reason = @"你的帐号被踢出下线，请注意帐号信息安全";
            break;
        }
        case NIMKickReasonByServer:
            reason = @"你已被服务器踢下线";
            break;
        default:
            break;
    }
    // 登出逻辑
    [NimSdkUtilPlugin logout];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"⚠️"
                                                                   message:reason
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                              style:UIAlertActionStyleDefault
                                            handler:nil]];
    [self.window.rootViewController presentViewController:alert
                                                 animated:YES
                                               completion:nil];
}

@end
