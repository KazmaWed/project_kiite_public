import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:kiite/model/kiite_icons.dart';
import 'package:kiite/view/daily_edit/daily_edit_view_model.dart';

class DatePickerView extends StatefulWidget {
  const DatePickerView({Key? key}) : super(key: key);

  @override
  DatePickerViewState createState() => DatePickerViewState();
}

class DatePickerViewState extends State<DatePickerView> {
  late DailyEditViewModel viewModel;

  double horizontalInset = 16;
  double verticalInset = 12;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        viewModel = ref.watch(dailyEditViewModelProvider);

        return Card(
          clipBehavior: Clip.antiAlias,
          borderOnForeground: false,
          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: horizontalInset, vertical: verticalInset),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(KiiteIcons.today, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 12),
                  Text(
                    DateFormat('yyyy/MM/dd - E.').format(viewModel.dateTime),
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ],
              ),
            ),
            onTap: () {
              _selectDate(context, ref);
            },
          ),
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context, WidgetRef ref) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: viewModel.dateTime,
      firstDate: DateTime(2022, 1, 1),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => viewModel.dateTime = picked);
    }
  }
}
