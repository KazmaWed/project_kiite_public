import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kiite/model/kiite_icons.dart';
import 'package:kiite/model/transport_fee_model.dart';

class FeeDemandHistoryItem extends StatelessWidget {
  const FeeDemandHistoryItem({Key? key, required this.fee}) : super(key: key);
  final TransportFee fee;

  @override
  Widget build(BuildContext context) {
    const iconColumnWidth = 36.0;
    const iconEndMargin = 8.0;

    return Card(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          children: [
            Row(children: [
              SizedBox(
                width: iconColumnWidth,
                child: Icon(
                  KiiteIcons.today,
                  color: Theme.of(context).primaryColor,
                  // color: Theme.of(context).primaryColor.withOpacity(KiiteColors.iconOpacity),
                ),
              ),
              const SizedBox(width: iconEndMargin),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    DateFormat('yyyy/MM/dd - E.').format(fee.used),
                    style: TextStyle(fontSize: Theme.of(context).textTheme.bodyText1!.fontSize),
                  ),
                  const SizedBox(height: 2),
                  SelectableText(
                    DateFormat('申請日 yyyy/MM/dd - E.').format(fee.posted),
                    style: TextStyle(
                        fontSize: Theme.of(context).textTheme.caption!.fontSize,
                        color: Colors.grey),
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  alignment: Alignment.centerRight,
                  child: SelectableText('${NumberFormat('#,###').format(fee.price)}円',
                      style: TextStyle(
                        fontSize: Theme.of(context).textTheme.bodyText1!.fontSize,
                      )),
                ),
              ),
            ]),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Container(height: 0.1, color: Colors.black),
            ),
            Row(children: [
              SizedBox(
                width: iconColumnWidth,
                child: Icon(
                  KiiteIcons.startPlace, color: Theme.of(context).primaryColor,
                  // color: Theme.of(context).primaryColor.withOpacity(KiiteColors.iconOpacity),
                ),
              ),
              const SizedBox(width: iconEndMargin),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(fee.fromTitle),
                  SelectableText(fee.fromStation),
                ],
              ),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              SizedBox(
                width: iconColumnWidth,
                child: Icon(
                  KiiteIcons.endPlace, color: Theme.of(context).primaryColor,
                  // color: Theme.of(context).primaryColor.withOpacity(KiiteColors.iconOpacity),
                ),
              ),
              const SizedBox(width: iconEndMargin),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(fee.toTitle),
                  SelectableText(fee.toStation),
                ],
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
