import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kiite/model/kiite_colors.dart';
import 'package:kiite/model/kiite_icons.dart';
import 'package:kiite/view/daily_edit/daily_edit_view_model.dart';
import 'package:kiite/view/daily_detail/daily_detail_view_model.dart';

class DailyCommentCard extends ConsumerWidget {
  const DailyCommentCard({Key? key, required this.daily}) : super(key: key);
  final Daily daily;

  // -------------------- コメント枠全体 --------------------

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double vertinalInset = 12;
    double horizontalInset = 18;

    return Card(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: vertinalInset, horizontal: horizontalInset),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  KiiteIcons.sms,
                  color: Theme.of(context).primaryColor,
                  // color: Theme.of(context).primaryColor.withOpacity(KiiteColors.iconOpacity),
                ),
                const SizedBox(width: 8),
                Text('コメント', style: TextStyle(color: Theme.of(context).primaryColor)),
                Expanded(child: Container(width: double.infinity)),
                // Text('8.0 h',
                //     style: TextStyle(color: Theme.of(context).primaryColor)),
              ],
            ),
            const SizedBox(height: 8),
            commentFeed(context, daily),
            const SizedBox(height: 0),
            commentField(context),
          ],
        ),
      ),
    );
  }

  // -------------------- コメントフィード --------------------

  Widget commentFeed(BuildContext context, Daily daily) {
    return Consumer(builder: (context, ref, child) {
      final futureCommentList = ref.watch(commentRepositoryProvider)!.commentList(daily.id!);

      return FutureBuilder(
        future: futureCommentList,
        builder: (
          BuildContext context,
          AsyncSnapshot<List<Comment>> snapshot,
        ) {
          // ロード中
          if (!snapshot.hasData) {
            return Container(
              height: 76,
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                color: KiiteColors.grey.withOpacity(0.25),
              ),
            );
          }

          final commentList = snapshot.data ?? <Comment>[];

          return Container(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              children: [
                for (var comment in commentList)
                  commentBalloon(context, comment, daily.authorId == comment.authorId, true),
              ],
            ),
          );
        },
      );
    });
  }

  // -------------------- コメント入力欄 --------------------

  Widget commentField(BuildContext context) {
    double edgeInset = 4;

    return Consumer(builder: (context, ref, child) {
      final viewModel = ref.watch(dailyDetailViewModelProvider);
      final changeThemeViewModel = ref.watch(changeThemeViewModelProvider);
      Color hintColor = Theme.of(context).textTheme.bodyText2!.color!.withOpacity(0.5);
      TextStyle hintStyle = Theme.of(context).textTheme.bodyText2!.copyWith(color: hintColor);

      return Container(
        padding: EdgeInsets.fromLTRB(edgeInset, edgeInset, edgeInset, 0),
        child: FocusScope(
          child: Focus(
            onFocusChange: (focus) {
              ref.read(commentButtonIconProvider.state).state =
                  (viewModel.commentEditingController.text != '')
                      ? KiiteIcons.send
                      : KiiteIcons.sms;
            },
            child: TextFormField(
              focusNode: staticFocusNode,
              controller: viewModel.commentEditingController,
              onChanged: (value) {
                if (value == '') {
                  ref.read(commentButtonIconProvider.state).state = KiiteIcons.sms;
                } else {
                  ref.read(commentButtonIconProvider.state).state = KiiteIcons.send;
                }
                viewModel.scrollController.animateTo(
                  viewModel.scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutSine,
                );
              },
              keyboardType: TextInputType.multiline,
              keyboardAppearance:
                  changeThemeViewModel.darkMode ? Brightness.dark : Brightness.light,
              maxLines: null,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'カキカキ...',
                hintStyle: hintStyle,
              ),
            ),
          ),
        ),
      );
    });
  }
}
