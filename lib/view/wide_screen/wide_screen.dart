import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiite/model/comment_model.dart';
import 'package:kiite/model/kiite_Threshold.dart';
import 'package:kiite/model/kiite_colors.dart';
import 'package:kiite/model/kiite_icons.dart';
import 'package:kiite/view/comment_timeline/comment_timeline_view.dart';
import 'package:kiite/view/common_components/daily_column_view.dart';
import 'package:kiite/view/comment_timeline/comment_timeline_view_model.dart';

import 'package:kiite/view/daily_list/daily_list_view_model.dart';
import 'package:kiite/view/daily_edit/daily_edit_view_model.dart';
import 'package:kiite/view/wide_screen/wide_screen_view_model.dart';

class WideScreen extends StatefulWidget {
  const WideScreen({Key? key}) : super(key: key);

  @override
  WideScreenState createState() => WideScreenState();
}

class WideScreenState extends State<WideScreen> {
  String herotag = 'daily_list';
  late DailyListViewModel dailyListViewModel;
  late CommentTimelineViewModel commentTimelineViewModel;
  late WideScreenViewModel wideScreenViewModel;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  var navigationIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      dailyListViewModel = ref.watch(dailyListViewModelProvider);
      commentTimelineViewModel = ref.watch(commentTimelineViewModelProvider);
      wideScreenViewModel = ref.watch(wideScreenViewModelProvider);

      final selectedDailyId = ref.watch(selectedDailyIdProvider);

      ref.read(dailyListViewModelProvider).callback = callback();
      ref.read(commentTimelineViewModelProvider).callback = callback();

      final mainViewList = [
        dailyList(ref),
        commentTimeline(ref),
      ];

      // --------- PC ---------
      return Scaffold(
          key: _scaffoldKey,
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: KiiteThreshold.maxWidth),
              child: Row(
                children: [
                  // ---------- ??????????????? ----------
                  SizedBox(
                    width: 74,
                    child: navigationRail(context, ref),
                  ),
                  // ---------- ???????????? ----------
                  SizedBox(
                    width: 154,
                    child: drawer(context, ref),
                  ),
                  const VerticalDivider(width: 0),
                  // ---------- ????????????????????? ----------
                  Expanded(
                    child: mainViewList[navigationIndex],
                  ),
                  const VerticalDivider(width: 0),
                  // ---------- ?????????????????????????????? ----------
                  Expanded(
                    child: DailyColumnView(
                      dailyId: selectedDailyId,
                      callback: () => setState(() {}),
                    ),
                  ),
                  const VerticalDivider(width: 0),
                ],
              ),
            ),
          ));
    });
  }

  Widget dailyList(WidgetRef ref) {
    final futureDailyList = ref.watch(futureDailyListProvider);
    return FutureBuilder(
      future: futureDailyList,
      builder: (BuildContext context, AsyncSnapshot<List<Daily>> snapshot) {
        // ?????????
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: DailyListLoadingView());
        } else if (snapshot.hasError) {
          return errorView();
        } else {
          // ???????????????????????????
          List<Daily> dailyList = snapshot.data ?? <Daily>[];

          return DailyListView(dailyList: dailyList);
        }
      },
    );
  }

  Widget commentTimeline(WidgetRef ref) {
    final futureCommentTimeline = ref.watch(futureCommentTimelineProvider);
    return FutureBuilder(
      future: futureCommentTimeline,
      builder: (BuildContext context, AsyncSnapshot<List<CommentTimeline>> snapshot) {
        // ?????????????????????????????????
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CommentTimelineLoadintView());
        } else if (snapshot.hasError) {
          return errorView();
        } else {
          // ???????????????????????????
          List<CommentTimeline> commentTimelineList = snapshot.data ?? <CommentTimeline>[];
          return CommentTimelineView(commentTimelineList: commentTimelineList);
        }
      },
    );
  }

  Widget navigationRail(BuildContext context, WidgetRef ref) {
    final unselectedLabelTextStyle = Theme.of(context).textTheme.bodySmall!.copyWith(
          color: Theme.of(context).cardColor.withAlpha(255),
          fontWeight: FontWeight.bold,
          fontSize: 11,
        );
    final selectedLabelTextStyle = unselectedLabelTextStyle;
    final iconColor = Theme.of(context).canvasColor;
    final selectedIconTheme = IconThemeData(color: Theme.of(context).primaryColor, opacity: 1);
    final unselectedIconTheme = IconThemeData(color: iconColor, opacity: 1);

    final List<NavigationRailDestination> destinations = [
      NavigationRailDestination(
        icon: Icon(KiiteIcons.daily),
        label: const Text('???????????????'),
      ),
      NavigationRailDestination(
        icon: Icon(KiiteIcons.sms),
        label: const Text('????????????'),
      ),
      NavigationRailDestination(
        icon: Icon(KiiteIcons.reload),
        label: const Text('????????????'),
      ),
      NavigationRailDestination(
        icon: Icon(KiiteIcons.edit),
        label: const Text('?????????'),
      ),
    ];

    void destinationSelected(int value) {
      if (value < 2) {
        setState(() => navigationIndex = value);
      } else if (value == 2) {
        reload();
      } else if (value == 3) {
        editButtonPressed(context, ref);
      }
    }

    Widget trailing() {
      final iconColor = Theme.of(context).canvasColor;
      return Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.max,
          children: [
            IconButton(
              onPressed: () => ref.read(selectedDailyIdProvider.state).state = '',
              icon: Icon(KiiteIcons.work, color: iconColor),
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    }

    // ???????????????????????????
    // Future<void> onSettingButton() async {
    //   await Navigator.of(context).push(
    //     MaterialPageRoute(
    //       builder: (context) => const SettingScreen(),
    //     ),
    //   );
    // }

    return NavigationRail(
      selectedIndex: navigationIndex,
      backgroundColor: Theme.of(context).primaryColor,
      labelType: NavigationRailLabelType.all,
      useIndicator: true,
      indicatorColor: iconColor,
      selectedIconTheme: selectedIconTheme,
      selectedLabelTextStyle: selectedLabelTextStyle,
      unselectedLabelTextStyle: unselectedLabelTextStyle,
      unselectedIconTheme: unselectedIconTheme,
      destinations: destinations,
      onDestinationSelected: (value) => destinationSelected(value),
      trailing: trailing(),
    );
  }

  // ???????????????
  Future<void> editButtonPressed(BuildContext context, WidgetRef ref) async {
    final viewModel = ref.watch(dailyEditViewModelProvider);

    await viewModel.initControllers(context).then((value) {
      ref.read(dailyEditViewModelProvider.state).state = viewModel;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => DailyEditScreen(heroTag: herotag)),
      );
    });
  }

  // ??????????????????
  Widget errorView() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('??????????????????????????????'),
          const SizedBox(height: 12),
          TextButton(
            child: const Text('????????????'),
            onPressed: () {
              dailyListViewModel.refreshDailyList();
              commentTimelineViewModel.refreshTimelineList();
            },
          ),
        ],
      ),
    );
  }

  void reload() {
    dailyListViewModel.refreshDailyList();
    commentTimelineViewModel.refreshTimelineList();
  }

  var highlightIndex = 0;
  // ???????????? (???????????????)
  Widget drawer(BuildContext context, WidgetRef ref) {
    List<String> nameList = userNameMap.values.toList();
    nameList.remove(userNameMap[FirebaseAuth.instance.currentUser!.uid]);
    nameList.sort((a, b) => a.hiragana.compareTo(b.hiragana));

    List<String> nameSanList = ['?????????', '?????????', ...nameList.san];
    nameList = ['?????????', '?????????', ...nameList];

    return Drawer(
      backgroundColor: Theme.of(context).cardColor,
      elevation: 0,
      child: ListView.builder(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + AppBar().preferredSize.height / 4,
        ),
        itemCount: userNameMap.length,
        itemBuilder: (BuildContext context, int index) {
          final highlight = highlightIndex == index;
          final textStyle = highlight
              ? Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: Theme.of(context).primaryColor)
              : null;
          return InkWell(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.centerLeft,
              height: 40,
              width: double.infinity,
              child: Text(nameSanList[index], style: textStyle),
            ),
            onTap: () {
              onDrawerButtonPressed(context, ref, nameList[index]);
              setState(() => highlightIndex = index);
            },
          );
        },
      ),
    );
  }

  // ?????????????????????
  void onDrawerButtonPressed(BuildContext context, WidgetRef ref, String name) {
    if (name == '?????????') {
      dailyListViewModel.filterBy = null;
      commentTimelineViewModel.filterBy = null;
    } else if (name == '?????????') {
      dailyListViewModel.filterBy = FirebaseAuth.instance.currentUser!.uid;
      commentTimelineViewModel.filterBy = FirebaseAuth.instance.currentUser!.uid;
    } else {
      for (var key in userNameMap.keys) {
        if (name == userNameMap[key]) {
          dailyListViewModel.filterBy = key;
          commentTimelineViewModel.filterBy = key;
          break;
        }
      }
    }
    if (KiiteThreshold.isMobile(context)) {
      Navigator.of(context).pop();
    }
    dailyListViewModel.refreshDailyList();
    commentTimelineViewModel.refreshTimelineList();
  }

  Function callback() {
    return () => setState(() {});
  }
}
