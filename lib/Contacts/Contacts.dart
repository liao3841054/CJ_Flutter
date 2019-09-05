/**
 *  Created by chenyn on 2019-06-28
 *  通讯录
 */

import 'package:flutter/material.dart';
import 'package:nim_sdk_util/nim_sdk_util.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:cajian/Base/CJUtils.dart';
import 'package:azlistview/azlistview.dart';
import 'package:cajian/Contacts/Model/ContactModel.dart';
import 'package:azlistview/src/az_common.dart';

class ContactsWidget extends StatefulWidget {

  ContactsState createState() {
    return new ContactsState();
  }

}

class ContactsState extends State<ContactsWidget> {

  List<ContactInfo> _contacts = List();
  int _suspensionHeight = 40;
  int _itemHeight = 50;
  String _suspensionTag = "";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {

    List friends = await NimSdkUtil.friends();
    friends.forEach((f){
      _contacts.add(ContactInfo(f['showName'], f['avatarUrlString'], infoId: f['infoId']));
    });

    _handleList(_contacts);
  }

  void _handleList(List<ContactInfo> list) {
      if (list == null || list.isEmpty) return;
      for (int i = 0, length = list.length; i < length; i++) {
        String pinyin = PinyinHelper.getPinyinE(list[i].showName);
        String tag = pinyin.substring(0, 1).toUpperCase();
        // list[i].namePinyin = pinyin;
        if (RegExp("[A-Z]").hasMatch(tag)) {
          list[i].tagIndex = tag;
        } else {
          list[i].tagIndex = "#";
        }
      }
      //根据A-Z排序
      SuspensionUtil.sortListBySuspensionTag(_contacts);
  }

  void _onSusTagChanged(String tag) {
    setState(() {
      _suspensionTag = tag;
    });
  }

  Widget _buildSusWidget(String susTag) {
    return Container(
      height: _suspensionHeight.toDouble(),
      padding: const EdgeInsets.only(left: 15.0),
      color: Color(0xfff3f4f5),
      alignment: Alignment.centerLeft,
      child: Text(
        '$susTag',
        softWrap: false,
        style: TextStyle(
          fontSize: 14.0,
          color: Color(0xff999999),
        ),
      ),
    );
  }

  Widget _buildListItem(ContactInfo model) {
    String susTag = model.getSuspensionTag();
    return Column(
      children: <Widget>[
        Offstage(
          offstage: model.isShowSuspension != true,
          child: _buildSusWidget(susTag),
        ),
        SizedBox(
          height: _itemHeight.toDouble(),
          child: ListTile(
            title: Text(model.showName),
            onTap: () {
              print("OnItemClick: $model");
              Navigator.pop(context, model);
            },
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
            title: const Text(
                '通讯录',
                style: TextStyle(color: Color(0xFF141414)),
            ),
            backgroundColor: WhiteColor,
            elevation: 0.01,
          ),
        body: Column(
      children: <Widget>[
          Expanded(
              flex: 1,
              child: AzListView(
                data: _contacts,
                itemBuilder: (context, model) => _buildListItem(model),
                suspensionWidget: _buildSusWidget(_suspensionTag),
                isUseRealIndex: true,
                itemHeight: _itemHeight,
                suspensionHeight: _suspensionHeight,
                onSusTagChanged: _onSusTagChanged,
                //showCenterTip: false,
              )),
        ],
      ),
      )
    );
  }
}