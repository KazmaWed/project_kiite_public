import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiite/model/comment_model.dart';
import 'package:intl/intl.dart';
import 'package:kiite/provider/static_value_provider.dart';
import 'package:url_launcher/url_launcher.dart';

// -------------------- コメントアイテム --------------------

Widget commentBalloon(BuildContext context, Comment comment, bool fromRight, bool selectable) {
  final borderColor = Theme.of(context).primaryColor;
  const balloonCornerRadius = Radius.circular(20);
  // const balloonElevation = 1.0;

  String dateText() {
    String output;
    if (DateTime.now().difference(comment.posted).inMinutes < 60) {
      output = DateTime.now().difference(comment.posted).inMinutes.toString();
      output += '分前';
    } else if (DateTime.now().difference(comment.posted).inHours < 24) {
      output = DateTime.now().difference(comment.posted).inHours.toString();
      output += '時間前';
    } else if (DateTime.now().difference(comment.posted).inDays < 2) {
      output = '昨日\n';
      output += DateFormat('H:mm').format(comment.posted);
    } else if (DateTime.now().difference(comment.posted).inDays <= 7) {
      output = DateTime.now().difference(comment.posted).inDays.toString();
      output += '日前\n';
      output += DateFormat('H:mm').format(comment.posted);
    } else {
      output = DateFormat('M/d\nH:mm').format(comment.posted);
    }
    return output;
  }

  if (!fromRight) {
    return Consumer(builder: (context, ref, child) {
      return Container(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            _userNameText(context, ref, comment.authorId!, selectable),
            const Spacer(),
          ]),
          const SizedBox(height: 3),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(
              child: Card(
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
                      topRight: balloonCornerRadius,
                      bottomRight: balloonCornerRadius,
                      bottomLeft: balloonCornerRadius,
                    ),
                  ),
                  // color: Colors.pink,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  // width: double.infinity,
                  child: bodyText(comment.body, selectable),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(dateText(),
                style: TextStyle(fontSize: Theme.of(context).textTheme.caption!.fontSize)),
          ]),
        ]),
      );
    });
  } else {
    return Consumer(
      builder: (context, ref, child) {
        return Container(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(children: [
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              const Spacer(),
              _userNameText(context, ref, comment.authorId!, selectable),
            ]),
            const SizedBox(height: 2),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(dateText(),
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: Theme.of(context).textTheme.caption!.fontSize)),
              const SizedBox(width: 8),
              Expanded(
                child: Card(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: balloonCornerRadius,
                      bottomRight: balloonCornerRadius,
                      bottomLeft: balloonCornerRadius,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: borderColor),
                      borderRadius: const BorderRadius.only(
                        topLeft: balloonCornerRadius,
                        topRight: Radius.zero,
                        bottomRight: balloonCornerRadius,
                        bottomLeft: balloonCornerRadius,
                      ),
                    ),
                    // color: Colors.pink,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    // width: double.infinity,
                    child: bodyText(comment.body, selectable),
                  ),
                ),
              ),
            ]),
          ]),
        );
      },
    );
  }
}

// -------------------- コメントアイテム内の名前 --------------------

Widget _userNameText(BuildContext context, WidgetRef ref, String authorId, bool selectable) {
  final userNickname = userNameMap[authorId] == null ? 'ダレカさん' : '${userNameMap[authorId]!}さん';

  if (selectable) {
    return SelectableText(
      userNickname,
      style: TextStyle(color: Theme.of(context).primaryColor),
    );
  } else {
    return Text(
      userNickname,
      style: TextStyle(color: Theme.of(context).primaryColor),
    );
  }
}

Widget bodyText(String body, bool selectable) {
  const linkifyOptions = LinkifyOptions(
    humanize: false,
    removeWww: false,
    looseUrl: false,
    defaultToHttps: false,
    excludeLastPeriod: true,
  );
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (selectable)
        SelectableLinkify(
          options: linkifyOptions,
          onOpen: (link) async {
            await launchUrl(Uri.parse(link.url));
          },
          text: body,
          style: const TextStyle(
              overflow: TextOverflow.clip, leadingDistribution: TextLeadingDistribution.even),
        ),
      if (!selectable)
        Linkify(
          options: linkifyOptions,
          onOpen: (link) async {
            await launchUrl(Uri.parse(link.url));
          },
          text: body,
          style: const TextStyle(
            overflow: TextOverflow.clip,
            leadingDistribution: TextLeadingDistribution.even,
          ),
        ),
      // linkPreviewList(body),
    ],
  );
}
