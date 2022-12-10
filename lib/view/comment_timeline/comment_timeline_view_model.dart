import 'package:kiite/view/daily_detail/daily_detail_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kiite/model/comment_model.dart';
import 'package:kiite/provider/firebase_provider.dart';

export 'package:kiite/provider/view_model_provider.dart';
export 'package:kiite/provider/firebase_provider.dart';
export 'package:kiite/provider/static_value_provider.dart';
export 'package:kiite/view/common_components/comment_timeline_comment_balloon.dart';
export 'package:kiite/view/common_components/comment_timeline_blank_balloon.dart';
export 'package:kiite/view/comment_timeline/comment_timeline_loading_view.dart';

class CommentTimelineViewModel {
  CommentTimelineViewModel(this.ref);

  final StateProviderRef ref;
  late Function callback;

  bool firstCommentListBuild = true;
  String? filterBy;
  List<CommentTimeline> timelineList = [];

  void timelineFirstLoad(List<CommentTimeline> firstTimelineList) {
    if (firstCommentListBuild) {
      // for (var element in timelineList) {
      //   commentedCardList.add(CommentTimelineCard(timeline: element));
      // }
      timelineList += firstTimelineList;
      firstCommentListBuild = false;
    }
  }

  Future<void> refreshTimelineList() async {
    firstCommentListBuild = true;
    timelineList = [];
    // FutureBuilder再描画
    ref.read(futureCommentTimelineProvider.state).state =
        ref.read(commentRepositoryProvider)!.futureCommentTLList(filterBy);
    ref.read(futureDraftListProvider.state).state =
        ref.read(dailyRepositoryProvider)!.futureDraftList();
  }

  Future<void> loadMoreTimeline() async {
    final loadedItems = await _moreCommentTimeline();
    // for (var index = 0; index < loadedItems.length; index++) {
    //   output.add(CommentTimelineCard(timeline: loadedItems[index]));
    // }
    timelineList += loadedItems;
  }

  Future<List<CommentTimeline>> _moreCommentTimeline() async {
    final repository = ref.read(commentRepositoryProvider)!;
    final timelineLoaded = await repository.additionalTimelineList(filterBy);
    return timelineLoaded;
  }
}
