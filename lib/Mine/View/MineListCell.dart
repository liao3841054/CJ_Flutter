/**
 *  Created by chenyn on 2019-07-08
 */
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:cajian/Base/CJUtils.dart';
import 'package:cajian/Mine/Model/MineModel.dart';
import 'package:nim_sdk_util/Model/nim_userInfo.dart';

Widget cellForModel(MineModel model) {
  if(model.type == MineCellType.Others) {
    return MineListCellOthers(model);
  }else if(model.type == MineCellType.Separator) {
    return MineListCellSeparator();
  }else if(model.type == MineCellType.Profile) {
    return MineListProfileHeader(model);
  }

  return Container();
}

class MineListCellOthers extends StatelessWidget {
  final MineModel model;
  MineListCellOthers(this.model);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        height: 48,
        color: Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
            ),
            new Image.asset(model.icon),
            new Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
            ),
            new Text(
              model.title,
            ),
            new Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
            ),
            model.tipIcon != null
                ? new Image.asset(model.tipIcon)
                : Divider(height: 0),
            Spacer(),
            new Icon(
              Icons.arrow_forward_ios,
              size: 16,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
            ),
          ],
        ),
      ),
      onTap: () {
        model.onTap(this.model);
      },
    );
  }
}

class MineListCellSeparator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      color: mainBgColor,
    );
  }
}

// 用户信息
class MineListProfileHeader extends StatefulWidget {
  final MineModel model;
  MineListProfileHeader(this.model);

  MineListProfileState createState() {
    return MineListProfileState();
  }
}

class MineListProfileState extends State<MineListProfileHeader> {
  String _avatarUrl;
  String _showName;
  String _cajianNo;

  @override
  initState() {
    super.initState();

    fetchInfo();
  }

  fetchInfo() async {
    UserInfo info = await widget.model.mineInfo();
    setState(() {
      _avatarUrl = info.avatarUrlString;
      _showName = info.showName;
      _cajianNo = info.cajianNo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
          height: 103,
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
              ),
              _avatarUrl != null
                  ? FadeInImage.assetNetwork(
                      image: _avatarUrl,
                      width: 44,
                      placeholder: 'images/icon_avatar_placeholder@2x.png',
                    )
                  : Image.asset(
                      'images/icon_avatar_placeholder@2x.png',
                      width: 44,
                    ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
              ),
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _showName ?? '',
                    style: TextStyle(fontSize: 17, color: blackColor),
                  ),
                  Text(
                    '擦肩号：$_cajianNo',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF9B9B9B),
                    ),
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                ],
              )),
              Image.asset(
                'images/icon_settings_gray_qr@2x.png',
                width: 14,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
              ),
              new Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
              ),
            ],
          )),
      onTap: () {
        widget.model.onTap(widget.model);
      },
    );
  }
}
