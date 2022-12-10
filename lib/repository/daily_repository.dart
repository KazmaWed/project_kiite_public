import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'package:kiite/model/daily_model.dart';
import 'package:kiite/model/comment_model.dart';
import 'package:kiite/provider/static_value_provider.dart';
// import 'dart:io';

// -------------------- Dailyレポジトリー --------------------

class DailyRepository {
  final User user = FirebaseAuth.instance.currentUser!;

  bool networking = false; // ダイアリー取得処理中判定
  bool allLoaded = false; // 全ダイアリー読み込み済み判定
  int dailyLastItemDateTime = 0; // 最後に読み込んだダイアリーの日付
  final dailyNumDownloadAtOnce = 24; // 一度に読み込むダイアリー数

  // 最新のダイアリー取得
  Future<List<Daily>> futureDailyList([String? uid]) async {
    final output = <Daily>[];

    if (!networking) {
      networking = true;
      allLoaded = false;
      int itemCount = 0;

      if (uid == null) {
        await FirebaseFirestore.instance
            .collection('daily')
            .orderBy('posted', descending: true)
            .limit(dailyNumDownloadAtOnce)
            .get()
            .then((value) {
          for (var doc in value.docs) {
            final newDaily = Daily.fromMap(doc.data());
            newDaily.id = doc.id;
            output.add(newDaily);

            itemCount++;
          }
        });
      } else {
        await FirebaseFirestore.instance
            .collection('daily')
            .where('authorId', isEqualTo: uid)
            .orderBy('posted', descending: true)
            .limit(dailyNumDownloadAtOnce)
            .get()
            .then((value) {
          for (var doc in value.docs) {
            final newDaily = Daily.fromMap(doc.data());
            newDaily.id = doc.id;
            output.add(newDaily);

            itemCount++;
          }
        });
      }

      if (output.isEmpty) {
        allLoaded = true;
      } else {
        // 最後にダウンロードしたダイアリー日付記録
        dailyLastItemDateTime = output.last.posted.millisecondsSinceEpoch;
        allLoaded = itemCount < dailyNumDownloadAtOnce;
      }
    }
    networking = false;
    return output;
  }

  // レイジーロードで追加のダイアリー取得
  Future<List<Daily>> additionalDailyList([String? uid]) async {
    final output = <Daily>[];
    if (!networking && !allLoaded) {
      networking = true;
      int itemCount = 0;

      if (uid == null) {
        await FirebaseFirestore.instance
            .collection('daily')
            .orderBy('posted', descending: true)
            .limit(dailyNumDownloadAtOnce)
            .startAfter([dailyLastItemDateTime])
            .get()
            .then((value) {
              for (var doc in value.docs) {
                // 取得した情報をid付きダイアリーに変換
                final newDaily = Daily.fromMap(doc.data());
                newDaily.id = doc.id;
                // 出力配列に追加
                output.add(newDaily);

                itemCount++;
              }
            });
      } else {
        await FirebaseFirestore.instance
            .collection('daily')
            .where('authorId', isEqualTo: uid)
            .orderBy('posted', descending: true)
            .limit(dailyNumDownloadAtOnce)
            .startAfter([dailyLastItemDateTime])
            .get()
            .then((value) {
              for (var doc in value.docs) {
                // 取得した情報をid付きダイアリーに変換
                final newDaily = Daily.fromMap(doc.data());
                newDaily.id = doc.id;
                // 出力配列に追加
                output.add(newDaily);

                itemCount++;
              }
            });
      }

      if (output.isEmpty) {
        allLoaded = true;
      } else {
        // 最後にダウンロードしたダイアリー日付記録
        dailyLastItemDateTime = output.last.posted.millisecondsSinceEpoch;
        allLoaded = itemCount < dailyNumDownloadAtOnce;
      }
    }
    networking = false;
    return output;
  }

  // ダイアリー下書き取得
  Future<List<Daily>> futureDraftList() async {
    networking = true;

    final output = <Daily>[];
    networking = true;
    await FirebaseFirestore.instance
        .collection('draft')
        .where('authorId', isEqualTo: user.uid)
        .get()
        .then((value) {
      for (var doc in value.docs) {
        final newDaily = Daily.fromMap(doc.data());
        newDaily.id = doc.id;
        output.add(newDaily);
      }
    });
    networking = false;
    return output;
  }

  // ID指定でDaily取得
  Future<Daily> futureDailyById(String id) async {
    late Daily output;
    await FirebaseFirestore.instance.doc('daily/$id').get().then((value) {
      final newDaily = Daily.fromMap(value.data()!);
      newDaily.id = value.id;
      output = newDaily;
    });
    return output;
  }

  // 追加
  Future<bool> addDaily(Daily daily, {String collection = 'daily'}) async {
    bool succeed = true;
    String docName = DateFormat('yyyyMMdd').format(daily.dateTime) + user.uid;
    daily.authorId = user.uid;
    // await FirebaseFirestore.instance
    //     .collection(collection)
    //     .add(daily.toFireMap())
    //     .then((value) {})
    //     .catchError((e) {
    //   succeed = false;
    // });
    await FirebaseFirestore.instance
        .collection(collection)
        .doc(docName)
        .set(daily.toFireMap())
        .then((value) {})
        .catchError((e) {
      succeed = false;
    });
    return succeed;
  }

  // 削除
  Future<bool> removeDaily(Daily daily) async {
    bool succeed = true;

    // 画像の削除
    for (var photo in daily.photoList) {
      await FirebaseStorage.instance.ref().child(photo.imagePath).delete().catchError((e) {
        succeed = false;
      });
    }

    // コメント削除
    await FirebaseFirestore.instance
        .collection('comment/${daily.id}/comment')
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        FirebaseFirestore.instance
            .doc('comment/${daily.id}/comment/${doc.id}')
            .delete()
            .catchError((e) => false);
      }
    }).catchError((e) {
      succeed = false;
    });
    await FirebaseFirestore.instance.doc('commnent/${daily.id}').delete().catchError((e) {
      succeed = false;
    });

    // ダイアリー削除
    await FirebaseFirestore.instance.doc('daily/${daily.id}').delete().catchError((e) {
      succeed = false;
    });

    return succeed;
  }

  Future<bool> removeDraft(Daily daily) async {
    // ダイアリー削除
    await FirebaseFirestore.instance.doc('draft/${daily.id}').delete().catchError((e) => false);
    return true;
  }

  // 更新
  Future<bool> updateDaily(Daily daily, {String collection = 'daily'}) async {
    Map<String, dynamic> updatedDailyMap = daily.toFireMap();
    updatedDailyMap['authorId'] = user.uid;
    await FirebaseFirestore.instance
        .collection(collection)
        .doc(daily.id)
        .update(updatedDailyMap)
        .catchError((e) => false);
    return true;
  }

  // -------------------- 画像の保存・削除 -------------------

  Future<List<Photo>> addXFileList(List<XFile?> xFileList) async {
    final List<Photo> photoList = []; // URLリスト出力
    final DateTime created = DateTime.now(); // 投稿日時
    final String createdStr = DateFormat('yyyyMMddHms').format(created);

    for (var xFile in xFileList) {
      if (xFile != null) {
        // ファイル名・拡張子の取得
        String fileName = xFile.name.replaceFirst('image_picker_', '');
        String fileType = fileName.split('.').last;
        String fileNameWithTime = '$createdStr${FirebaseAuth.instance.currentUser!.uid}$fileName';
        if (iosWebSafeAreaInset > 0) {
          fileNameWithTime += '.$fileType';
        }

        // アップロード
        final task = await FirebaseStorage.instance
            .ref()
            .child('daily/${user.uid}')
            .child(fileNameWithTime)
            .putData(await xFile.readAsBytes(), SettableMetadata(contentType: 'image/$fileType'));

        // URLとCloud Firebaseのパスの取得
        String imageUrl = await task.ref.getDownloadURL();
        String imagePath = task.ref.fullPath;

        // DailyにPhotoを渡す用
        Photo photo = Photo(imageUrl: imageUrl, imagePath: imagePath);
        photoList.add(photo);
      }
    }

    return photoList;
  }

  Future<bool> removePhotoList(List<Photo> photoList) async {
    var output = true;

    for (var photo in photoList) {
      await FirebaseStorage.instance
          .ref()
          .child(photo.imagePath)
          .delete()
          .onError((error, stackTrace) {
        output = false;
      });
    }
    return output;
  }

  // -------------------- コメント -------------------

  // コメント
  Future<bool> addComment(Daily daily, Comment comment) async {
    bool succeed = true;
    late Daily realTimeDaily;
    await FirebaseFirestore.instance.doc('daily/${daily.id!}').get().then((value) async {
      // dataからDailyを生成
      realTimeDaily = Daily.fromMap(value.data()!);

      // コメント時間を更新したものをMapにして再アップ
      Map<String, dynamic> map = realTimeDaily.toFireMap();
      await FirebaseFirestore.instance.doc('daily/${daily.id!}').update(map);
    }).catchError((e) {
      succeed = false;
    });
    return succeed;
  }
}
