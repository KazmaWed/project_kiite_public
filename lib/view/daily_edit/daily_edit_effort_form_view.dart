import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiite/model/kiite_icons.dart';
import 'package:kiite/view/daily_edit/daily_edit_view_model.dart';

class EffortFormView extends StatefulWidget {
  const EffortFormView({Key? key}) : super(key: key);

  @override
  State<EffortFormView> createState() => _EffortFormViewState();
}

class _EffortFormViewState extends State<EffortFormView> {
  late DailyEditViewModel viewModel;
  late double totalLength;

  @override
  Widget build(BuildContext context) {
    double horizontalInset = 16;
    double topInset = 16;
    double bottomInstet = 8;

    return Consumer(builder: ((context, ref, child) {
      totalLength = ref.watch(dailyTotalEffortLength);
      viewModel = ref.watch(dailyEditViewModelProvider);

      return Card(
        child: Container(
          padding: EdgeInsets.fromLTRB(horizontalInset, topInset, horizontalInset, bottomInstet),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(KiiteIcons.timer, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'ジカン',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Expanded(child: Container(width: double.infinity)),
                  Text(
                    'トータル  ${totalLength.toString()} h',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
              const SizedBox(height: 12),
              Column(children: [
                for (var idx = 0; idx < viewModel.effortItemNum; idx++)
                  EffortItem(context: context, ref: ref, index: idx),
              ]),
            ],
          ),
        ),
      );
    }));
  }
}
