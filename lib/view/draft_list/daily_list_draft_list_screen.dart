import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiite/view/draft_list/daily_list_draft_list_view.dart';
import 'package:kiite/view/daily_edit/daily_edit_view_model.dart';

class DraftListScreen extends ConsumerWidget {
  const DraftListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Consumer(builder: (context, ref, child) {
      final futureDraftList = ref.watch(futureDraftListProvider);

      return Scaffold(
        appBar: AppBar(
          title: const Text('シタガキ'),
        ),
        body: FutureBuilder(
          future: futureDraftList,
          builder: (BuildContext context, AsyncSnapshot<List<Daily>> snapshot) {
            // 通信中はスピナーを表示
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            // エラー発生時はエラーメッセージを表示
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }

            final draftList = snapshot.data ?? <Daily>[];
            return DraftListView(dailyList: draftList);
          },
        ),
      );
    });
  }
}
