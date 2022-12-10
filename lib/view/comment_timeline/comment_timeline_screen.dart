import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiite/model/comment_model.dart';
import 'package:kiite/model/kiite_Threshold.dart';
import 'package:kiite/model/kiite_colors.dart';
import 'package:kiite/model/kiite_icons.dart';
import 'package:kiite/view/comment_timeline/comment_timeline_view_model.dart';
import 'package:kiite/view/daily_edit/daily_edit_view_model.dart';

import 'comment_timeline_view.dart';

class CommentTimeLineScreen extends StatefulWidget {
  const CommentTimeLineScreen({Key? key}) : super(key: key);

  @override
  CommentTimeLineScreenState createState() => CommentTimeLineScreenState();
}

class CommentTimeLineScreenState extends State<CommentTimeLineScreen> {
  String herotag = 'comment_list';
  late CommentTimelineViewModel viewModel;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      viewModel = ref.watch(commentTimelineViewModelProvider);
      ref.read(commentTimelineViewModelProvider).callback = callback();

      final futureCommentTimeline = ref.watch(futureCommentTimelineProvider);

      if (KiiteThreshold.isMobile(context)) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('コメント'),
            leading: IconButton(
              icon: Icon(KiiteIcons.filter),
              onPressed: () => _scaffoldKey.currentState!.openDrawer(),
            ),
            actions: [_reloadButton()],
          ),
          key: _scaffoldKey,
          drawer: _drawer(context, ref),
          floatingActionButton: _floatingActionButtons(
            context,
            ref,
          ),
          body: FutureBuilder(
            future: futureCommentTimeline,
            builder: (BuildContext context, AsyncSnapshot<List<CommentTimeline>> snapshot) {
              // 通信中はスピナーを表示
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CommentTimelineLoadintView());
              }
              // エラー発生時はエラーメッセージを表示
              if (snapshot.hasError) {
                return _errorView();
              }

              // 読み込み成功で表示
              List<CommentTimeline> commentTimelineList = snapshot.data ?? <CommentTimeline>[];
              // PC時はトップのダイアリーを選択
              if (KiiteThreshold.isPC(context)) {
                ref.read(selectedDailyIdProvider.state).state = commentTimelineList.first.dailyId;
              }

              return RefreshIndicator(
                child: CommentTimelineView(commentTimelineList: commentTimelineList),
                onRefresh: () async => {viewModel.refreshTimelineList()},
              );
            },
          ),
        );
      } else {
        return Scaffold(
          appBar: AppBar(
            title: const Text('コメント'),
            actions: [_reloadButton()],
          ),
          key: _scaffoldKey,
          floatingActionButton: _floatingActionButtons(
            context,
            ref,
          ),
          body: FutureBuilder(
            future: futureCommentTimeline,
            builder: (BuildContext context, AsyncSnapshot<List<CommentTimeline>> snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CommentTimelineLoadintView());
              } else if (snapshot.hasError) {
                return _errorView();
              } else {
                List<CommentTimeline> commentTimelineList = snapshot.data ?? <CommentTimeline>[];

                return Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(width: 154, child: _drawer(context, ref)),
                    Expanded(
                      child: RefreshIndicator(
                        child: CommentTimelineView(commentTimelineList: commentTimelineList),
                        onRefresh: () async => {viewModel.refreshTimelineList()},
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        );
      }
    });
  }

  Widget _floatingActionButtons(BuildContext context, WidgetRef ref) {
    return Column(children: [
      const Spacer(),
      Row(children: [
        Expanded(child: Container(width: 0)),
        draftButton(herotag: herotag),
        const SizedBox(width: 12),
        FloatingActionButton(
          heroTag: herotag,
          child: Icon(KiiteIcons.edit),
          onPressed: () {
            _editButtonPressed(context, ref);
          },
        ),
      ]),
    ]);
  }

  Widget _reloadButton() {
    return IconButton(
      icon: Icon(KiiteIcons.reload),
      onPressed: () => {viewModel.refreshTimelineList()},
    );
  }

  void _editButtonPressed(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(dailyEditViewModelProvider);
    viewModel.initControllers(context);
    ref.read(dailyEditViewModelProvider.state).state = viewModel;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DailyEditScreen(heroTag: herotag),
      ),
    );
  }

  Widget _drawer(BuildContext context, WidgetRef ref) {
    List<String> nameList = userNameMap.values.toList();
    nameList.remove(userNameMap[FirebaseAuth.instance.currentUser!.uid]);
    nameList.sort((a, b) => a.hiragana.compareTo(b.hiragana));
    List<String> nameSanList = ['ミンナ', 'ジブン', ...nameList.san];
    nameList = ['ミンナ', 'ジブン', ...nameList];

    return Drawer(
      elevation: 0,
      child: ListView.builder(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + AppBar().preferredSize.height / 4,
        ),
        itemCount: userNameMap.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.centerLeft,
              height: 48,
              width: double.infinity,
              child: Text(nameSanList[index]),
            ),
            onTap: () => _onDrawerButtonPressed(context, ref, nameList[index]),
          );
        },
      ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('ロードデキナカッタ…'),
          const SizedBox(height: 12),
          TextButton(
            child: const Text('リロード'),
            onPressed: () => viewModel.refreshTimelineList(),
          ),
        ],
      ),
    );
  }

  void _onDrawerButtonPressed(BuildContext context, WidgetRef ref, String name) {
    if (name == 'ミンナ') {
      viewModel.filterBy = null;
    } else if (name == 'ジブン') {
      viewModel.filterBy = FirebaseAuth.instance.currentUser!.uid;
    } else {
      for (var key in userNameMap.keys) {
        if (name == userNameMap[key]) {
          viewModel.filterBy = key;
          break;
        }
      }
    }
    if (KiiteThreshold.isMobile(context)) {
      Navigator.of(context).pop();
    }
    viewModel.refreshTimelineList();
  }

  Function callback() {
    return () => setState(() {});
  }
}
