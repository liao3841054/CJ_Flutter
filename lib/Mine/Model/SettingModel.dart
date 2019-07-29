
/**
 *  Created by chenyn on 2019-07-23
 *  设置cell model
 */
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cajian/Login/LoginManager.dart';
import 'package:cajian/Base/CJUtils.dart';

enum SettingCellType {
  Function,    // 功能按钮
  Accessory,   // 入口
  Separator,   // 分割
} 

typedef TapCallback = void Function(BuildContext ctx);
class SettingModel {
  @required SettingCellType cellType;
  String title;
  String subTitle;
  Color  titleColor;
  TapCallback onTap;
  bool needSeparatorLine;

  SettingModel(
    this.cellType, 
    this.title, 
    this.subTitle, 
    this.titleColor, 
    this.onTap, 
    {this.needSeparatorLine = true}
  );
}


final List<SettingModel> settingCellModels = [
  SettingModel(SettingCellType.Accessory, '安全', null, null, (BuildContext ctx){

  }),
  SettingModel(SettingCellType.Accessory, '绑定微信', '未绑定', null, (BuildContext ctx){

  }, needSeparatorLine: false),

  SettingModel(SettingCellType.Separator, null, null, null, null, needSeparatorLine: false),

  SettingModel(SettingCellType.Accessory, '新消息通知', null, null, (BuildContext ctx){

  }),

  SettingModel(SettingCellType.Accessory, '黑名单', null, null, (BuildContext ctx){

  }),

  SettingModel(SettingCellType.Accessory, '清理缓存', null, null, (BuildContext ctx){

  }, needSeparatorLine: false),

  SettingModel(SettingCellType.Separator, null, null, null, null, needSeparatorLine: false),

  SettingModel(SettingCellType.Accessory, '关于', null, null, (BuildContext ctx){

  }, needSeparatorLine: false),

  SettingModel(SettingCellType.Separator, null, null, null, null, needSeparatorLine: false),

  SettingModel(SettingCellType.Function, '退出登录', null, Color(0xFFFA5151), (BuildContext ctx){
    dialog(ctx, '提示', '确定要退出登录吗？', '确定', '取消', (){
      Navigator.pop(ctx);
      LoginManager().logout();
    }, (){
      
    });
    
  }),
];
