import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kiite/model/kiite_Threshold.dart';
import 'package:kiite/model/kiite_icons.dart';
import 'package:kiite/view/daily_list/daily_list_reaction.dart';
import 'package:kiite/view/daily_edit/daily_edit_view_model.dart';

class DailyListCard extends ConsumerWidget {
  const DailyListCard({Key? key, required this.daily}) : super(key: key);
  final Daily daily;
  final String heroTag = 'daily_list';

  String get dailyId => daily.id!;
  final double iconSize = 18;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double elevation = ref.read(selectedDailyIdProvider) == dailyId ? 3.2 : 1;
    final shape = ref.read(selectedDailyIdProvider) == dailyId
        ? RoundedRectangleBorder(
            side: BorderSide(color: Theme.of(context).primaryColor),
            borderRadius: const BorderRadius.all(Radius.circular(4)))
        : null;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: elevation,
      // shadowColor: shadowColor,
      shape: shape,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  userNameText(context, ref, daily.authorId!),
                  photoIcon(context),
                  const Spacer(),
                  ReactionIcons(daily: daily),
                  dateTimeText(context, daily),
                ],
              ),
            ],
          ),
        ),
        onTap: () => onTap(context, ref, daily),
      ),
    );
  }

  Widget userNameText(BuildContext context, WidgetRef ref, String authorId) {
    final userNickname = userNameMap[authorId] == null ? 'ダレカさん' : '${userNameMap[authorId]!}さん';
    final textStyle = TextStyle(color: Theme.of(context).primaryColor);

    return Text(userNickname, style: textStyle);
  }

  Widget dateTimeText(BuildContext context, Daily daily) {
    return Row(children: [
      Container(
        alignment: Alignment.centerRight,
        width: 46,
        child: Text(
          DateFormat('MM/dd').format(daily.dateTime),
          style: Theme.of(context).textTheme.bodyText2,
        ),
      ),
      const SizedBox(width: 6),
      Container(
        alignment: Alignment.centerLeft,
        width: 34,
        child: Text(
          DateFormat('E.').format(daily.dateTime),
          maxLines: 1,
        ),
      ),
    ]);
  }

  Widget photoIcon(BuildContext context) {
    if (daily.photoList.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Icon(
          KiiteIcons.attach,
          // color: Theme.of(context).primaryColor.withOpacity(KiiteColors.iconOpacity),
          color: Theme.of(context).primaryColor,
          size: iconSize,
        ),
      );
    } else {
      return Container();
    }
  }

  Future<void> onTap(BuildContext context, WidgetRef ref, Daily daily) async {
    if (KiiteThreshold.isPC(context)) {
      await ref.read(dailyDetailViewModelProvider).initControllers(daily).then((value) async {
        ref.read(selectedDailyIdProvider.state).state = daily.id!;
      });
    } else {
      final viewModel = ref.watch(dailyListViewModelProvider);
      // 連打ガード
      if (viewModel.firstTap) {
        viewModel.firstTap = false;

        // 遷移前に初期化
        await ref.read(dailyDetailViewModelProvider).initControllers(daily).then((value) async {
          // 遷移
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DailyDetailView(daily: daily, heroTag: heroTag),
            ),
          );
          // 戻ってきた時にsetState()
          ref.read(dailyListViewModelProvider).callback();
          viewModel.firstTap = true;
        });
      }
    }
  }
}
