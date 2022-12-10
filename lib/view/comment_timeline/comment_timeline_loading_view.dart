import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:kiite/model/kiite_icons.dart';
import 'package:kiite/view/common_components/comment_timeline_blank_balloon.dart';

class CommentTimelineLoadintView extends StatelessWidget {
  const CommentTimelineLoadintView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        for (var index = 0; index < 6; index++) const CommentTimelineLoadingItem(),
      ]),
    );
  }
}

class CommentTimelineLoadingItem extends StatelessWidget {
  const CommentTimelineLoadingItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          child: itemContent(context),
        ),
      );
    } else {
      return Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          child: Shimmer.fromColors(
            baseColor: Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.1),
            highlightColor: Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.7),
            child: itemContent(context),
          ),
        ),
      );
    }
  }
}

Widget itemContent(BuildContext context) {
  final color = Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.2);
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      Container(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 2),
        child: Row(
          children: [
            Icon(
              KiiteIcons.daily, color: Theme.of(context).primaryColor,
              // color: Theme.of(context).primaryColor.withOpacity(KiiteColors.iconOpacity),
            ),
            const SizedBox(width: 8),
            Text(
              'ダレカさん',
              style: TextStyle(color: color),
            ),
            const SizedBox(width: 4),
            Text('--/-- ---.', style: TextStyle(color: color)),
            Text('のダイアリー', style: TextStyle(color: color)),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: blankBalloon(context),
      ),
    ]),
  );
}
