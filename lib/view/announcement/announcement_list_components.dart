import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kiite/model/kiite_Threshold.dart';
import 'package:kiite/view/announcement/announcement_detail_screen.dart';
import 'package:kiite/view/fee_demand/fee_demand_view_model.dart';
import 'package:url_launcher/url_launcher.dart';

class AnnouncementListItem extends StatefulWidget {
  const AnnouncementListItem({Key? key, required this.index}) : super(key: key);
  final int index;

  @override
  State<AnnouncementListItem> createState() => _AnnouncementListItemState();
}

class _AnnouncementListItemState extends State<AnnouncementListItem> {
  @override
  Widget build(BuildContext context) {
    const linkifyOptions = LinkifyOptions(
      humanize: false,
      removeWww: false,
      looseUrl: false,
      defaultToHttps: false,
      excludeLastPeriod: true,
    );

    return Consumer(builder: (context, ref, child) {
      final viewModel = ref.watch(announcementListScreenViewModelProvider);
      final announcement = viewModel.loadedAnnouncementList[widget.index];

      final stillDue = !announcement.dueDate.difference(DateTime.now()).isNegative;
      final reacted = announcement.reactedBy!.contains(FirebaseAuth.instance.currentUser!.uid);

      final cardShadowColor = (stillDue && !reacted)
          ? Theme.of(context).primaryColor
          : Theme.of(context).cardTheme.shadowColor;
      final cardElevation = (stillDue && !reacted) ? 3.2 : 1.0;

      final titleStyle = (stillDue && !reacted)
          ? TextStyle(
              fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            )
          : Theme.of(context).textTheme.titleMedium!;
      // final dueStyle = Theme.of(context).textTheme.bodyMedium!;
      final dateStyle = Theme.of(context).textTheme.bodySmall!;

      Widget announcementTitleView() {
        return Expanded(
          child: Text(
            announcement.title,
            style: titleStyle,
            maxLines: null,
          ),
        );
      }

      Widget dateView(DateTime dateTime, MainAxisAlignment alignment) {
        return Text(
          DateFormat('配信日：yyyy/MM/dd E. - HH:mm').format(dateTime),
          style: dateStyle,
        );
      }

      Widget dueView(DateTime dateTime, MainAxisAlignment alignment) {
        return Text(
          DateFormat('対応期日：yyyy/MM/dd E. - HH:mm').format(dateTime),
          style: titleStyle,
        );
      }

      Future<void> onTap() async {
        final viewModel = ref.watch(announcementListScreenViewModelProvider);
        final repository = ref.watch(announcementRepositoryProvider)!;
        viewModel.firstBuild = true;

        ref.watch(futureAnnouncementProvider.state).state =
            repository.futureAnnouncementById(announcement.id!);
        viewModel.initForEdit(announcement);

        await Navigator.of(context).push(
          MaterialPageRoute(builder: ((context) => AnnouncementDetailScreen(index: widget.index))),
        );

        repository.futureAnnouncementById(announcement.id!).then((value) {
          viewModel.loadedAnnouncementList[widget.index] = value;
          // setState(() {});
        }).whenComplete(() async {
          await viewModel.futureReactedUserList(announcement.id!).then((value) {
            viewModel.loadedAnnouncementList[widget.index].reactedBy = value;
            setState(() {});
          });
        });
        // setState(() => viewModel.initList());
      }

      Widget miniCard() {
        return Card(
          clipBehavior: Clip.antiAlias,
          shadowColor: cardShadowColor,
          elevation: cardElevation,
          child: InkWell(
            onTap: () => onTap(),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [announcementTitleView()]),
                  const SizedBox(height: 8),
                  dueView(announcement.dueDate, MainAxisAlignment.end),
                  dateView(announcement.deliverDate, MainAxisAlignment.start),
                  const Divider(),
                  Row(children: [
                    Flexible(
                      child: Linkify(
                        text: announcement.body,
                        maxLines: 5,
                        options: linkifyOptions,
                        onOpen: (link) async {
                          await launchUrl(Uri.parse(link.url));
                        },
                      ),
                    ),
                  ]),
                  const Divider(),
                  const SizedBox(height: 2),
                  ReactedUserChipView(userIdList: announcement.reactedBy ?? []),
                ],
              ),
            ),
          ),
        );
      }

      Widget wideCard() {
        return Card(
          clipBehavior: Clip.antiAlias,
          shadowColor: cardShadowColor,
          elevation: cardElevation,
          child: InkWell(
            onTap: () => onTap(),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(children: [
                    announcementTitleView(),
                    const SizedBox(width: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 220),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        dueView(announcement.dueDate, MainAxisAlignment.end),
                        dateView(announcement.deliverDate, MainAxisAlignment.start),
                      ]),
                    ),
                  ]),
                  const Divider(),
                  Row(children: [
                    Flexible(
                      child: Linkify(
                        maxLines: 5,
                        options: linkifyOptions,
                        text: announcement.body,
                      ),
                    ),
                  ]),
                  const Divider(),
                  const SizedBox(height: 4),
                  ReactedUserChipView(userIdList: announcement.reactedBy ?? []),
                ],
              ),
            ),
          ),
        );
      }

      if (KiiteThreshold.isPC(context)) {
        return wideCard();
      } else {
        return miniCard();
      }
    });
  }
}

class LinkButton extends StatelessWidget {
  const LinkButton({Key? key, required this.linkUrl, required this.linkTitle}) : super(key: key);
  final String linkUrl;
  final String linkTitle;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(color: Theme.of(context).primaryColor);

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          InkWell(
            onTap: () async => await launchUrl(Uri.parse(linkUrl)),
            hoverColor: Theme.of(context).primaryColor.withAlpha(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(linkTitle == '' ? linkUrl : linkTitle, style: style),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class ReactedUserChipView extends StatelessWidget {
  const ReactedUserChipView({Key? key, required this.userIdList}) : super(key: key);
  final List<String> userIdList;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final userInfoRepository = ref.watch(userInfoRepositoryProvider);

      Widget countView() {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Theme.of(context).primaryColor,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.done_rounded,
                color: Colors.white,
                size: Theme.of(context).textTheme.bodyMedium!.fontSize,
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child:
                    Text(userIdList.length.toString(), style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }

      Widget userNameChip(String name) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: Theme.of(context).dividerColor),
            // color: Theme.of(context).primaryColor,
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(name),
          ),
        );
      }

      List<Widget> blankNameChips(List<String> userNameList) {
        return [
          // ignore: unused_local_variable
          for (var userName in userNameList) Opacity(opacity: 0.4, child: userNameChip('ロード中')),
        ];
      }

      List<Widget> userNameChips(List<String> userNameList) {
        List<Widget> output = [];

        for (var userName in userNameList) {
          output.add(userNameChip(userName));
        }

        return output;
      }

      return FutureBuilder(
          future: userInfoRepository.futureUserList(),
          builder: (context, AsyncSnapshot<Map<String, Map<String, String>>> snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Row(children: [
                Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 4,
                  children: [countView(), ...blankNameChips(userIdList)],
                ),
              ]);
            } else if (!snapshot.hasData) {
              return Row(children: [
                Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 4,
                  children: [countView()],
                ),
              ]);
            } else if (snapshot.hasError) {
              return Row(children: [
                Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 4,
                  children: [
                    countView(),
                  ],
                ),
              ]);
            } else {
              final userInfoMap = snapshot.data!;
              final List<String> userNameList = [];
              for (var userId in userIdList) {
                userNameList.add(userInfoMap[userId]!['userName'] ?? '該当なし');
              }
              return Row(children: [
                Flexible(
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 4,
                    runSpacing: 4,
                    children: [countView(), ...userNameChips(userNameList)],
                  ),
                ),
              ]);
            }
          });
    });
  }
}
