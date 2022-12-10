import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:kiite/model/kiite_icons.dart';

class DailyListLoadingView extends StatelessWidget {
  const DailyListLoadingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        for (var index = 0; index < 24; index++) const DailyListLoadingItem(),
      ]),
    );
  }
}

class DailyListLoadingItem extends StatelessWidget {
  const DailyListLoadingItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.2);

    if (kIsWeb) {
      return Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Text('ダレカさん', style: TextStyle(color: color)),
                    const Spacer(),
                    likeIcon(context, color),
                    const SizedBox(width: 6),
                    Container(
                      alignment: Alignment.centerRight,
                      width: 46,
                      child: Text('--/--', maxLines: 1, style: TextStyle(color: color)),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      alignment: Alignment.centerLeft,
                      width: 34,
                      child: Text('---.', maxLines: 1, style: TextStyle(color: color)),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text('ダレカさん'),
                      const Spacer(),
                      likeIcon(context, color),
                      const SizedBox(width: 6),
                      Container(
                        alignment: Alignment.centerRight,
                        width: 46,
                        child: const Text('--/--', maxLines: 1),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        alignment: Alignment.centerLeft,
                        width: 34,
                        child: const Text('---.', maxLines: 1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget likeIcon(BuildContext context, Color color) {
    double iconSize = 18;
    double countFontSize = Theme.of(context).textTheme.overline!.fontSize!;

    return Row(children: [
      Icon(KiiteIcons.heart, color: color, size: iconSize),
      const SizedBox(width: 2),
      Column(children: [
        const SizedBox(height: 6),
        Text(
          '-',
          style: TextStyle(
            color: color,
            fontSize: countFontSize,
            fontWeight: FontWeight.bold,
          ),
        )
      ]),
    ]);
  }
}
