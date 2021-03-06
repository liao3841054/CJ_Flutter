import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class WxSdk {
  static const MethodChannel _channel = const MethodChannel('wx_sdk');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /// 微信登录
  static Future<void> wxLogin() async {
    await _channel.invokeMethod('wxlogin');
  }

  /// 微信分享
  /// 目前实现了分享网页，可自行扩充
  /// type: 1:image 12:web
  static Future<void> wxShare(int type,
      {String title = '',
      String content = '',
      String url = '',
      Uint8List imgData}) async {
    await _channel.invokeMethod('share:', {
      'type': type,
      'title': title,
      'content': content,
      'url': url,
      'imgData': imgData
    });
  }

  /// 查询微信绑定状态
  static Future<bool> wxBindStatus() async {
    return await _channel.invokeMethod('wxBindStatus:');
  }

  /// 解绑微信
  static Future<bool> unBindWeChat() async {
    return await _channel.invokeMethod('unBindWeChat:');
  }
}
