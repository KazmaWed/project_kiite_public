import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kiite/model/comment_model.dart';
import 'package:kiite/model/kiite_icons.dart';
import 'package:kiite/model/kiite_Threshold.dart';
import 'package:kiite/view/daily_edit/daily_edit_view_model.dart';
import 'package:kiite/view/common_components/comment_timeline_comment_balloon.dart';
import 'package:kiite/view/common_components/comment_timeline_blank_balloon.dart';

class CommentTimelineCard extends ConsumerWidget {
  const CommentTimelineCard({Key? key, required this.timeline}) : super(key: key);
  final CommentTimeline timeline;
  final String heroTag = 'comment_list';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String dailyId = timeline.dailyId;
    DateTime dailyDate = timeline.dailyDateTime;
    bool firstTap = true;

    final double elevation = ref.read(selectedDailyIdProvider) == dailyId ? 3.2 : 1;
    final shape = ref.read(selectedDailyIdProvider) == dailyId
        ? RoundedRectangleBorder(
            side: BorderSide(color: Theme.of(context).primaryColor),
            borderRadius: const BorderRadius.all(Radius.circular(4)))
        : null;

    Future<void> onTap(BuildContext context, WidgetRef ref, String dailyId) async {
      if (KiiteThreshold.isPC(context)) {
        await ref.read(dailyRepositoryProvider)!.futureDailyById(dailyId).then((value) async {
          await ref.read(dailyDetailViewModelProvider).initControllers(value);
          ref.read(selectedDailyIdProvider.state).state = dailyId;
        });
      } else {
        // 連打ガード
        if (firstTap) {
          firstTap = false;

          // ダイアリーID
          // ref.read(selectedDailyIdProvider.state).state = dailyId;
          Daily daily = await ref.read(dailyRepositoryProvider)!.futureDailyById(dailyId);

          await ref.read(dailyDetailViewModelProvider).initControllers(daily).then((value) async {
            // 画面遷移
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DailyDetailView(
                  daily: daily,
                  heroTag: heroTag,
                ),
              ),
            );
            // 戻ってきた時にsetState()
            ref.read(commentTimelineViewModelProvider).callback();
            firstTap = true;
          });
        }
      }
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: elevation,
      shape: shape,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 2),
              child: Row(
                children: [
                  Icon(
                    KiiteIcons.daily, color: Theme.of(context).primaryColor,
                    // color: Theme.of(context).primaryColor.withOpacity(KiiteColors.iconOpacity),
                  ),
                  const SizedBox(width: 8),
                  userNameText(context, ref, timeline.dailyAuthorId),
                  const SizedBox(width: 4),
                  Text(DateFormat('MM/dd E.').format(dailyDate)),
                  const Text('のダイアリー'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: commentFeed(context, timeline),
            ),
          ]),
        ),
        onTap: () => onTap(context, ref, dailyId),
      ),
    );
  }

  // -------------------- 名前テキスト --------------------

  Widget userNameText(BuildContext context, WidgetRef ref, String authorId) {
    final userNickname = userNameMap[authorId] == null ? 'ダレカさん' : '${userNameMap[authorId]!}さん';

    return Text(
      userNickname,
      style: TextStyle(color: Theme.of(context).primaryColor),
    );
  }

  // -------------------- コメントフィード --------------------

  Widget commentFeed(BuildContext context, CommentTimeline timeline) {
    return Consumer(
      builder: (context, ref, child) {
        final futureCommentList =
            ref.read(commentRepositoryProvider)!.commentList(timeline.dailyId);

        return FutureBuilder(
          future: futureCommentList,
          builder: (
            BuildContext context,
            AsyncSnapshot<List<Comment>> snapshot,
          ) {
            final commentList = snapshot.data ?? <Comment>[];

            if (!snapshot.hasData) {
              // return Container(
              //   height: 76,
              //   alignment: Alignment.center,
              //   child: CircularProgressIndicator(color: KiiteColors.grey.withOpacity(0.25)),
              // );
              return Container(
                padding: const EdgeInsets.only(top: 2),
                child: blankBalloon(context),
              );
            }

            return Container(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                children: [
                  for (var comment in commentList)
                    commentBalloon(
                        context, comment, timeline.dailyAuthorId == comment.authorId, false),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
