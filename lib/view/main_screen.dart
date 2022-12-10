import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:kiite/model/kiite_icons.dart';
import 'package:kiite/provider/firebase_provider.dart';
import 'package:kiite/provider/static_value_provider.dart';
import 'package:kiite/provider/view_model_provider.dart';
import 'package:kiite/view/announcement/announcement_list_screen.dart';
import 'package:kiite/model/kiite_Threshold.dart';
import 'package:kiite/view/daily_list/daily_list_screen.dart';
import 'package:kiite/view/comment_timeline/comment_timeline_screen.dart';
import 'package:kiite/view/setting/setting_screen.dart';
import 'package:kiite/view/wide_screen/wide_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  var firstBuild = true;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final announcementRepository = ref.watch(announcementRepositoryProvider)!;
        final announcementScreenViewModel = ref.watch(announcementListScreenViewModelProvider);

        Future<void> browserInfo() async {
          try {
            await DeviceInfoPlugin().webBrowserInfo.then((value) async {
              final platform = value.platform.toString();
              final screenSize = MediaQuery.of(context).size;
              final ratio = screenSize.height / screenSize.width;
              if (platform == 'iPhone' && ratio > 16 / 9) {
                setState(() => iosWebSafeAreaInset = 28);
              }
            });
          } catch (e) {
            log(e.toString());
          }
        }

        Future<void> unreacted(WidgetRef ref) async {
          final unreacted = await announcementRepository.unreactedAnnoucement();
          const title = 'おしらせアリ';
          const content = '期日までにご対応ください';

          if (unreacted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  actionsPadding: const EdgeInsets.only(bottom: 8, right: 8),
                  title: const Text(title),
                  content: const Text(content),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        announcementScreenViewModel.initList();
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const AnnouncementManageScreen()),
                        );
                      },
                      child: const Text('イマスル', textAlign: TextAlign.end),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('アトデ', textAlign: TextAlign.end),
                    ),
                  ],
                );
              },
            );
          }
        }

        browserInfo();
        if (firstBuild) {
          unreacted(ref);
          firstBuild = false;
        }

        final futureNameMap = ref.watch(futureUserListProvider);
        return FutureBuilder(
            future: futureNameMap,
            builder: (context, AsyncSnapshot<Map<String, String>> snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Scaffold(
                  appBar: AppBar(),
                  body: const Center(child: CircularProgressIndicator()),
                );
              } else {
                userNameMap = snapshot.data ?? {};
                return const ResponsiveScreen();
              }
            });
      },
    );
  }
}

class ResponsiveScreen extends StatefulWidget {
  const ResponsiveScreen({Key? key}) : super(key: key);

  @override
  State<ResponsiveScreen> createState() => _ResponsiveScreenState();
}

class _ResponsiveScreenState extends State<ResponsiveScreen> {
  var _indexNum = 0;
  final List<Widget> _screenList = [
    const DailyListScreen(),
    const CommentTimeLineScreen(),
    const SettingScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      if (KiiteThreshold.isMobile(context) || KiiteThreshold.isTablet(context)) {
        return Scaffold(
          body: IndexedStack(
            index: _indexNum,
            children: _screenList,
          ),
          bottomNavigationBar: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: KiiteThreshold.mobile),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BottomNavigationBar(
                  currentIndex: _indexNum,
                  onTap: (value) {
                    setState(() {
                      ref.watch(selectedDailyIdProvider.state).state = '';
                      _indexNum = value;
                    });
                  },
                  items: [
                    BottomNavigationBarItem(icon: Icon(KiiteIcons.daily), label: 'ダイアリー'),
                    BottomNavigationBarItem(icon: Icon(KiiteIcons.sms), label: 'コメント'),
                    BottomNavigationBarItem(icon: Icon(KiiteIcons.work), label: 'ソノタ'),
                  ],
                ),
                if (iosWebSafeAreaInset > 0)
                  Material(
                    elevation: Theme.of(context).bottomNavigationBarTheme.elevation ?? 0,
                    child: Container(
                      height: iosWebSafeAreaInset,
                      color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
                    ),
                  ),
              ],
            ),
          ),
        );
      } else {
        return const WideScreen();
      }
    });
  }
}
