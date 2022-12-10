import 'package:flutter/material.dart';

Widget blankBalloon(BuildContext context) {
  Color hintColor = Theme.of(context).textTheme.bodyText2!.color!;
  TextStyle hintStyle =
      Theme.of(context).textTheme.bodyText2!.copyWith(color: hintColor.withOpacity(0.3));

  return Container(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(children: [
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(
          'ダレカさん',
          style: hintStyle,
        ),
        const Spacer(),
      ]),
      const SizedBox(height: 3),
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        _bodyText(context, hintStyle),
        const SizedBox(width: 6),
        _dateText(context, hintStyle),
      ]),
    ]),
  );
}

Widget _bodyText(BuildContext context, TextStyle style) {
  final borderColor = Theme.of(context).primaryColor;
  const balloonCornerRadius = Radius.circular(20);
  const balloonElevation = 1.0;

  return Expanded(
    child: Material(
      color: Theme.of(context).cardColor,
      elevation: balloonElevation,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: balloonCornerRadius,
          bottomRight: balloonCornerRadius,
          bottomLeft: balloonCornerRadius,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.zero,
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
        ),
        // color: Colors.pink,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        // width: double.infinity,
        child: Text(
          'カタカタカタカタ…',
          style: style,
        ),
      ),
    ),
  );
}

Widget _dateText(BuildContext context, TextStyle style) {
  String dateText = '--/--';
  String timeText = '--:--';

  return Column(children: [
    Text(dateText, style: style),
    Text(timeText, style: style),
  ]);
}
