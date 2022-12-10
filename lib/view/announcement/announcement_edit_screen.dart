import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiite/model/kiite_colors.dart';
import 'package:kiite/model/kiite_Threshold.dart';
import 'package:kiite/model/announcement_model.dart';
import 'package:kiite/view/announcement/announcement_edit_components.dart';
import 'package:kiite/view/daily_edit/daily_edit_view_model.dart';

class AnnouncementEditScreen extends StatefulWidget {
  const AnnouncementEditScreen({Key? key}) : super(key: key);

  @override
  State<AnnouncementEditScreen> createState() => _AnnouncementEditScreenState();
}

class _AnnouncementEditScreenState extends State<AnnouncementEditScreen> {
  @override
  Widget build(BuildContext context) {
    const basicMargin = 4.0;

    return Consumer(builder: (context, ref, child) {
      final viewModel = ref.watch(announcementListScreenViewModelProvider);
      final repository = ref.watch(announcementRepositoryProvider)!;
      final sendButtonText = viewModel.id == null ? '投稿' : '変更';

      Future<void> onSend() async {
        showNetworkingCircular(context);
        if (viewModel.id == null) {
          await repository.post(viewModel.announcement()).then((value) {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          }).catchError((e) {
            Navigator.of(context).pop();
          });
        } else {
          await repository.update(viewModel.announcement()).then((value) {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          }).catchError((e) {
            Navigator.of(context).pop();
          });
        }
      }

      Future<void> onDelete() async {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) {
            return AlertDialog(
              title: const Text("削除しますか？"),
              actions: [
                TextButton(
                  child: const Text("戻る"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text("削除"),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    showNetworkingCircular(context);
                    await repository.delete(viewModel.id!).then((value) {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    }).catchError((e) {
                      Navigator.of(context).pop();
                    });
                  },
                ),
              ],
            );
          },
        );
      }

      Widget deleteButton() {
        if (viewModel.id != null) {
          return IconButton(
            onPressed: () => onDelete(),
            icon: const Icon(Icons.delete_forever_rounded),
          );
        } else {
          return Container();
        }
      }

      Widget fieldView() {
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            // タイトル、公開日
            Row(children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text('タイトル'),
              )
            ]),
            Row(children: [
              Flexible(flex: 2, child: announcementTitleField(ref)),
              const SizedBox(width: basicMargin),
              Flexible(flex: 1, child: deliverDatePicker(context, ref, () => setState(() {}))),
            ]),
            const SizedBox(height: basicMargin),

            // 本文
            Row(children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text('本文'),
              )
            ]),
            bodyField(ref),
            const SizedBox(height: basicMargin),

            // リアクション
            Row(children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text('対応ボタン'),
              )
            ]),
            Row(children: [
              Flexible(flex: 2, child: reacitonField(ref)),
              const SizedBox(width: basicMargin),
              Flexible(flex: 1, child: dueDatePicker(context, ref, () => setState(() {}))),
            ]),
            // ),
            const SizedBox(height: basicMargin * 3),

            // 投稿ボタン
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              ElevatedButton(
                onPressed: () async => onSend(),
                child: Padding(padding: const EdgeInsets.all(8), child: Text(sendButtonText)),
              ),
              const SizedBox(width: 3.2),
            ]),
          ],
        );
      }

      return Scaffold(
        appBar: AppBar(
          title: const Text('おしらせ投稿'),
          actions: [deleteButton()],
        ),
        body: Container(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: KiiteThreshold.tablet),
            child: FutureBuilder(
                future: ref.watch(futureAnnouncementProvider),
                builder: (context, AsyncSnapshot<Announcement> snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (!snapshot.hasData) {
                    return const Center(child: Text('取得できませんでした'));
                  } else if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  } else {
                    if (viewModel.firstBuild) {
                      viewModel.initForEdit(snapshot.data!);
                      viewModel.firstBuild = false;
                    }
                    return fieldView();
                  }
                }),
          ),
        ),
      );
    });
  }
}
