import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kiite/model/kiite_colors.dart';
import 'package:kiite/model/kiite_icons.dart';
import 'package:kiite/model/daily_model.dart';
import 'package:kiite/view/daily_list/daily_list_view_model.dart';
import 'package:kiite/view/daily_edit/daily_edit_screen.dart';
import 'package:kiite/view/draft_list/daily_list_draft_list_screen.dart';

Widget draftButton({required String herotag}) {
  return Consumer(builder: (context, ref, child) {
    final futureDraftList = ref.watch(futureDraftListProvider);

    return FutureBuilder(
        future: futureDraftList,
        builder: (BuildContext context, AsyncSnapshot<List<Daily>> snapshot) {
          // 通信中はスピナーを表示
          if (snapshot.connectionState != ConnectionState.done) {
            return const SizedBox(width: 0, height: 0);
          }
          // エラー発生時はエラーメッセージを表示
          if (snapshot.hasError) {
            return const SizedBox(width: 0, height: 0);
          }

          final draftList = snapshot.data ?? <Daily>[];

          if (draftList.isNotEmpty) {
            return FloatingActionButton(
              heroTag: '${herotag}_draft',
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () async {
                if (draftList.length > 1) {
                  // -------------------- 下書きが複数 --------------------
                  _refreshList(ref);
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => const DraftListScreen()));
                } else {
                  // -------------------- 下書きが一件 --------------------
                  final viewModel = ref.watch(dailyEditViewModelProvider);
                  showNetworkingCircular(context);

                  await viewModel.initControllers(context).whenComplete(() async {
                    await viewModel.setDraft(context, draftList.first).then((succeed) {
                      Navigator.of(context).pop();
                      ref.read(dailyEditViewModelProvider.state).state = viewModel;

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DailyEditScreen(heroTag: herotag),
                        ),
                      );
                    });
                  });
                  // await viewModel.setDraft(context, draftList.first);
                  // await viewModel.initControllers(context);
                }
              },
              child: Column(children: [
                Expanded(flex: 3, child: Container()),
                Expanded(
                    flex: 4,
                    child: Text('シタガキ',
                        style: TextStyle(
                          fontSize: Theme.of(context).textTheme.overline!.fontSize,
                          letterSpacing: -0.2,
                        ))),
                Expanded(flex: 8, child: Icon(KiiteIcons.drafts)),
                Expanded(flex: 2, child: Container()),
              ]),
            );
          } else {
            return const SizedBox(height: 0, width: 0);
          }
        });
  });
}

Future<void> _refreshList(WidgetRef ref) async {
  ref.read(futureDraftListProvider.state).state =
      ref.watch(dailyRepositoryProvider)!.futureDraftList();
}
