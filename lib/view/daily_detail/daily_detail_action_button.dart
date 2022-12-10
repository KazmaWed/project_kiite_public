import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiite/model/kiite_colors.dart';
import 'package:kiite/model/kiite_icons.dart';
import 'package:kiite/model/reaction_model.dart';
import 'package:kiite/provider/firebase_provider.dart';
import 'package:kiite/provider/view_model_provider.dart';
import 'package:kiite/provider/static_value_provider.dart';

class ReactionButtonRow extends StatelessWidget {
  const ReactionButtonRow({Key? key, required this.ref, required this.dailyId}) : super(key: key);
  final WidgetRef ref;
  final String dailyId;

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(dailyDetailViewModelProvider);
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final futureLikedByList = ref.watch(reactionRepositoryProvider)!.futureLikedBy(dailyId);
    final futureEncouragedByList =
        ref.watch(reactionRepositoryProvider)!.futureEncouragedBy(dailyId);
    final futureInspiredList = ref.watch(reactionRepositoryProvider)!.futureInspired(dailyId);
    final futureAll = Future.wait([futureLikedByList, futureEncouragedByList, futureInspiredList]);

    String blankNumber = '-';

    return FutureBuilder(
      future: futureAll,
      builder: (
        BuildContext context,
        AsyncSnapshot<List<Set<String>>> snapshot,
      ) {
        // ロード中
        if (!snapshot.hasData) {
          return Row(children: [
            FloatingActionButton(
              heroTag: 'like',
              backgroundColor: KiiteColors.grey,
              onPressed: () {},
              child: Column(children: [
                Expanded(flex: 2, child: Container()),
                Expanded(
                  flex: 3,
                  child: Text(blankNumber,
                      style: TextStyle(fontSize: Theme.of(context).textTheme.overline!.fontSize)),
                ),
                Expanded(flex: 6, child: Icon(KiiteIcons.favorite)),
                Expanded(flex: 3, child: Container()),
              ]),
            ),
            const SizedBox(width: 15),
            FloatingActionButton(
              heroTag: 'encourage',
              backgroundColor: KiiteColors.grey,
              onPressed: () {},
              child: Column(children: [
                Expanded(flex: 2, child: Container()),
                Expanded(
                  flex: 3,
                  child: Text(blankNumber),
                ),
                Expanded(flex: 6, child: Icon(KiiteIcons.healing)),
                Expanded(flex: 3, child: Container()),
              ]),
            ),
            const SizedBox(width: 15),
            FloatingActionButton(
              heroTag: 'light',
              backgroundColor: KiiteColors.grey,
              onPressed: () {},
              child: Column(children: [
                Expanded(flex: 2, child: Container()),
                Expanded(
                    flex: 3,
                    child: Text(blankNumber,
                        style:
                            TextStyle(fontSize: Theme.of(context).textTheme.overline!.fontSize))),
                Expanded(flex: 6, child: Icon(KiiteIcons.light)),
                Expanded(flex: 3, child: Container()),
              ]),
            ),
            const SizedBox(width: 15),
          ]);
        }

        // ロード後
        final reactionList = snapshot.data ?? <Set<String>>[];
        // ViewModelに格納
        final reaction = Reaction();
        reaction.likedBy = reactionList[0];
        reaction.encouragedBy = reactionList[1];
        reaction.inspired = reactionList[2];

        viewModel.reaction = reaction;

        // カウント表示
        int likedIconCount = viewModel.reaction.likedBy.length;
        int encouragedCount = viewModel.reaction.encouragedBy.length;
        int inspireCount = viewModel.reaction.inspired.length;

        // ボタン色
        MaterialColor likedIconColor =
            viewModel.reaction.likedBy.contains(uid) ? KiiteColors.pink : KiiteColors.grey;
        MaterialColor encouragedIconColor =
            viewModel.reaction.encouragedBy.contains(uid) ? KiiteColors.blue : KiiteColors.grey;
        MaterialColor inspireIconColor =
            viewModel.reaction.inspired.contains(uid) ? KiiteColors.yellow : KiiteColors.grey;

        return InkWell(
          onLongPress: () => {_onLongPress(context, reaction)},
          child: Row(
            children: [
              FloatingActionButton(
                heroTag: 'like',
                backgroundColor: likedIconColor,
                onPressed: () => {viewModel.like(ref)},
                child: Column(children: [
                  Expanded(flex: 2, child: Container()),
                  Expanded(
                    flex: 3,
                    child: Text(
                      likedIconCount.toString(),
                      style: TextStyle(fontSize: Theme.of(context).textTheme.overline!.fontSize),
                    ),
                  ),
                  Expanded(flex: 6, child: Icon(KiiteIcons.favorite)),
                  Expanded(flex: 3, child: Container()),
                ]),
              ),
              const SizedBox(width: 15),
              FloatingActionButton(
                heroTag: 'encourage',
                backgroundColor: encouragedIconColor,
                onPressed: () => {viewModel.encourage(ref)},
                child: Column(children: [
                  Expanded(flex: 2, child: Container()),
                  Expanded(
                      flex: 3,
                      child: Text(encouragedCount.toString(),
                          style:
                              TextStyle(fontSize: Theme.of(context).textTheme.overline!.fontSize))),
                  Expanded(flex: 6, child: Icon(KiiteIcons.healing)),
                  Expanded(flex: 3, child: Container()),
                ]),
              ),
              const SizedBox(width: 15),
              FloatingActionButton(
                heroTag: 'light',
                backgroundColor: inspireIconColor,
                onPressed: () => {viewModel.inspiredBy(ref)},
                child: Column(children: [
                  Expanded(flex: 2, child: Container()),
                  Expanded(
                      flex: 3,
                      child: Text(inspireCount.toString(),
                          style:
                              TextStyle(fontSize: Theme.of(context).textTheme.overline!.fontSize))),
                  Expanded(flex: 6, child: Icon(KiiteIcons.light)),
                  Expanded(flex: 3, child: Container()),
                ]),
              ),
              const SizedBox(width: 15),
            ],
          ),
        );
      },
    );
  }
}

Future<void> _onLongPress(BuildContext context, Reaction reaction) async {
  if (reaction.hasData()) {
    await showDialog(
      barrierColor: Colors.black26,
      context: context,
      builder: (context) {
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Container(
              padding: const EdgeInsets.all(4),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (reaction.likedBy.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(KiiteIcons.like, color: KiiteColors.iconPink),
                          const SizedBox(width: 14),
                          _nameListColumn(reaction.likedBy, KiiteColors.pink)
                        ],
                      ),
                    if (reaction.likedBy.isNotEmpty &&
                        (reaction.encouragedBy.isNotEmpty || reaction.inspired.isNotEmpty))
                      const SizedBox(height: 8),
                    if (reaction.encouragedBy.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(KiiteIcons.healing, color: KiiteColors.iconBlue),
                          const SizedBox(width: 14),
                          _nameListColumn(reaction.encouragedBy, KiiteColors.blue)
                        ],
                      ),
                    if (reaction.encouragedBy.isNotEmpty && reaction.inspired.isNotEmpty)
                      const SizedBox(height: 8),
                    if (reaction.inspired.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(KiiteIcons.light, color: KiiteColors.iconYellow),
                          const SizedBox(width: 14),
                          _nameListColumn(reaction.inspired, KiiteColors.textYellow)
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

Widget _nameListColumn(Set<String> set, Color color) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (var uid in set)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            userNameMap[uid] == null ? 'ダレカさん' : '${userNameMap[uid]!}さん',
            style: TextStyle(color: color),
          ),
        ),
    ],
  );
}
