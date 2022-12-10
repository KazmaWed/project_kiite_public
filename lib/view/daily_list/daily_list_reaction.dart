import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiite/model/kiite_colors.dart';
import 'package:kiite/model/kiite_icons.dart';
import 'package:kiite/model/reaction_model.dart';
import 'package:kiite/view/daily_edit/daily_edit_view_model.dart';

class ReactionIcons extends ConsumerWidget {
  const ReactionIcons({Key? key, required this.daily}) : super(key: key);
  final Daily daily;

  @override
  Widget build(context, ref) {
    final repository = ref.watch(reactionRepositoryProvider)!;
    final futureLikedBy = repository.futureLikedBy(daily.id!);
    final futureEncouragedBy = repository.futureEncouragedBy(daily.id!);
    final futureInspired = repository.futureInspired(daily.id!);
    final futureAll = Future.wait([futureLikedBy, futureEncouragedBy, futureInspired]);

    return FutureBuilder(
      future: futureAll,
      builder: (BuildContext context, AsyncSnapshot<List<Set<String>>> snapshot) {
        // データ取得中
        if (!snapshot.hasData) {
          return Container();
        } else {
          final reaction = Reaction();
          reaction.likedBy = snapshot.data![0];
          reaction.encouragedBy = snapshot.data![1];
          reaction.inspired = snapshot.data![2];

          return stamps(context, reaction);
        }
      },
    );
  }
}

// Widget ReactionIcons(Daily daily) {
//   return Consumer(builder: (context, ref, child) {
//     final repository = ref.watch(reactionRepositoryProvider)!;
//     final futureLikedBy = repository.futureLikedBy(daily.id!);
//     final futureEncouragedBy = repository.futureEncouragedBy(daily.id!);
//     final futureInspired = repository.futureInspired(daily.id!);
//     final futureAll = Future.wait([futureLikedBy, futureEncouragedBy, futureInspired]);

//     return FutureBuilder(
//         future: futureAll,
//         builder: (BuildContext context, AsyncSnapshot<List<Set<String>>> snapshot) {
//           // データ取得中
//           if (!snapshot.hasData) {
//             return Container();
//           }

//           final reaction = Reaction();
//           reaction.likedBy = snapshot.data![0];
//           reaction.encouragedBy = snapshot.data![1];
//           reaction.inspired = snapshot.data![2];

//           return stamps(context, reaction);
//         });
//   });
// }

Widget stamps(BuildContext context, Reaction reaction) {
  double iconSize = 18;
  double countFontSize = Theme.of(context).textTheme.overline!.fontSize!;

  List<Widget> icons = [];
  if (reaction.inspired.isNotEmpty) {
    // アイコン
    icons.add(Icon(KiiteIcons.light, color: KiiteColors.iconYellow, size: iconSize));
    icons.add(const SizedBox(width: 1));
    icons.add(
      Column(children: [
        const SizedBox(height: 6),
        Text(
          reaction.inspired.length.toString(),
          style: TextStyle(
            color: KiiteColors.textYellow,
            fontSize: countFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ]),
    );
    icons.add(const SizedBox(width: 4));
  }
  if (reaction.encouragedBy.isNotEmpty) {
    // アイコン
    icons.add(Icon(KiiteIcons.tape, color: KiiteColors.blue, size: iconSize));
    icons.add(const SizedBox(width: 3));
    icons.add(
      Column(children: [
        const SizedBox(height: 6),
        Text(
          reaction.encouragedBy.length.toString(),
          style: TextStyle(
            color: KiiteColors.blue,
            fontSize: countFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ]),
    );
    icons.add(const SizedBox(width: 4));
  }
  if (reaction.likedBy.isNotEmpty) {
    // アイコン
    icons.add(
      Icon(KiiteIcons.heart, color: KiiteColors.pink, size: iconSize),
    );
    icons.add(const SizedBox(width: 2));
    icons.add(
      Column(children: [
        const SizedBox(height: 6),
        Text(
          reaction.likedBy.length.toString(),
          style: TextStyle(
            color: KiiteColors.pink,
            fontSize: countFontSize,
            fontWeight: FontWeight.bold,
          ),
        )
      ]),
    );
    icons.add(const SizedBox(width: 4));
  }
  icons.add(const SizedBox(width: 2));

  return Row(children: icons);
}
