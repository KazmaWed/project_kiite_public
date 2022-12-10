import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:kiite/model/kiite_colors.dart';
import 'package:kiite/provider/static_value_provider.dart';

Future<void> onChangeNameTap(BuildContext context) async {
  // プログレス
  showNetworkingCircular(context);
  // ユーザー名再取得
  User user = FirebaseAuth.instance.currentUser!;
  userNameMap = {};
  await FirebaseFirestore.instance.collection('user').get().then((value) async {
    for (var document in value.docs) {
      userNameMap[document.id] = document.data()['nickname'];
    }

    String myNickName = userNameMap[user.uid]!;
    Navigator.of(context).pop();

    // ダイアログ表示
    final controller = TextEditingController(text: myNickName);
    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          actionsPadding: const EdgeInsets.only(right: 8),
          title: const Text('ナマエを変更スル'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.name,
            maxLines: 1,
            decoration: const InputDecoration(
              hintText: 'ナマエ',
            ),
            onChanged: (value) => {myNickName = value},
          ),
          actions: [
            TextButton(
              child: const Text('ヤメル'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('ケッテイ'),
              onPressed: () => {_changeName(context, user.uid, myNickName)},
            ),
          ],
        );
      },
    );
  });
}

Future<void> _changeName(BuildContext context, String uid, String newName) async {
  // プログレス
  Navigator.of(context).pop();
  showNetworkingCircular(context);
  // 空白回避
  if (newName.replaceAll(' ', '').replaceAll('　', '') == '') {
    newName = 'ナナシ';
  }
  // ローカル変更
  userNameMap[uid] = newName;
  // Firebase更新
  final data = {'nickname': newName};
  await FirebaseFirestore.instance.doc('user/$uid').set(data).whenComplete(() {
    // プログレス非表示
    Navigator.of(context).pop();
  });
}
