import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kiite/model/kiite_colors.dart';
import 'package:kiite/model/kiite_icons.dart';
import 'package:kiite/model/reaction_model.dart';
import 'package:kiite/view/daily_detail/daily_detail_view_model.dart';
import 'package:kiite/view/daily_edit/daily_edit_view_model.dart';

class DailyColumnTitleView extends ConsumerWidget {
  const DailyColumnTitleView({Key? key, required this.daily}) : super(key: key);
  final Daily daily;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var networking = false;

    final authorName =
        userNameMap[daily.authorId] != null ? '${userNameMap[daily.authorId]}さん' : 'ダレカさん';
    final dailyTitleStr = '$authorName ${DateFormat('y M/d E. H:m').format(daily.dateTime)}';
    final dailyTitleStyle = Theme.of(context).textTheme.titleMedium!.copyWith(
          color: Theme.of(context).primaryColor,
        );
    final editDateStr = DateFormat('投稿日 y M/d E. H:m').format(daily.posted);
    final editDateStyle = TextStyle(
      fontSize: Theme.of(context).textTheme.caption!.fontSize,
      color: KiiteColors.grey,
    );

    void _onEditPressed(BuildContext context, WidgetRef ref, Daily daily) {
      var viewModel = ref.watch(dailyEditViewModelProvider);
      viewModel.setDaily(context, daily);
      ref.read(dailyEditViewModelProvider.state).state = viewModel;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DailyEditScreen(heroTag: ''),
        ),
      );
    }

    Future<void> _deleteDaily(BuildContext context, WidgetRef ref, Daily daily) async {
      final viewModel = ref.watch(dailyDetailViewModelProvider);
      // インジケーター表示
      Navigator.of(context).pop();
      showNetworkingCircular(context);
      // 削除
      await viewModel.removeDaily(context, daily).then((value) {
        // _refreshList(ref);

        // インジケーター非表示・画面遷移
        Navigator.of(context).popUntil((route) => route.isFirst);
      });
    }

    Future<void> _onDeletePressed(BuildContext context, WidgetRef ref, Daily daily) async {
      if (!networking) {
        networking = true;
        await _deleteDaily(context, ref, daily);
        networking = false;
      }
    }

    Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Daily daily) async {
      Navigator.of(context).pop();
      await showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            actionsPadding: const EdgeInsets.only(bottom: 8, right: 8),
            title: const Text('サクジョしますか？'),
            actions: <Widget>[
              TextButton(
                child: const Text("シナイ"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text("スル"),
                onPressed: () {
                  _onDeletePressed(context, ref, daily);
                },
              ),
            ],
          );
        },
      );
    }

    Future<void> _onMoreButtonPressed(BuildContext context, WidgetRef ref, Daily daily) async {
      showDialog(
        context: context,
        builder: (_) {
          return SizedBox(
            width: 10,
            child: SimpleDialog(
              // title: Text('ダイアリーを…'),
              children: <Widget>[
                TextButton(
                  child: const Text('ヘンシュウ'),
                  onPressed: () => {
                    Navigator.of(context).pop(),
                    _onEditPressed(context, ref, daily),
                  },
                ),
                TextButton(
                  child: const Text('サクジョ'),
                  onPressed: () => _confirmDelete(context, ref, daily),
                ),
              ],
            ),
          );
        },
      );
    }

    Widget moreButton() {
      if (FirebaseAuth.instance.currentUser!.uid == daily.authorId) {
        return IconButton(
          onPressed: () => _onMoreButtonPressed(context, ref, daily),
          padding: const EdgeInsets.all(0),
          splashRadius: 20,
          icon: Icon(
            Icons.more_horiz_rounded,
            color: KiiteColors.grey,
          ),
        );
      } else {
        return const SizedBox();
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dailyTitleStr, style: dailyTitleStyle),
                Text(editDateStr, style: editDateStyle),
              ],
            ),
            const Spacer(),
            moreButton(),
          ],
        ),
      ),
    );
  }
}

// -------------------- コメントボタン --------------------
class MessageButton extends StatefulWidget {
  const MessageButton({Key? key, required this.ref, this.heroTag}) : super(key: key);
  final WidgetRef ref;
  final String? heroTag;

  @override
  State<MessageButton> createState() => _MessageButtonState();
}

class _MessageButtonState extends State<MessageButton> {
  var networking = false;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      IconData iconData = ref.watch(commentButtonIconProvider);
      final viewModel = ref.watch(dailyDetailViewModelProvider);

      Future<void> onSendComment(
        BuildContext context,
        WidgetRef ref,
        DailyDetailViewModel viewModel,
      ) async {
        if (!networking) {
          networking = true;

          Navigator.of(context).pop();
          // インジケーター表示
          showNetworkingCircular(context);
          // 送信
          await viewModel.addComment(context).then((value) {
            Navigator.of(context).pop();
            viewModel.commentEditingController.clear();
            // インジケーター非表示
            ref.read(commentButtonIconProvider.state).state = KiiteIcons.sms;
          });

          networking = false;
        }
      }

      void onComment(BuildContext context, WidgetRef ref, bool entered) {
        if (entered) {
          showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                actionsPadding: const EdgeInsets.only(bottom: 8, right: 8),
                title: const Text('コメントを送信スル？'),
                content: Text(viewModel.commentEditingController.text),
                actions: <Widget>[
                  // ボタン領域
                  TextButton(
                    child: const Text('ヤメル'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  TextButton(
                    child: const Text('スル'),
                    onPressed: () => {onSendComment(context, ref, viewModel)},
                  ),
                ],
              );
            },
          );
        } else {
          viewModel.scrollController
              .animateTo(
            viewModel.scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutSine,
          )
              .then((value) {
            staticFocusNode.requestFocus();
          });
        }
      }

      return FloatingActionButton(
        heroTag: widget.heroTag,
        backgroundColor: KiiteColors.green,
        onPressed: () {
          bool commentEntered = iconData == KiiteIcons.send;
          onComment(context, ref, commentEntered);
        },
        child: Icon(iconData),
      );
    });
  }

  // Future<void> onRefresh(BuildContext context, WidgetRef ref, String dailyId) async {
  //   if (!networking) {
  //     networking = true;
  //     final futureDaily = ref.watch(dailyRepositoryProvider)!.futureDailyById(dailyId);
  //     ref.read(futureDailyByIdProvider.state).state = futureDaily;
  //     networking = false;
  //   }
  // }
}

// -------------------- リアクションボタン --------------------
class ReactionButtonRow extends StatelessWidget {
  const ReactionButtonRow({Key? key, required this.ref, required this.dailyId}) : super(key: key);
  final WidgetRef ref;
  final String dailyId;

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(dailyDetailViewModelProvider);
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final futureLikedByList = ref.watch(reactionRepositoryProvider)!.futureLikedBy(dailyId);
    final futureEncouragedByList =
        ref.watch(reactionRepositoryProvider)!.futureEncouragedBy(dailyId);
    final futureInspiredList = ref.watch(reactionRepositoryProvider)!.futureInspired(dailyId);
    final futureAll = Future.wait([futureLikedByList, futureEncouragedByList, futureInspiredList]);

    String blankNumber = '-';

    return FutureBuilder(
      future: futureAll,
      builder: (
        BuildContext context,
        AsyncSnapshot<List<Set<String>>> snapshot,
      ) {
        // ロード中
        if (!snapshot.hasData) {
          return Row(children: [
            FloatingActionButton(
              heroTag: 'like',
              backgroundColor: KiiteColors.grey,
              onPressed: () {},
              child: Column(children: [
                Expanded(flex: 2, child: Container()),
                Expanded(
                  flex: 3,
                  child: Text(blankNumber,
                      style: TextStyle(fontSize: Theme.of(context).textTheme.overline!.fontSize)),
                ),
                Expanded(flex: 6, child: Icon(KiiteIcons.favorite)),
                Expanded(flex: 3, child: Container()),
              ]),
            ),
            const SizedBox(width: 15),
            FloatingActionButton(
              heroTag: 'encourage',
              backgroundColor: KiiteColors.grey,
              onPressed: () {},
              child: Column(children: [
                Expanded(flex: 2, child: Container()),
                Expanded(
                  flex: 3,
                  child: Text(blankNumber),
                ),
                Expanded(flex: 6, child: Icon(KiiteIcons.healing)),
                Expanded(flex: 3, child: Container()),
              ]),
            ),
            const SizedBox(width: 15),
            FloatingActionButton(
              heroTag: 'light',
              backgroundColor: KiiteColors.grey,
              onPressed: () {},
              child: Column(children: [
                Expanded(flex: 2, child: Container()),
                Expanded(
                    flex: 3,
                    child: Text(blankNumber,
                        style:
                            TextStyle(fontSize: Theme.of(context).textTheme.overline!.fontSize))),
                Expanded(flex: 6, child: Icon(KiiteIcons.light)),
                Expanded(flex: 3, child: Container()),
              ]),
            ),
            const SizedBox(width: 15),
          ]);
        }

        // ロード後
        final reactionList = snapshot.data ?? <Set<String>>[];
        // ViewModelに格納
        final reaction = Reaction();
        reaction.likedBy = reactionList[0];
        reaction.encouragedBy = reactionList[1];
        reaction.inspired = reactionList[2];

        viewModel.reaction = reaction;

        // カウント表示
        int likedIconCount = viewModel.reaction.likedBy.length;
        int encouragedCount = viewModel.reaction.encouragedBy.length;
        int inspireCount = viewModel.reaction.inspired.length;

        // ボタン色
        MaterialColor likedIconColor =
            viewModel.reaction.likedBy.contains(uid) ? KiiteColors.pink : KiiteColors.grey;
        MaterialColor encouragedIconColor =
            viewModel.reaction.encouragedBy.contains(uid) ? KiiteColors.blue : KiiteColors.grey;
        MaterialColor inspireIconColor =
            viewModel.reaction.inspired.contains(uid) ? KiiteColors.yellow : KiiteColors.grey;

        return InkWell(
          hoverColor: Colors.transparent,
          onLongPress: () => {onLongPress(context, reaction)},
          child: Row(
            children: [
              FloatingActionButton(
                heroTag: 'like',
                backgroundColor: likedIconColor,
                onPressed: () => {viewModel.like(ref)},
                child: Column(children: [
                  Expanded(flex: 2, child: Container()),
                  Expanded(
                    flex: 3,
                    child: Text(
                      likedIconCount.toString(),
                      style: TextStyle(fontSize: Theme.of(context).textTheme.overline!.fontSize),
                    ),
                  ),
                  Expanded(flex: 6, child: Icon(KiiteIcons.favorite)),
                  Expanded(flex: 3, child: Container()),
                ]),
              ),
              const SizedBox(width: 15),
              FloatingActionButton(
                heroTag: 'encourage',
                backgroundColor: encouragedIconColor,
                onPressed: () => {viewModel.encourage(ref)},
                child: Column(children: [
                  Expanded(flex: 2, child: Container()),
                  Expanded(
                      flex: 3,
                      child: Text(encouragedCount.toString(),
                          style:
                              TextStyle(fontSize: Theme.of(context).textTheme.overline!.fontSize))),
                  Expanded(flex: 6, child: Icon(KiiteIcons.healing)),
                  Expanded(flex: 3, child: Container()),
                ]),
              ),
              const SizedBox(width: 15),
              FloatingActionButton(
                heroTag: 'light',
                backgroundColor: inspireIconColor,
                onPressed: () => {viewModel.inspiredBy(ref)},
                child: Column(children: [
                  Expanded(flex: 2, child: Container()),
                  Expanded(
                      flex: 3,
                      child: Text(inspireCount.toString(),
                          style:
                              TextStyle(fontSize: Theme.of(context).textTheme.overline!.fontSize))),
                  Expanded(flex: 6, child: Icon(KiiteIcons.light)),
                  Expanded(flex: 3, child: Container()),
                ]),
              ),
              const SizedBox(width: 15),
            ],
          ),
        );
      },
    );
  }
}

// -------------------- リアクションユーザー表示 --------------------
Future<void> onLongPress(BuildContext context, Reaction reaction) async {
  if (reaction.hasData()) {
    // 名前リスト
    Widget nameListColumn(Set<String> set, Color color) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var uid in set)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                userNameMap[uid] == null ? 'ダレカさん' : '${userNameMap[uid]!}さん',
                style: TextStyle(color: color),
              ),
            ),
        ],
      );
    }

    await showDialog(
      barrierColor: Colors.black26,
      context: context,
      builder: (context) {
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Container(
              padding: const EdgeInsets.all(4),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (reaction.likedBy.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(KiiteIcons.like, color: KiiteColors.iconPink),
                          const SizedBox(width: 14),
                          nameListColumn(reaction.likedBy, KiiteColors.pink)
                        ],
                      ),
                    if (reaction.likedBy.isNotEmpty &&
                        (reaction.encouragedBy.isNotEmpty || reaction.inspired.isNotEmpty))
                      const SizedBox(height: 8),
                    if (reaction.encouragedBy.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(KiiteIcons.healing, color: KiiteColors.iconBlue),
                          const SizedBox(width: 14),
                          nameListColumn(reaction.encouragedBy, KiiteColors.blue)
                        ],
                      ),
                    if (reaction.encouragedBy.isNotEmpty && reaction.inspired.isNotEmpty)
                      const SizedBox(height: 8),
                    if (reaction.inspired.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(KiiteIcons.light, color: KiiteColors.iconYellow),
                          const SizedBox(width: 14),
                          nameListColumn(reaction.inspired, KiiteColors.textYellow)
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
