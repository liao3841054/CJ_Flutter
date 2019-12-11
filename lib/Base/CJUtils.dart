/**
 *  Created by chenyn on 2019-06-28
 *  工具类
 */

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

Size getSize(BuildContext context) {
  final Size screenSize = MediaQuery.of(context).size;
  return screenSize;
}

double topPadding(BuildContext context) {
  final double topPadding = MediaQuery.of(context).padding.top;
  return topPadding;
}

double bottomPadding(BuildContext context) {
  final double bottomPadding = MediaQuery.of(context).padding.bottom;
  return bottomPadding;
}

final Color mainBgColor = Color(0xFFECECEC);
final Color whiteColor = Color(0xFFFCFCFC);
final Color blackColor = Color(0xFF141414);
final Color blueColor = Color(0xFF3092EE);
final Color appBarColor = Color(0xffe5e5e5);

class CJUtils {}

// 弹窗 handlerTexts <-> handlers  一一对应，不然会报错
cjDialog(BuildContext context, String title,
    {Widget content,
    String cancelText = '取消',
    Function cancelHandler,
    List<String> handlerTexts,
    List<Function> handlers}) {
  if (handlers != null && handlerTexts != null) {
    assert(handlers.length == handlerTexts.length);
  }else {
    handlerTexts = [];
    handlers = [];
  }

  showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
            title: Text(title),
            content: content,
            actions: handlerTexts.map((f) {
              int idx = handlerTexts.indexOf(f);
              Function handler = handlers[idx];

              return CupertinoDialogAction(
                onPressed: () {
                  handler();
                  Navigator.of(context).pop();
                },
                child: Text(
                  f,
                  style: TextStyle(color: Colors.red),
                ),
              );
            }).toList()
              ..add(CupertinoDialogAction(
                onPressed: () {
                  cancelHandler != null && cancelHandler();
                  Navigator.of(context).pop();
                },
                isDefaultAction: true,
                child: Text(cancelText),
              )),
          ));
}

// 底部弹窗组件 handlerTexts <-> handlers  一一对应，不然会报错
cjSheet(BuildContext context, String title,
    {Widget content,
    String cancelText = '取消',
    Function cancelHandler,
    List<String> handlerTexts,
    List<Function> handlers}) {
  if (handlers != null && handlerTexts != null) {
    assert(handlers.length == handlerTexts.length);
  }else {
    handlerTexts = [];
    handlers = [];
  }

  showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
            title: Text(title),
            message: content,
            actions: handlerTexts.map((f) {
              int idx = handlerTexts.indexOf(f);
              Function handler = handlers[idx];

              return CupertinoActionSheetAction(
                onPressed: () {
                  handler();
                  Navigator.of(context).pop();
                },
                child: Text(
                  f,
                  style: TextStyle(color: Colors.red),
                ),
              );
            }).toList(),
            cancelButton: CupertinoActionSheetAction(
              onPressed: () {
                cancelHandler != null && cancelHandler();
                Navigator.of(context).pop();
              },
              isDefaultAction: true,
              child: Text(cancelText),
            ),
          ));
}

  /// cell
  /// 绘制通用样式的列表cell
  Widget cell(Widget title, Widget accessoryView, Function onTap,
      {Widget subTitle}) {
    List<Widget> ws = subTitle == null ? [title] : [title, subTitle];

    double indent = 12;
    return new GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: indent),
        constraints: BoxConstraints(minHeight: 46),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: ws,
              ),
            ),
            Container(child: accessoryView),
          ],
        ),
      ),
    );
  }
