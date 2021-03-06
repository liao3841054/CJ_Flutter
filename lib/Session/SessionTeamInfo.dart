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

double indent = 12;

class SessionTeamInfoWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SessionTeamInfoState();
  }
}

class _SessionTeamInfoState extends State<SessionTeamInfoWidget> {
  SessioninfoBloc _bloc;
  TeamInfo _teamInfo;
  List<UserInfo> _members = [];
  TeamMemberInfo _memberInfo;
  TextEditingController _nickNameController = TextEditingController();
  TextEditingController _teamNameController = TextEditingController();
  bool _msgNotify = false;
  bool _isStickOnTop = false;

  @override
  void dispose() {
    _nickNameController.dispose();
    _teamNameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  Widget _sectionLoading() {
    return Container(
      height: 30,
      child: Center(
        child: CupertinoActivityIndicator(),
      ),
    );
  }

  /// 群聊名字
  Widget _teamName() {
    if (_teamInfo == null) {
      return Container();
    }
    return Cell(
        Text('群聊名称'),
        Container(
          padding: EdgeInsets.only(left: 5),
          child: Row(
            children: <Widget>[
              Container(
                width: getSize(context).width - 120,
                child: Text(
                  _teamInfo.teamName == null ? '' : _teamInfo.teamName,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
              )
            ],
          ),
        ), () {
      if (_memberInfo.type == 1) {
        cjDialog(context, '设置名称',
            content: CupertinoTextField(
              controller: _teamNameController,
              clearButtonMode: OverlayVisibilityMode.editing,
            ),
            handlers: [
              () {
                if (_teamNameController.text.isNotEmpty) {
                  _bloc.add(UpdateTeamName(teamName: _teamNameController.text));
                }
              }
            ],
            handlerTexts: [
              '确定'
            ]);
      }
    });
  }

  /// 群二维码
  Widget _code() {
    if (_teamInfo == null) {
      return Container();
    }
    return Cell(
        Text('群二维码'),
        Row(
          children: <Widget>[
            Image.asset('images/icon_settings_gray_qr@2x.png'),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
            )
          ],
        ), () {
      String qrCodeUrl =
          'https://api.youxi2018.cn/v2/jump/g/' + _teamInfo.teamId;
      _bloc.add(TappedTeamQrCode(
          qrCodeUrl,
          _teamInfo.avatarUrlString == null
              ? 'images/icon_contact_groupchat@2x.png'
              : _teamInfo.avatarUrlString,
          44));
    });
  }

  /// 群公告
  Widget _announce() {
    return Cell(
        Text('群公告'),
        Row(
          children: <Widget>[
            Text('点击查看群公告'),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
            )
          ],
        ), () {
      _bloc.add(TappedTeamAnnouncement(announcement: _teamInfo.announcement));
    });
  }

  /// 群昵称
  Widget _nickName() {
    if (_memberInfo == null) {
      return Container();
    }
    return Cell(
        Text('我在本群的群昵称'),
        Row(
          children: <Widget>[
            Text(_memberInfo.nickName == null ? '点击设置' : _memberInfo.nickName),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
            )
          ],
        ), () {
      cjDialog(context, '设置群昵称',
          content: CupertinoTextField(
            controller: _nickNameController,
            clearButtonMode: OverlayVisibilityMode.editing,
          ),
          handlers: [
            () {
              print(_nickNameController.text.trim());
              if (_nickNameController.text.trim().isNotEmpty) {
                _bloc.add(UpdateTeamNickName(
                    nickName: _nickNameController.text.trim()));
              }
            }
          ],
          handlerTexts: [
            '确定'
          ]);
    });
  }

  ///
  Widget _teamManage() {
    return Cell(
        Text('群管理'),
        Row(
          children: <Widget>[
            Text('点击查看'),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
            )
          ],
        ), () {
      print(_memberInfo.type);
      if (_memberInfo.type == 1) {
        _bloc.add(TappedTeamManage());
      } else {
        cjDialog(context, '只有群主才能使用群管理功能哦～');
      }
    });
  }

  ///
  Widget _chatHistory() {
    return Container();
    // return cell(
    //     Text('查找聊天记录'),
    //     Row(
    //       children: <Widget>[Text('点击查看'), Icon(Icons.arrow_forward_ios, size: 14,)],
    //     ),
    //     () {});
  }

  ///
  Widget _msgMute() {
    return Cell(
        Text('消息免打扰'),
        CupertinoSwitch(
          value: _msgNotify,
          onChanged: (value) => _bloc.add(SwitchNotifyStatus(newValue: value)),
        ),
        () => {});
  }

  ///
  Widget _stickOnTop() {
    return Cell(
        Text('聊天置顶'),
        CupertinoSwitch(
          value: _isStickOnTop,
          onChanged: (value) =>
              _bloc.add(SwitchStickOnTopStatus(newValue: value)),
        ),
        () => {});
  }

  ///
  Widget _clearHistory() {
    return Cell(
        Text('清空聊天记录'),
        Icon(
          Icons.arrow_forward_ios,
          size: 14,
        ),
        () => cjSheet(context, '警告',
            content: Text('确定要清空聊天记录吗？'),
            handlerTexts: ['确定'],
            handlers: [() => _bloc.add(ClearChatHistory())]));
  }

  ///
  Widget _quitGroup() {
    if (_memberInfo == null || _teamInfo == null) {
      return Container();
    }
    String tip = _memberInfo.userId == _teamInfo.owner ? '解散群聊' : '退出群聊';
    return CupertinoButton(
      onPressed: () =>
          cjSheet(context, '警告', content: Text('确定要$tip吗？'), handlerTexts: [
        '确定'
      ], handlers: [
        () => _memberInfo.userId == _teamInfo.owner
            ? _bloc.add(DismissTeamEvent())
            : _bloc.add(QuitTeamEvent())
      ]),
      color: Colors.white,
      child: Container(
        constraints: BoxConstraints(minHeight: 46),
        child: Text(tip, style: TextStyle(color: Colors.red)),
      ),
    );
  }

  /// 查看全部群成员
  Widget _showAllMembers() {
    if (_members == null || _members.length < 9) {
      return Container();
    }
    return GestureDetector(
      onTap: () => _bloc.add(ShowAllMembersEvent()),
      child: Container(
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('查看全部群成员'),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMemberOperateBtn(int operateType) {
    return GestureDetector(
        onTap: () {
          List<String> ids = [];
          _members.forEach((f) => ids.add(f.userId));
          _bloc.add(OperateMembersEvent(type: operateType, filterIds: ids));
        },
        child: SizedBox(
            width: 70,
            child: Image.asset(
              operateType == 1
                  ? 'images/icon_session_info_add@2x.png'
                  : 'images/icon_session_info_remove@2x.png',
              width: 70,
            )));
  }

  Widget _buildAvatar(String avatarStr, String showName, String memberId) {
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
    return GestureDetector(
        onTap: () => _bloc.add(TappedTeamMemberAvatarEvent(
            teamId: _teamInfo.teamId, memberId: memberId)),
        child: SizedBox(
          width: 70,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              avatar,
              Text(
                showName == null ? '' : showName,
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
        ));
  }

  /// 群成员
  Widget _teamMemberSection() {
    if (_members == null) {
      return _sectionLoading();
    }
    List<UserInfo> ms = (_members.length > 8 && _memberInfo.type == 1)
        ? _members.sublist(0, 8)
        : _members;

    // 改成可变数组
    List<UserInfo> _ms = [];
    _ms.addAll(ms);
    // 群主快捷添加新成员和踢出成员功能
    if (_memberInfo.type == 1) {
      UserInfo add = UserInfo();
      add.userId = '+';
      UserInfo delete = UserInfo();
      delete.userId = '-';
      _ms.addAll([add, delete]);
    }

    return Container(
        constraints: BoxConstraints(maxHeight: 140),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 10,
          children: _ms.map((f) {
            if (f.userId == '+') {
              return _buildMemberOperateBtn(1);
            }
            if (f.userId == '-') {
              return _buildMemberOperateBtn(0);
            }

            return _buildAvatar(f.avatarUrlString, f.showName, f.userId);
          }).toList(),
        ));
  }

  /// 群信息
  Widget _teamInfoHeader() {
    if (_teamInfo == null) {
      return _sectionLoading();
    }
    int dt = (_teamInfo.createTime * 1000).ceil();
    DateTime date = DateTime.fromMillisecondsSinceEpoch(dt);
    return ListTile(
      leading: GestureDetector(
        onTap: () {
          if (_memberInfo.type == 1) {
            /// 换头像
            cjSheet(context, '设置群头像', handlerTexts: [
              '拍照',
              '从相册'
            ], handlers: [
              () => _bloc.add(TappedTeamAvatar(type: 0)),
              () => _bloc.add(TappedTeamAvatar(type: 1))
            ]);
          }
        },
        child: _teamInfo.avatarUrlString != null
            ? FadeInImage.assetNetwork(
                image: _teamInfo.avatarUrlString,
                width: 44,
                placeholder: 'images/icon_contact_groupchat@2x.png',
              )
            : Image.asset(
                'images/icon_contact_groupchat@2x.png',
                width: 44,
              ),
      ),
      title: Text(_teamInfo.showName == null ? '' : _teamInfo.showName),
      subtitle: Text(
        '于' +
            date.year.toString() +
            '年' +
            date.month.toString() +
            '月' +
            date.day.toString() +
            '日' +
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
          /// 加载OK
          if (state is TeamSessionInfoLoaded) {
            _teamInfo = state.info;
            _members = state.members;
            _memberInfo = state.memberInfo;
            _isStickOnTop = state.isStickOnTop;
            _msgNotify = state.msgNotify;

            return ListView(
              key: Key('ListView'),
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
                _teamManage(),
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
