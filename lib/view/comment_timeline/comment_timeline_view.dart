import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiite/model/comment_model.dart';
import 'package:kiite/view/comment_timeline/comment_timeline_item.dart';
import 'package:kiite/view/comment_timeline/comment_timeline_view_model.dart';
import 'package:visibility_detector/visibility_detector.dart';

final focus = FocusNode();

class CommentTimelineView extends StatefulWidget {
  const CommentTimelineView({Key? key, required this.commentTimelineList}) : super(key: key);
  final List<CommentTimeline> commentTimelineList;

  @override
  CommentTimelineViewState createState() => CommentTimelineViewState();
}

class CommentTimelineViewState extends State<CommentTimelineView> {
  var bottomReached = false;
  late CommentTimelineViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      viewModel = ref.watch(commentTimelineViewModelProvider);
      viewModel.timelineFirstLoad(widget.commentTimelineList);

      final scrollController = ScrollController(keepScrollOffset: true);

      return ListView(
        cacheExtent: MediaQuery.of(context).size.height * 1000,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        controller: scrollController,
        children: [
          ...viewModel.timelineList.map((e) => CommentTimelineCard(timeline: e)).toList(),
          VisibilityDetector(
            key: const Key('comment_list'),
            onVisibilityChanged: (visibilityInfo) {
              if (!bottomReached && visibilityInfo.visibleFraction > 0) {
                _loadMoreCommented(ref);
                bottomReached = true;
              }
            },
            child: Container(
              alignment: Alignment.center,
              height: 68,
              child: const CircularProgressIndicator(),
            ),
          ),
        ],
      );
    });
  }

  Future<void> _loadMoreCommented(WidgetRef ref) async {
    await viewModel.loadMoreTimeline();
    bottomReached = false;
    setState(() {});
  }
}
