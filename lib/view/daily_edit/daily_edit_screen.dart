import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiite/model/kiite_colors.dart';
import 'package:kiite/model/kiite_icons.dart';
import 'package:kiite/model/kiite_Threshold.dart';
import 'package:kiite/model/kiite_snackbar.dart';
import 'package:kiite/provider/confirm_tab_close_stream.dart';
import 'package:kiite/view/daily_edit/daily_edit_view_model.dart';

// ignore: must_be_immutable
class DailyEditScreen extends ConsumerWidget {
  DailyEditScreen({Key? key, required this.heroTag}) : super(key: key);
  final String heroTag;
  late DailyEditViewModel viewModel;
  bool networking = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // タブを閉じるときの確認
    ref.watch(confirmTabCloseStreamProvider);

    viewModel = ref.watch(dailyEditViewModelProvider);
    String appBarTitle = '';
    if (viewModel.editingDaily == null) {
      appBarTitle = 'シンキ';
    } else if (viewModel.draft) {
      appBarTitle = 'シタガキ';
    } else {
      appBarTitle = 'ヘンシュウ';
    }

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: KiiteThreshold.maxWidth),
          child: Scaffold(
            appBar: AppBar(
              title: Text(appBarTitle),
              leading: _backButton(context, ref),
              actions: _draftDeleteButton(context, ref),
            ),
            body: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Container(
                height: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: SingleChildScrollView(
                  child: [
                    if (KiiteThreshold.isMobile(context)) mobileMode(),
                    if (KiiteThreshold.isPC(context)) tabletMode(),
                  ].first,
                ),
              ),
            ),
            floatingActionButton: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: heroTag,
                  child: Icon(KiiteIcons.send),
                  onPressed: () {
                    _onDailyUpload(context, ref);
                  },
                ),
                SizedBox(height: iosWebSafeAreaInset),
              ],
            ),
          ),
        ),
      ),
      // ),
    );
  }

  Widget mobileMode() {
    return Column(
      children: const [
        DatePickerView(),
        SizedBox(height: 4),
        EffortFormView(),
        SizedBox(height: 4),
        DailyEditBodyView(),
        SizedBox(height: 4),
        ImagePickerView(),
        SizedBox(height: 104, width: double.infinity),
      ],
    );
  }

  Widget tabletMode() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: const [
              DatePickerView(),
              SizedBox(height: 4),
              EffortFormView(),
              SizedBox(height: 4),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: const [
              DailyEditBodyView(),
              SizedBox(height: 4),
              ImagePickerView(),
              SizedBox(height: 104, width: double.infinity),
            ],
          ),
        ),
      ],
    );
  }

  // 送信ボタンタップ
  Future<void> _onDailyUpload(BuildContext context, WidgetRef ref) async {
    if (!networking) {
      networking = true;
      await _dailyUpload(context, ref, viewModel);
      networking = false;
    }
  }

  // 戻るボタン
  Widget _backButton(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: Icon(KiiteIcons.clear),
      onPressed: () {
        _onBackButton(context, ref);
      },
    );
  }

  // 下書き削除ボタンウィジット
  List<Widget>? _draftDeleteButton(BuildContext context, WidgetRef ref) {
    if (viewModel.draft) {
      return [
        IconButton(
          icon: Icon(KiiteIcons.bin),
          onPressed: () {
            _onDraftDeleteButton(context, ref);
          },
        )
      ];
    } else {
      return null;
    }
  }

  // 下書き削除ボタンタップ
  Future<void> _onDraftDeleteButton(BuildContext context, WidgetRef ref) async {
    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          actionsPadding: const EdgeInsets.only(bottom: 8, right: 8),
          title: const Text('削除スル？'),
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
                _deleteDraft(context, ref);
              },
            ),
          ],
        );
      },
    );
  }

  // 下書き削除
  Future<void> _deleteDraft(BuildContext context, WidgetRef ref) async {
    // 連続タップガード
    if (!networking) {
      networking = true;
      // インジケーター
      Navigator.of(context).pop();
      showNetworkingCircular(context);

      viewModel.removeDraft();
      // リストを更新
      _refreshList(ref);
      Navigator.of(context).pop();
      Navigator.of(context).pop();

      networking = false;
    }
  }

  // 戻るボタンタップ
  Future<void> _onBackButton(BuildContext context, WidgetRef ref) async {
    // 分岐条件
    final creatingNewDairy = !viewModel.getDaily.isBlank() && viewModel.editingDaily == null;
    final editingDairy = !viewModel.getDaily.isBlank() && viewModel.editingDaily != null;
    final editingDraft = !viewModel.getDaily.isBlank() && viewModel.draft;

    if (creatingNewDairy) {
      // ---------- 新規作成時 ----------
      await showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            actionsPadding: const EdgeInsets.only(bottom: 8, right: 8),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('下書きを保存スル？'),
                const SizedBox(height: 4),
                Text(
                  '※ 写真は保存されません',
                  style: Theme.of(context).textTheme.bodyText2!.copyWith(color: KiiteColors.grey),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("シナイ"),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
              TextButton(
                child: const Text("スル"),
                onPressed: () {
                  // 連続タップガード
                  if (!networking) {
                    networking = true;
                    _saveDraft(context, ref, viewModel);
                    networking = false;
                  }
                },
              ),
            ],
          );
        },
      );
    } else if (editingDraft) {
      // ---------- 下書き編集時 ----------
      await showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            actionsPadding: const EdgeInsets.only(bottom: 8, right: 8),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('変更を保存スル？'),
                const SizedBox(height: 4),
                Text('※ 写真は保存されません',
                    style:
                        Theme.of(context).textTheme.bodyText2!.copyWith(color: KiiteColors.grey)),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("シナイ"),
                onPressed: () => {Navigator.of(context).pop(), Navigator.of(context).pop()},
              ),
              TextButton(
                child: const Text("スル"),
                onPressed: () {
                  // 連続タップガード
                  if (!networking) {
                    networking = true;
                    _updateDraft(context, ref, viewModel);
                    networking = false;
                  }
                },
              ),
            ],
          );
        },
      );
    } else if (editingDairy) {
      // ---------- 投稿済みダイアリー編集時 ----------
      await showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            actionsPadding: const EdgeInsets.only(bottom: 8, right: 8),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('変更を保存スル？'),
              ],
            ),
            actions: <Widget>[
              // ボタン領域
              TextButton(
                child: const Text("シナイ"),
                onPressed: () => {Navigator.of(context).pop(), Navigator.of(context).pop()},
              ),
              TextButton(
                child: const Text("スル"),
                onPressed: () {
                  // 連続タップガード
                  if (!networking) {
                    networking = true;
                    _updateDaily(context, ref, viewModel);
                    networking = false;
                  }
                },
              ),
            ],
          );
        },
      );
    } else {
      Navigator.of(context).pop();
    }

    ref.read(dailyTotalEffortLength.state).state = 0.0;
  }
}

// DailyListViewの更新
Future<void> _refreshList(WidgetRef ref) async {
  ref.read(dailyListViewModelProvider).refreshDailyList();
}

Future<void> _dailyUpload(BuildContext context, WidgetRef ref, DailyEditViewModel viewModel) async {
  final newPost = !viewModel.draft && viewModel.editingDaily != null;
  final postDraft = viewModel.draft;

  late Future<bool> futureSucceed;

  // Firebaseアップロード
  showNetworkingCircular(context);

  if (newPost) {
    // 投稿記事編集時
    futureSucceed = viewModel.updateDaily();
  } else if (postDraft) {
    // 下書き変更時
    futureSucceed = viewModel.postDraft();
  } else {
    // 新規投稿または
    futureSucceed = viewModel.addDaily();
  }

  await futureSucceed.then((succeed) {
    if (succeed) {
      KiiteSnackBar(context).posted();
      _refreshList(ref); // リストを更新
      Navigator.of(context).popUntil((route) => route.isFirst); // トップに遷移
      ref.read(dailyTotalEffortLength.state).state = 0.0; // 合計時間初期化
    } else {
      Navigator.of(context).pop();
      KiiteSnackBar(context).postFailed();
    }
  });

  // 下書きの場合は削除
  if (viewModel.draft) {
    await viewModel.removeDraft();
  }
}

// 下書き保存
Future<void> _saveDraft(BuildContext context, WidgetRef ref, DailyEditViewModel viewModel) async {
  showNetworkingCircular(context);
  await viewModel.saveDraft().then((succeed) {
    if (succeed) {
      _refreshList(ref);
      Navigator.of(context).popUntil((route) => route.isFirst);
      KiiteSnackBar(context).saved();
    } else {
      Navigator.of(context).pop();
      KiiteSnackBar(context).saveFailed();
    }
  });
}

//
Future<void> _updateDraft(BuildContext context, WidgetRef ref, DailyEditViewModel viewModel) async {
  showNetworkingCircular(context);
  await viewModel.updateDraft(context).then((succeed) {
    if (succeed) {
      _refreshList(ref);
      Navigator.of(context).popUntil((route) => route.isFirst);
      KiiteSnackBar(context).saved();
    } else {
      Navigator.of(context).pop();
      KiiteSnackBar(context).saveFailed();
    }
  });
}

Future<void> _updateDaily(BuildContext context, WidgetRef ref, DailyEditViewModel viewModel) async {
  // インジケーター表示
  Navigator.of(context).pop();
  showNetworkingCircular(context);
  await viewModel.updateDaily().then((succeed) {
    if (succeed) {
      _refreshList(ref);
      Navigator.of(context).popUntil((route) => route.isFirst);
      KiiteSnackBar(context).saved();
    } else {
      Navigator.of(context).pop();
      KiiteSnackBar(context).saveFailed();
    }
  });
}
