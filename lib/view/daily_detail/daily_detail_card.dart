import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiite/model/daily_model.dart';
import 'package:kiite/model/kiite_icons.dart';
import 'package:kiite/provider/view_model_provider.dart';
import 'package:kiite/view/common_components/link_preview.dart';
import 'package:url_launcher/url_launcher.dart';

class DairyCard extends StatelessWidget {
  const DairyCard({Key? key, required this.daily}) : super(key: key);
  final Daily daily;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      return Card(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    KiiteIcons.timer, color: Theme.of(context).primaryColor,
                    // color: Theme.of(context).primaryColor.withOpacity(KiiteColors.iconOpacity),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ジカン',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  Expanded(child: Container(width: double.infinity)),
                  totalLengthText(context, ref),
                  const SizedBox(width: 4),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(4),
                child: Column(
                  children: [
                    for (var idx = 0; idx < daily.effortList.length; idx++)
                      effortItem(context, daily.effortList[idx]),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              dailyBodyCard(daily, context),
            ],
          ),
        ),
      );
    });
  }
}

Widget effortItem(BuildContext context, Effort effort) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        SelectableText(effort.title),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 1,
            color: Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.2),
          ),
        ),
        const SizedBox(width: 8),
        SelectableText(effort.length.isEmpty ? 'N/A h' : '${effort.length} h'),
      ],
    ),
  );
}

Widget dailyBodyCard(Daily daily, BuildContext context) {
  const linkifyOptions = LinkifyOptions(
    humanize: false,
    removeWww: false,
    looseUrl: false,
    defaultToHttps: false,
    excludeLastPeriod: true,
  );

  return Container(
    alignment: Alignment.centerLeft,
    child: Column(
      children: [
        Row(
          children: [
            Icon(
              KiiteIcons.daily, color: Theme.of(context).primaryColor,
              // color: Theme.of(context).primaryColor.withOpacity(KiiteColors.iconOpacity),
            ),
            const SizedBox(width: 8),
            Text(
              'ホンブン',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
          width: double.infinity,
          // child: SelectableText(daily.body),
          child: SelectableLinkify(
            options: linkifyOptions,
            onOpen: (link) async {
              await launchUrl(Uri.parse(link.url));
            },
            text: daily.body,
          ),
        ),
        const SizedBox(height: 8),
        // linkPreviewList(daily.body),
      ],
    ),
  );
}

Widget linkPreviewList(String text) {
  final urlList = getLinkList(text);

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var url in urlList)
        Column(children: [
          const SizedBox(height: 8),
          LinkPreviewCard(url: url),
        ]),
    ],
  );
}

Widget totalLengthText(BuildContext context, WidgetRef ref) {
  final viewModel = ref.watch(dailyDetailViewModelProvider);
  String lengthStr = 'トータル ${viewModel.totalLength} h';

  return Text(
    lengthStr,
    style: TextStyle(color: Theme.of(context).primaryColor),
  );
}
