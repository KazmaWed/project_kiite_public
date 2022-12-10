import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'package:kiite/view/daily_list/daily_list_view_model.dart';
import 'package:kiite/view/daily_edit/daily_edit_view_model.dart';

class DailyListView extends StatefulWidget {
  const DailyListView({Key? key, required this.dailyList}) : super(key: key);
  final List<Daily> dailyList;

  @override
  DailyListViewState createState() => DailyListViewState();
}

class DailyListViewState extends State<DailyListView> {
  var bottomReached = false;
  late DailyListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      viewModel = ref.watch(dailyListViewModelProvider);
      viewModel.createFirstItems(widget.dailyList);

      final scrollController = ScrollController(keepScrollOffset: true);

      return ListView(
        controller: scrollController,
        cacheExtent: MediaQuery.of(context).size.height * 1000,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        children: [
          ...viewModel.dailyList.map((daily) => DailyListCard(daily: daily)).toList(),
          bottomCircular(ref),
        ],
      );
    });
  }

  Widget bottomCircular(WidgetRef ref) {
    return VisibilityDetector(
      key: const Key('daily_list'),
      onVisibilityChanged: (visibilityInfo) {
        if (!bottomReached && visibilityInfo.visibleFraction > 0) {
          _loadMoreDaily(ref);
          bottomReached = true;
        }
      },
      child: Container(
        alignment: Alignment.center,
        height: 68,
        child: const CircularProgressIndicator(),
      ),
    );
  }

  Future<void> _loadMoreDaily(WidgetRef ref) async {
    await viewModel.loadMoreDailies();
    bottomReached = false;
    setState(() {});
  }
}
