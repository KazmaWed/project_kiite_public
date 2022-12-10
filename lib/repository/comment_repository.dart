import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:kiite/model/comment_model.dart';

class CommentRepository {
  bool networking = false; // TL取得処理中判定
  int lastItemDateTime = 0; // 最後に読み込んだTLの日付
  bool allLoaded = false; // 全TL読み込み済み判定
  final timelineNumDownloadAtOnce = 8; // 一度に読み込むTL数

  Future<List<CommentTimeline>> futureCommentTLList([String? uid]) async {
    // 出力配列
    List<CommentTimeline> output = [];

    if (!networking) {
      networking = true;
      allLoaded = false;
      int itemCount = 0;

      if (uid == null) {
        await FirebaseFirestore.instance
            .collection('comment')
            .orderBy('commented', descending: true)
            .limit(timelineNumDownloadAtOnce)
            .get()
            .then((value) async {
          for (var document in value.docs) {
            // ダイアリー毎のタイムライン
            final CommentTimeline timeline = CommentTimeline(
              dailyId: document.id,
            );
            timeline.setMap(document.data());

            output.add(timeline);
            itemCount++;
          }
        });
      } else {
        await FirebaseFirestore.instance
            .collection('comment')
            .where('dailyAuthorId', isEqualTo: uid)
            .orderBy('commented', descending: true)
            .limit(timelineNumDownloadAtOnce)
            .get()
            .then((value) async {
          for (var document in value.docs) {
            // ダイアリー毎のタイムライン
            final CommentTimeline timeline = CommentTimeline(
              dailyId: document.id,
            );
            timeline.setMap(document.data());

            output.add(timeline);
            itemCount++;
          }
        });
      }

      if (output.isEmpty) {
        allLoaded = true;
      } else {
        lastItemDateTime = output.last.commented.millisecondsSinceEpoch;
        allLoaded = itemCount < timelineNumDownloadAtOnce;
      }
    }

    networking = false;
    return output;
  }

  Future<List<CommentTimeline>> additionalTimelineList([String? uid]) async {
    // 出力配列
    List<CommentTimeline> output = [];

    if (!networking && !allLoaded) {
      networking = true;
      int itemCount = 0;

      if (uid == null) {
        await FirebaseFirestore.instance
            .collection('comment')
            .orderBy('commented', descending: true)
            .limit(timelineNumDownloadAtOnce)
            .startAfter([lastItemDateTime])
            .get()
            .then((value) async {
              for (var document in value.docs) {
                // ダイアリー毎のタイムライン
                final CommentTimeline timeline = CommentTimeline(
                  dailyId: document.id,
                );
                timeline.setMap(document.data());

                output.add(timeline);
                itemCount++;
              }
            });
      } else {
        await FirebaseFirestore.instance
            .collection('comment')
            .where('dailyAuthorId', isEqualTo: uid)
            .orderBy('commented', descending: true)
            .limit(timelineNumDownloadAtOnce)
            .startAfter([lastItemDateTime])
            .get()
            .then((value) async {
              for (var document in value.docs) {
                // ダイアリー毎のタイムライン
                final CommentTimeline timeline = CommentTimeline(
                  dailyId: document.id,
                );
                timeline.setMap(document.data());

                output.add(timeline);
                itemCount++;
              }
            });
      }

      if (output.isEmpty) {
        allLoaded = true;
      } else {
        lastItemDateTime = output.last.commented.millisecondsSinceEpoch;
        allLoaded = itemCount < timelineNumDownloadAtOnce;
      }
    }
    networking = false;
    return output;
  }

  Future<List<Comment>> commentList(String dailyId) async {
    final List<Comment> output = [];

    await FirebaseFirestore.instance
        .collection('comment/$dailyId/comment')
        .orderBy('posted')
        .get()
        .then((value) {
      for (var document in value.docs) {
        final comment = Comment.fromMap(document.data());
        output.add(comment);
      }
    });

    return output;
  }

  // 追加
  Future<bool> addComment(Comment comment) async {
    bool succeed = true;
    User user = FirebaseAuth.instance.currentUser!;
    comment.authorId = user.uid;
    Map<String, dynamic> map = comment.toTimelineMap();
    // コメント日時登録
    FirebaseFirestore.instance.doc('comment/${comment.dailyId}').set(map).catchError((e) {
      succeed = false;
    });
    // コメント本体投稿
    await FirebaseFirestore.instance
        .collection('comment/${comment.dailyId}/comment')
        .add(comment.toFireMap())
        .catchError((e) {
      succeed = false;
    });
    return succeed;
  }
}
