import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiite/model/kiite_colors.dart';
import 'package:kiite/model/kiite_icons.dart';
import 'package:kiite/model/kiite_Threshold.dart';
import 'package:kiite/view/daily_list/daily_list_view_model.dart';
import 'package:kiite/view/daily_edit/daily_edit_view_model.dart';

class DailyListScreen extends StatefulWidget {
  const DailyListScreen({Key? key}) : super(key: key);

  @override
  DailyListScreenState createState() => DailyListScreenState();
}

class DailyListScreenState extends State<DailyListScreen> {
  String herotag = 'daily_list';
  late DailyListViewModel viewModel;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      viewModel = ref.watch(dailyListViewModelProvider);
      ref.read(dailyListViewModelProvider).callback = callback();
      final futureDailyList = ref.watch(futureDailyListProvider);

      if (KiiteThreshold.isMobile(context)) {
        // --------- モバイル ---------
        return Scaffold(
          appBar: AppBar(
            title: const Text('ダイアリーA'),
            leading: IconButton(
              icon: Icon(KiiteIcons.filter),
              onPressed: () => _scaffoldKey.currentState!.openDrawer(),
            ),
            actions: [_reloadButton()],
          ),
          key: _scaffoldKey,
          drawer: _drawer(context, ref),
          floatingActionButton: _floatingActionButtons(context, ref),
          body: FutureBuilder(
            future: futureDailyList,
            builder: (BuildContext context, AsyncSnapshot<List<Daily>> snapshot) {
              // 通信中
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: DailyListLoadingView());
              } else if (snapshot.hasError) {
                return _errorView();
              } else {
                // 読み込み成功で表示
                List<Daily> dailyList = snapshot.data ?? <Daily>[];

                return RefreshIndicator(
                  child: DailyListView(dailyList: dailyList),
                  // オーバースクロールでリロード
                  onRefresh: () async => {viewModel.refreshDailyList()},
                );
              }
            },
          ),
        );
      } else {
        // --------- タブレット ---------
        return Scaffold(
          appBar: AppBar(
            title: const Text('ダイアリーB'),
            actions: [_reloadButton()],
          ),
          key: _scaffoldKey,
          floatingActionButton: _floatingActionButtons(context, ref),
          body: FutureBuilder(
            future: futureDailyList,
            builder: (BuildContext context, AsyncSnapshot<List<Daily>> snapshot) {
              // 通信中
              if (snapshot.connectionState != ConnectionState.done) {
                return Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(width: 148, child: _drawer(context, ref)),
                    const Expanded(
                      child: DailyListLoadingView(),
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return _errorView();
              } else {
                // 読み込み成功で表示
                List<Daily> dailyList = snapshot.data ?? <Daily>[];

                return Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(
                      width: 148,
                      child: _drawer(context, ref),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        // オーバースクロールでリロード
                        onRefresh: () async => {viewModel.refreshDailyList()},
                        child: DailyListView(dailyList: dailyList),
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
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          draftButton(herotag: herotag),
          const SizedBox(width: 12),
          FloatingActionButton(
            heroTag: herotag,
            child: Icon(KiiteIcons.edit),
            onPressed: () {
              _editButtonPressed(context, ref);
            },
          ),
        ],
      ),
    ]);
  }

  // 編集ボタン
  Future<void> _editButtonPressed(BuildContext context, WidgetRef ref) async {
    final viewModel = ref.watch(dailyEditViewModelProvider);
    await viewModel.initControllers(context).then((value) {
      ref.read(dailyEditViewModelProvider.state).state = viewModel;

      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => DailyEditScreen(heroTag: herotag)),
      );
    });
  }

  // 通信エラー時
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
            onPressed: () => viewModel.refreshDailyList(),
          ),
        ],
      ),
    );
  }

  // リロードボタン
  Widget _reloadButton() {
    return IconButton(
      icon: Icon(KiiteIcons.reload),
      onPressed: () => {viewModel.refreshDailyList()},
    );
  }

  // ドロアー (ハンバーガー)
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

  // ドロアータップ
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
    viewModel.refreshDailyList();
  }

  Function callback() {
    return () => setState(() {});
  }
}
