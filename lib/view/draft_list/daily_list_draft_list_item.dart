import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kiite/view/daily_edit/daily_edit_view_model.dart';

class DraftListCard extends ConsumerWidget {
  const DraftListCard({Key? key, required this.daily}) : super(key: key);
  final Daily daily;
  final String herotag = 'daily_list';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  draftDateTimeText(context, daily),
                  const Spacer(),
                  draftDatePostetText(context, daily),
                ],
              ),
            ],
          ),
        ),
        onTap: () {
          _onTap(context, ref, daily);
        },
      ),
    );
  }

  Widget draftDateTimeText(BuildContext context, Daily daily) {
    return Row(children: [
      Container(
        // color: KiiteColors.yellow,
        alignment: Alignment.centerLeft,
        child: Text(DateFormat('MM/dd E.').format(daily.dateTime),
            style: TextStyle(color: Theme.of(context).primaryColor)),
      ),
      const SizedBox(width: 4),
      const Text('のシタガキ'),
    ]);
  }

  Widget draftDatePostetText(BuildContext context, Daily daily) {
    return Text(
      'Saved on\n${DateFormat('MM/dd E. ').format(daily.posted)}',
      textAlign: TextAlign.right,
      style:
          TextStyle(color: Colors.grey, fontSize: Theme.of(context).textTheme.overline!.fontSize),
    );
  }

  void _onTap(BuildContext context, WidgetRef ref, Daily daily) {
    var viewModel = ref.watch(dailyEditViewModelProvider);
    viewModel.setDraft(context, daily);
    ref.read(dailyEditViewModelProvider.state).state = viewModel;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DailyEditScreen(heroTag: herotag),
      ),
    );
  }
}
