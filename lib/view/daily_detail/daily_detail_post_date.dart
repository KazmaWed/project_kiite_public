import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kiite/model/kiite_colors.dart';

class DailyDetailPostDateView extends StatelessWidget {
  const DailyDetailPostDateView({Key? key, required this.dateTime}) : super(key: key);
  final DateTime dateTime;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          'Posted on ${DateFormat('y M/d E. H:m').format(dateTime)}',
          style: TextStyle(
              fontSize: Theme.of(context).textTheme.caption!.fontSize, color: KiiteColors.grey),
        ),
      ),
      const Spacer(),
    ]);
  }
}
