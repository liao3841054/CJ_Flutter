/// Created by chenyn 2019-11-21
/// 群聊信息页
///

import 'package:flutter/material.dart';
import './bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_boost/flutter_boost.dart';
import '../Base/CJUtils.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:nim_sdk_util/nim_sdk_util.dart';

double indent = 12;

class SessionTeamInfoWidget extends StatefulWidget {
  final Session session;
  SessionTeamInfoWidget(this.session);
  @override
  State<StatefulWidget> createState() {
    return _SessionTeamInfoState();
  }
}

class _SessionTeamInfoState extends State<SessionTeamInfoWidget> {
  SessioninfoBloc _bloc;
  TeamInfo _teamInfo;
  List<UserInfo> _members;

  Widget _sectionLoading() {
    return Container(
      height: 30,
      child: Center(
        child: CupertinoActivityIndicator(),
      ),
    );
  }

  /// cell
  Widget _cell(Widget title, Widget accessoryView, Function onTap,
      {Widget subTitle}) {
    List<Widget> ws = subTitle == null ? [title] : [title, subTitle];

    return GestureDetector(
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

  /// 群聊名字
  Widget _teamName() {
    return _cell(
        Text('群聊名称'),
        Row(
          children: <Widget>[
            Text(_teamInfo.teamName),
            Icon(Icons.arrow_forward_ios)
          ],
        ),
        () {});
  }

  /// 群二维码
  Widget _code() {
    return _cell(
        Text('群二维码'),
        Row(
          children: <Widget>[Image.asset(''), Icon(Icons.arrow_forward_ios)],
        ),
        () {});
  }

  ///
  Widget _announce() {
    return _cell(
        Text('群公告'),
        Row(
          children: <Widget>[Text('点击查看群公告'), Icon(Icons.arrow_forward_ios)],
        ),
        () {});
  }

  ///
  Widget _nickName() {
    return _cell(
        Text('我在本群的群昵称'),
        Row(
          children: <Widget>[Text('点击设置'), Icon(Icons.arrow_forward_ios)],
        ),
        () {});
  }

  ///
  Widget _teamManager() {
    return _cell(
        Text('群管理'),
        Row(
          children: <Widget>[Text('点击查看'), Icon(Icons.arrow_forward_ios)],
        ),
        () {});
  }

  ///
  Widget _chatHistory() {
    return _cell(
        Text('查找聊天记录'),
        Row(
          children: <Widget>[Text('点击查看'), Icon(Icons.arrow_forward_ios)],
        ),
        () {});
  }

  ///
  Widget _msgMute() {
    return _cell(
        Text('消息免打扰'),
        CupertinoSwitch(
          value: false,
          onChanged: (value) {},
        ),
        () {});
  }

  ///
  Widget _stickOnTop() {
    return _cell(
        Text('聊天置顶'),
        CupertinoSwitch(
          value: false,
          onChanged: (value) {},
        ),
        () {});
  }

  ///
  Widget _clearHistory() {
    return _cell(
        Text('清空聊天记录'),
        CupertinoSwitch(
          value: false,
          onChanged: (value) {},
        ),
        () {});
  }

  ///
  Widget _quitGroup() {
    return CupertinoButton(
      onPressed: () {},
      color: Colors.white,
      child: Container(
        constraints: BoxConstraints(minHeight: 46),
        child: Text('退出群聊', style: TextStyle(color: Colors.red)),
      ),
    );
  }

  /// 查看全部群成员
  Widget _showAllMembers() {
    if (_members.length < 9) {
      return Container();
    }
    return GestureDetector(
      onTap: () => _bloc.add(ShowAllMembersEvent(members: _members)),
      child: Container(
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[Text('查看全部群成员'), Icon(Icons.arrow_forward_ios)],
        ),
      ),
    );
  }

  Widget _buildMemberOperateBtn(int operateType) {
    return GestureDetector(
        onTap: () => _bloc.add(OperateMembersEvent(type: operateType)),
        child: SizedBox(
            width: 70,
            child: Image.asset(
              operateType == 1
                  ? 'images/icon_session_info_add@2x.png'
                  : 'images/icon_session_info_remove@2x.png',
              width: 70,
            )));
  }

  Widget _buildAvatar(String avatarStr, String showName) {
    Widget avatar = avatarStr == null
        ? Image.asset(
            'images/icon_avatar_placeholder@2x.png',
            width: 40,
          )
        : (avatarStr.startsWith('http')
            ? FadeInImage.assetNetwork(
                image: avatarStr,
                width: 40,
                placeholder: 'images/icon_avatar_placeholder@2x.png',
              )
            : Image.asset(
                avatarStr,
                width: 40,
              ));
    return SizedBox(
      width: 70,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          avatar,
          Text(
            showName,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }

  /// 群成员
  Widget _teamMemberSection() {
    if (_members == null) {
      return _sectionLoading();
    }
    List<UserInfo> _ms =
        _members.length > 8 ? _members.sublist(0, 8) : _members.toList();
    // 插入两个，用来处理加号和减号显示
    _ms.addAll([UserInfo(), UserInfo()]);

    return Container(
        constraints: BoxConstraints(maxHeight: 140),
        child: Wrap(
          // alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 10,
          children: _ms.map((f) {
            if (_ms.indexOf(f) == _ms.length - 2) {
              // 添加按钮
              return _buildMemberOperateBtn(1);
            }
            if (f == _ms.last) {
              // 倒数第一个 减号
              return _buildMemberOperateBtn(2);
            }

            return _buildAvatar(f.avatarUrlString, f.showName);
          }).toList(),
        ));
  }

  /// 群信息
  Widget _teamInfoHeader() {
    if (_teamInfo == null) {
      return _sectionLoading();
    }
    return ListTile(
      leading: _teamInfo.avatarUrlString != null
          ? FadeInImage.assetNetwork(
              image: _teamInfo.avatarUrlString,
              width: 44,
              placeholder: 'images/icon_contact_groupchat@2x.png',
            )
          : Image.asset(
              'images/icon_contact_groupchat@2x.png',
              width: 44,
            ),
      title: Text(_teamInfo.showName),
      subtitle: Text(
        '于' +
            _teamInfo.createTime.toString() +
            '创建  群号：' +
            _teamInfo.teamId.toString(),
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _bloc = BlocProvider.of<SessioninfoBloc>(context);
    return Scaffold(
      appBar: new AppBar(
        leading: new IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            FlutterBoost.singleton.closeCurrent();
          },
        ),
        title: Text(
          '聊天信息',
          style: TextStyle(color: blackColor),
        ),
        backgroundColor: mainBgColor,
        elevation: 0.01,
        iconTheme: IconThemeData.fallback(),
      ),
      body: BlocBuilder<SessioninfoBloc, SessioninfoState>(
        builder: (context, state) {
          if (state is TeamSessionInfoLoaded || state is TeamMembersLoaded) {
            /// 加载OK
            if (state is TeamSessionInfoLoaded) _teamInfo = state.info;
            if (state is TeamMembersLoaded) _members = state.members;
            return ListView(
              children: <Widget>[
                _teamInfoHeader(),
                _teamMemberSection(),
                _showAllMembers(),
                _teamName(),
                Divider(
                  indent: indent,
                  height: 0.5,
                ),
                _code(),
                Divider(
                  indent: indent,
                  height: 0.5,
                ),
                _announce(),
                Divider(
                  indent: indent,
                  height: 0.5,
                ),
                _nickName(),
                Divider(
                  indent: indent,
                  height: 0.5,
                ),
                _teamManager(),
                Container(height: 8),
                _chatHistory(),
                Divider(
                  indent: indent,
                  height: 0.5,
                ),
                _msgMute(),
                Divider(
                  indent: indent,
                  height: 0.5,
                ),
                _stickOnTop(),
                Container(height: 8),
                _clearHistory(),
                Container(height: 8),
                _quitGroup()
              ],
            );
          }
          return Center(
            child: Container(),
          );
        },
      ),
    );
  }
}