import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kiite/model/announcement_model.dart';

class AnnouncementRepository {
  final User user = FirebaseAuth.instance.currentUser!;

  final announcementLoadLimit = 5;
  QueryDocumentSnapshot<Map<String, dynamic>>? lastLoadedAnnouncement;
  bool allAnnouncementLoaded = false;
  bool networking = false;

  // 全ニュース取得
  Future<List<Announcement>> futureAnnouncementList() async {
    List<Announcement> output = [];
    allAnnouncementLoaded = false;

    if (!networking) {
      networking = true;

      // ニュース情報取得
      await FirebaseFirestore.instance
          .collection('announcement')
          .orderBy('deliverDate', descending: true)
          .where('deliverDate', isLessThanOrEqualTo: DateTime.now().millisecondsSinceEpoch)
          .limit(announcementLoadLimit + 1)
          .get()
          .then((value) {
        // 全件読み込み済みチェック
        allAnnouncementLoaded = value.docs.length < announcementLoadLimit;

        // データのリスト化
        output = value.docs.map((doc) {
          final item = Announcement.fromMap(doc.data());
          item.id = doc.id;
          return item;
        }).toList();

        // 全件読み込み済みの場合の処理
        if (!allAnnouncementLoaded) {
          output.removeLast();
          lastLoadedAnnouncement = value.docs[value.docs.length - 2];
        } else {
          lastLoadedAnnouncement = value.docs.last;
        }
      });

      // リアクション済ユーザー取得
      for (var index = 0; index < output.length; index++) {
        output[index].reactedBy = await reactedUserlist(output[index].id!);
      }
      networking = false;
    }

    return output;
  }

  Future<List<Announcement>> futureAdditionalAnnouncementList() async {
    List<Announcement> output = [];

    if (!networking && !allAnnouncementLoaded) {
      networking = true;

      // ニュース情報取得
      await FirebaseFirestore.instance
          .collection('announcement')
          .orderBy('deliverDate', descending: true)
          .startAfterDocument(lastLoadedAnnouncement!)
          .limit(announcementLoadLimit + 1)
          .get()
          .then((value) {
        // 全件読み込み済みチェック
        allAnnouncementLoaded = value.docs.length < announcementLoadLimit;

        // データのリスト化
        output = value.docs.map((doc) {
          final item = Announcement.fromMap(doc.data());
          item.id = doc.id;
          return item;
        }).toList();

        // 全件読み込み済みの場合の処理
        if (!allAnnouncementLoaded) {
          output.removeLast();
          lastLoadedAnnouncement = value.docs[value.docs.length - 2];
        } else {
          lastLoadedAnnouncement = value.docs.last;
        }
      });

      // リアクション済ユーザー取得
      for (var index = 0; index < output.length; index++) {
        output[index].reactedBy = await reactedUserlist(output[index].id!);
      }

      networking = false;
    }
    return output;
  }

  Future<bool> unreactedAnnoucement() async {
    List<Future<bool>> futureList = [];

    await FirebaseFirestore.instance
        .collection('announcement')
        // .where('deliverDate', isLessThanOrEqualTo: DateTime.now().millisecondsSinceEpoch)
        .where('dueDate', isGreaterThan: DateTime.now().millisecondsSinceEpoch)
        // .orderBy('dueDate', descending: true)
        .get()
        .then((value) {
      final allId = value.docs.map((doc) => doc.id).toList();

      for (var id in allId) {
        futureList.add(noNeedReaction(id));
      }
    });

    final result = await Future.wait(futureList);
    return result.contains(false);
  }

  Future<bool> noNeedReaction(String announcementId) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    var output = false;

    await FirebaseFirestore.instance.doc('announcement/$announcementId').get().then((value) async {
      final doc = value.data()!;
      final deliverDate = DateTime.fromMillisecondsSinceEpoch(doc['deliverDate']);
      final dueDate = DateTime.fromMillisecondsSinceEpoch(doc['dueDate']);

      final delivered = DateTime.now().isAfter(deliverDate);
      final stillDue = DateTime.now().isBefore(dueDate);

      if (delivered && stillDue) {
        await FirebaseFirestore.instance
            .collection('announcementReaction/$announcementId/reactedBy')
            .get()
            .then((value) {
          final docs = value.docs;
          final allId = docs.map((e) => e.id).toList();
          output = allId.contains(userId);
        });
      } else {
        output = true;
      }
    });

    return output;
  }

  Future<Announcement> futureAnnouncementById(String id) async {
    late final Announcement output;
    await FirebaseFirestore.instance.doc('announcement/$id').get().then((value) {
      output = Announcement.fromMap(value.data()!);
      output.id = value.id;
    });
    return output;
  }

  // ニュース投稿
  Future<bool> post(Announcement announcement) async {
    var succeed = true;
    await FirebaseFirestore.instance
        .collection('announcement')
        .add(announcement.toFireMap())
        .catchError((e) {
      succeed = false;
    });
    return succeed;
  }

  Future<bool> update(Announcement announcement) async {
    var succeed = true;
    await FirebaseFirestore.instance
        .doc('announcement/${announcement.id}')
        .set(announcement.toFireMap())
        .catchError((e) {
      succeed = false;
    });
    return succeed;
  }

  Future<bool> delete(String announcementId) async {
    var succeed = true;
    succeed = await removeReactions(announcementId);
    if (succeed) {
      FirebaseFirestore.instance.doc('announcement/$announcementId').delete().catchError((e) {
        succeed = false;
      });
    }
    return succeed;
  }

  // ニュースに反応
  Future<bool> reactTo(String announcementId) async {
    final userId = user.uid;

    var succeed = true;
    await FirebaseFirestore.instance
        .doc('announcementReaction/$announcementId/reactedBy/$userId')
        .get()
        .then((value) {
      if (!value.exists) {
        FirebaseFirestore.instance
            .doc('announcementReaction/$announcementId/reactedBy/$userId')
            .set(
          {'reactedAt': DateTime.now().millisecondsSinceEpoch},
        );
      } else {
        FirebaseFirestore.instance
            .doc('announcementReaction/$announcementId/reactedBy/$userId')
            .delete();
      }
    });
    return succeed;
  }

  // -------------------- メソッドないメソッド --------------------

  // ニュースに反応済ユーザー取得
  Future<List<String>> reactedUserlist(String announcementId) async {
    final List<String> output = [];

    await FirebaseFirestore.instance
        .collection('announcementReaction/$announcementId/reactedBy')
        .get()
        .then((collection) {
      for (var doc in collection.docs) {
        output.add(doc.id);
      }
    });

    return output;
  }

  // 反応済みユーザー削除
  Future<bool> removeReactions(String announcementId) async {
    bool succeed = true;
    List<Future<void>> futureList = [];

    final collectionPath = 'announcementReaction/$announcementId/readtedBy';
    await FirebaseFirestore.instance.collection(collectionPath).get().then((collection) {
      for (var doc in collection.docs) {
        final docPath = '$collectionPath/${doc.id}';
        futureList.add(
          FirebaseFirestore.instance.doc(docPath).delete().catchError((e) => {succeed = false}),
        );
      }
    });

    Future.wait(futureList);
    return succeed;
  }
}
