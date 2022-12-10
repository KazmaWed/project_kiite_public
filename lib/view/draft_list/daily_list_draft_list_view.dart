import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kiite/view/daily_edit/daily_edit_view_model.dart';
import 'package:kiite/view/draft_list/daily_list_draft_list_item.dart';

class DraftListView extends ConsumerWidget {
  const DraftListView({Key? key, required this.dailyList}) : super(key: key);
  final List<Daily> dailyList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        _onRefresh(ref);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: dailyList.length,
        itemBuilder: (context, index) {
          return DraftListCard(daily: dailyList[index]);
        },
      ),
    );
  }

  Future<void> _onRefresh(WidgetRef ref) async {
    final repository = ref.watch(dailyRepositoryProvider);
    ref.read(futureDraftListProvider.state).state = repository!.futureDraftList();
  }
}
