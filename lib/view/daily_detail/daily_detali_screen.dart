import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiite/model/kiite_colors.dart';
import 'package:kiite/model/kiite_icons.dart';
import 'package:kiite/model/kiite_Threshold.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import 'package:kiite/view/daily_detail/daily_detail_photo_view.dart';
import 'package:kiite/view/daily_edit/daily_edit_view_model.dart';
import 'package:kiite/view/daily_detail/daily_detail_view_model.dart';
import 'package:kiite/view/daily_detail/daily_detail_card.dart';

class DailyDetailView extends StatefulWidget {
  const DailyDetailView({Key? key, required this.daily, required this.heroTag}) : super(key: key);
  final Daily daily;
  final String heroTag;

  @override
  DailyDetailViewState createState() => DailyDetailViewState();
}

class DailyDetailViewState extends State<DailyDetailView> {
  bool firstBuild = true;
  late DailyDetailViewModel viewModel;
  bool networking = false;

  @override
  Widget build(BuildContext context) {
    Function callback() {
      return () => setState(() {});
    }

    return Consumer(builder: (context, ref, child) {
      // 既読ダイアリー更新
      // _saveReadDaily(ref, daily);

      // ダイアリーの最新情報取得
      viewModel = ref.watch(dailyDetailViewModelProvider);
      viewModel.callback = callback();
      final futureDaily = ref.watch(futureDailyByIdProvider);

      // ユーザー名取得
      String userNickname = userNameMap.isEmpty ? 'ダレカさん' : userNameMap[widget.daily.authorId]!;
      String title = userNickname + DateFormat(' M/d E.').format(widget.daily.dateTime);

      return Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: KiiteThreshold.maxWidth),
            child: Scaffold(
              appBar: AppBar(
                title: Text(title),
                leading: backButton(context),
                actions: editButton(context, ref, widget.daily),
              ),
              floatingActionButton: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ReactionButtonRow(ref: ref, dailyId: widget.daily.id!),
                      messageButton(ref)
                    ],
                  ),
                  SizedBox(height: iosWebSafeAreaInset),
                ],
              ),
              body: FutureBuilder(
                future: futureDaily,
                builder: (BuildContext context, AsyncSnapshot<Daily?> snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  } else
                  // エラー発生時はエラーメッセージを表示
                  if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  } else if (!snapshot.hasData) {
                    return const Center(child: Text('No data.'));
                  } else {
                    Daily dailyLoaded = snapshot.data!;

                    return Scaffold(
                      body: RefreshIndicator(
                        onRefresh: () async {
                          _onRefresh(context, ref, dailyLoaded.id!);
                        },
                        child: ListView(
                          padding: const EdgeInsets.all(12),
                          controller: viewModel.scrollController,
                          children: [
                            // モバイル・タブレット
                            if (KiiteThreshold.isMobile(context) ||
                                KiiteThreshold.isTablet(context))
                              GestureDetector(
                                onTap: () => FocusScope.of(context).unfocus(),
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      DailyDetailPostDateView(dateTime: dailyLoaded.posted),
                                      DairyCard(
                                        daily: dailyLoaded,
                                      ),
                                      const DailyPhotoView(),
                                      DailyCommentCard(daily: dailyLoaded),
                                      const SizedBox(height: 72),
                                      SizedBox(height: iosWebSafeAreaInset),
                                    ],
                                  ),
                                ),
                              ),
                            // PC
                            // if (KiiteThreshold.isPC(context))
                            //   Row(
                            //     mainAxisSize: MainAxisSize.min,
                            //     crossAxisAlignment: CrossAxisAlignment.start,
                            //     children: [
                            //       Expanded(
                            //         child: Column(
                            //           mainAxisAlignment: MainAxisAlignment.start,
                            //           children: [
                            //             GestureDetector(
                            //               onTap: () => FocusScope.of(context).unfocus(),
                            //               child: SingleChildScrollView(
                            //                 child: Column(
                            //                   children: [
                            //                     DailyDetailPostDateView(
                            //                         dateTime: dailyLoaded.posted),
                            //                     DairyCard(daily: dailyLoaded),
                            //                     const DailyPhotoView(),
                            //                   ],
                            //                 ),
                            //               ),
                            //             ),
                            //           ],
                            //         ),
                            //       ),
                            //       const SizedBox(width: 12),
                            //       Expanded(
                            //         child: Column(
                            //           mainAxisSize: MainAxisSize.min,
                            //           children: [
                            //             Text('',
                            //                 style: TextStyle(
                            //                     fontSize:
                            //                         Theme.of(context).textTheme.caption!.fontSize)),
                            //             DailyCommentCard(daily: dailyLoaded),
                            //             const SizedBox(height: 72),
                            //           ],
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget backButton(BuildContext context) {
    return IconButton(
      icon: Icon(KiiteIcons.arrow_back),
      onPressed: () {
        Navigator.of(context).pop();
        viewModel.initControllers(widget.daily);
      },
    );
  }

  List<Widget> editButton(BuildContext context, WidgetRef ref, Daily daily) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null || user.uid == daily.authorId) {
      return <Widget>[
        IconButton(
          icon: Icon(KiiteIcons.more),
          onPressed: () => {_onMoreButtonPressed(context, ref, daily)},
        ),
      ];
    } else {
      return [];
    }
  }

  Widget messageButton(WidgetRef ref) {
    IconData iconData = ref.watch(commentButtonIconProvider);
    return FloatingActionButton(
      heroTag: widget.heroTag,
      backgroundColor: KiiteColors.green,
      onPressed: () {
        bool commentEntered = iconData == KiiteIcons.send;
        _onComment(context, ref, commentEntered);
      },
      child: Icon(iconData),
    );
  }

  Future<void> _onRefresh(BuildContext context, WidgetRef ref, String dailyId) async {
    if (!networking) {
      networking = true;
      final futureDaily = ref.watch(dailyRepositoryProvider)!.futureDailyById(dailyId);
      ref.read(futureDailyByIdProvider.state).state = futureDaily;
      networking = false;
    }
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

  void _onEditPressed(BuildContext context, WidgetRef ref, Daily daily) {
    var viewModel = ref.watch(dailyEditViewModelProvider);
    viewModel.setDaily(context, daily);
    ref.read(dailyEditViewModelProvider.state).state = viewModel;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DailyEditScreen(heroTag: widget.heroTag),
      ),
    );
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

  Future<void> _onDeletePressed(BuildContext context, WidgetRef ref, Daily daily) async {
    if (!networking) {
      networking = true;
      await _deleteDaily(context, ref, viewModel, daily);
      networking = false;
    }
  }

  void _onComment(BuildContext context, WidgetRef ref, bool entered) {
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
                onPressed: () => {_onSendComment(context, ref, viewModel)},
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

  Future<void> _onSendComment(
      BuildContext context, WidgetRef ref, DailyDetailViewModel viewModel) async {
    if (!networking) {
      networking = true;
      await _sendComment(context, ref, viewModel);
      networking = false;
    }
  }
}

Future<void> _refreshList(WidgetRef ref) async {
  ref.read(dailyListViewModelProvider).refreshDailyList();
  ref.read(commentTimelineViewModelProvider).refreshTimelineList();
}

Future<void> _sendComment(
    BuildContext context, WidgetRef ref, DailyDetailViewModel viewModel) async {
  // インジケーター表示
  Navigator.of(context).pop();
  showNetworkingCircular(context);
  // 送信
  await viewModel.addComment(context).then((value) {
    viewModel.commentEditingController.clear();
    // インジケーター非表示
    Navigator.of(context).pop();
    ref.read(commentButtonIconProvider.state).state = KiiteIcons.sms;
  });
}

Future<void> _deleteDaily(
    BuildContext context, WidgetRef ref, DailyDetailViewModel viewModel, Daily daily) async {
  // インジケーター表示
  Navigator.of(context).pop();
  showNetworkingCircular(context);
  // 削除
  await viewModel.removeDaily(context, daily).then((value) {
    _refreshList(ref);
    // インジケーター非表示・画面遷移
    Navigator.of(context).popUntil((route) => route.isFirst);
  });
}
