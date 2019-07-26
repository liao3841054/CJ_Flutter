#import "SessionListViewControllerPlugin.h"
#import "FlutterSessionListViewController.h"

@implementation SessionListViewControllerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar
{
    // 注册flutter platform view
    [registrar registerViewFactory:[[FlutterSessionListViewControllerFactory alloc] initWithMessenger:registrar.messenger] withId:@"plugins/session_list"];
    
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"session_list_view_controller"
            binaryMessenger:[registrar messenger]];
  SessionListViewControllerPlugin* instance = [[SessionListViewControllerPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
