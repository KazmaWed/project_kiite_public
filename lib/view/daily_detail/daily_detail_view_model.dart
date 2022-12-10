import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kiite/model/kiite_icons.dart';
import 'package:kiite/model/daily_model.dart';
import 'package:kiite/model/kiite_snackbar.dart';
import 'package:kiite/provider/view_model_provider.dart';
import 'package:kiite/provider/firebase_provider.dart';
import 'package:kiite/provider/static_value_provider.dart';

import 'package:kiite/model/comment_model.dart';
import 'package:kiite/model/reaction_model.dart';

export 'package:kiite/view/daily_list/daily_list_item.dart';
export 'package:kiite/view/daily_detail/daily_detail_post_date.dart';
export 'package:kiite/view/daily_detail/daily_detail_action_button.dart';
export 'package:kiite/view/common_components/comment_timeline_comment_balloon.dart';
export 'package:kiite/model/comment_model.dart';

class DailyDetailViewModel {
  DailyDetailViewModel(this.ref);

  StateProviderRef ref;
  final User user = FirebaseAuth.instance.currentUser!;
  ScrollController scrollController = ScrollController();

  late Function callback;
  late TextEditingController commentEditingController;
  late Daily selectedDaily;
  late List<Comment> commentList;
  late Reaction reaction;

  Future<void> initControllers(Daily daily) async {
    // ダイアリーID
    // ref.read(selectedDailyIdProvider.state).state = daily.id!;

    // コメント
    commentList = await ref.read(commentRepositoryProvider)!.commentList(daily.id!);

    ref.read(commentButtonIconProvider.state).state = KiiteIcons.sms;
    commentEditingController = TextEditingController();
    selectedDaily = await ref.read(dailyRepositoryProvider)!.futureDailyById(daily.id!);
    ref.read(futureDailyByIdProvider.state).state =
        ref.read(dailyRepositoryProvider)!.futureDailyById(daily.id!);
  }

  Comment get comment {
    Comment output = Comment(
      body: commentEditingController.text,
      dailyAuthorId: selectedDaily.authorId,
      posted: DateTime.now(),
    );
    output.setDaily(selectedDaily);
    return output;
  }

  // -------------------- カードにアクション系メソッド --------------------

  Future<void> addComment(BuildContext context) async {
    // コメント生成
    Comment newComment = comment;

    // リポジトリに追加
    final commentRepository = ref.read(commentRepositoryProvider);
    await commentRepository!.addComment(newComment).then((succeed) {
      // スナックバー
      final snack = KiiteSnackBar(context);
      if (succeed) {
        snack.sent();
      } else {
        snack.sendFailed();
      }
    });
    commentEditingController.clear();
    ref.read(commentButtonIconProvider.state).state = KiiteIcons.sms;

    callback();
  }

  // いいね、励まし、
  Future<void> like(WidgetRef ref) async {
    final repository = ref.watch(reactionRepositoryProvider)!;
    final alreadyReacted = reaction.likedBy.contains(user.uid);

    if (alreadyReacted) {
      reaction.likedBy.remove(user.uid);
      callback();
      await repository.unlike(selectedDaily.id!);
    } else {
      reaction.likedBy.add(user.uid);
      callback();
      await repository.like(selectedDaily.id!);
    }

    _refreshList(selectedDaily);
  }

  Future<void> encourage(WidgetRef ref) async {
    final repository = ref.watch(reactionRepositoryProvider)!;
    final alreadyReacted = reaction.encouragedBy.contains(user.uid);

    if (alreadyReacted) {
      reaction.encouragedBy.remove(user.uid);
      callback();
      await repository.unEncourage(selectedDaily.id!);
    } else {
      reaction.encouragedBy.add(user.uid);
      callback();
      await repository.encourage(selectedDaily.id!);
    }

    _refreshList(selectedDaily);
  }

  Future<void> inspiredBy(WidgetRef ref) async {
    final repository = ref.watch(reactionRepositoryProvider)!;
    final alreadyReacted = reaction.inspired.contains(user.uid);

    if (alreadyReacted) {
      reaction.inspired.remove(user.uid);
      callback();
      await repository.unInspired(selectedDaily.id!);
    } else {
      reaction.inspired.add(user.uid);
      callback();
      await repository.inspired(selectedDaily.id!);
    }

    _refreshList(selectedDaily);
  }

  Future<void> removeDaily(BuildContext context, Daily daily) async {
    final dailyRepository = ref.read(dailyRepositoryProvider);
    await dailyRepository!.removeDaily(daily).then((succeed) {
      // スナックバー
      final snack = KiiteSnackBar(context);
      if (succeed) {
        snack.removed();
      } else {
        snack.removeFailed();
      }
    });
  }

  Future<void> removeDraft(BuildContext context, Daily daily) async {
    final dailyRepository = ref.read(dailyRepositoryProvider);
    await dailyRepository!.removeDraft(daily).then((succeed) {
      // スナックバー
      final snack = KiiteSnackBar(context);
      if (succeed) {
        snack.removed();
      } else {
        snack.removeFailed();
      }
    });
  }

  // リストビューのカード更新
  Future<void> _refreshList(Daily daily) async {
    ref.read(dailyListViewModelProvider).updateItem(daily);
  }

  String get totalLength {
    double outputInt = 0;

    for (var effort in selectedDaily.effortList) {
      outputInt += effort.length.isEmpty ? 0.0 : double.parse(effort.length);
    }

    return outputInt.toString();
  }
}
