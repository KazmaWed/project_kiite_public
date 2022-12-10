import 'package:kiite/model/kiite_Threshold.dart';
import 'package:kiite/view/announcement/announcement_list_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:kiite/provider/view_model_provider.dart';
import 'package:kiite/view/project_manage/project_manage_list_screen.dart';
import 'package:kiite/view/setting/change_theme_screen.dart';
import 'package:kiite/view/fee_demand/fee_demand_screen.dart';

import 'change_name_dialog.dart';

class SettingScreen extends ConsumerWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: KiiteThreshold.maxWidth),
          child: Scaffold(
            appBar: AppBar(title: const Text('ソノタ')),
            body: SingleChildScrollView(
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: KiiteThreshold.mobile),
                  child: SettingViewButtons(ref: ref),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SettingViewButtons extends StatelessWidget {
  const SettingViewButtons({Key? key, required this.ref}) : super(key: key);
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    String attendanceGoogleSheet =
        'https://docs.google.com/spreadsheets/d/1c7u46D8EPw1emUOt0LhPk7PaxDigd74v7aNtfiv6k2g/edit';
    String notionDashBoard = 'https://www.notion.so/f8f61b98afd34040975498eeddcc903b';

    return Column(children: [
      Row(children: [
        Expanded(
          child: menuButton(
            context: context,
            title: '交通費請求',
            onPressed: () => {_onDemandFee(context, ref)},
          ),
        ),
      ]),
      Row(children: [
        Expanded(
          child: menuButton(
            context: context,
            title: 'お知らせ確認',
            onPressed: () => _onAnnouncement(context, ref),
          ),
        ),
      ]),
      Row(children: [
        Expanded(
          child: menuButton(
            context: context,
            title: '出勤状況シート',
            onPressed: () => {_openLink(attendanceGoogleSheet)},
          ),
        ),
      ]),
      Row(children: [
        Expanded(
          child: menuButton(
            context: context,
            title: 'プロジェクト管理',
            onPressed: () => {_onProjectManage(context, ref)},
          ),
        ),
      ]),
      Row(children: [
        Expanded(
          child: menuButton(
            context: context,
            title: 'Notion ダッシュボード',
            onPressed: () => {_openLink(notionDashBoard)},
          ),
        ),
      ]),
      Row(children: [
        Expanded(
          child: menuButton(
            context: context,
            title: 'Redmine',
            onPressed: () => {},
          ),
        ),
      ]),
      Row(children: [
        Expanded(
          child: menuButton(
            context: context,
            title: 'テーマ・フォント変更',
            onPressed: () => {_onChangeTheme(context, ref)},
          ),
        ),
      ]),
      Row(children: [
        Expanded(
          child: menuButton(
            context: context,
            title: 'ナマエ変更',
            onPressed: () => {onChangeNameTap(context)},
          ),
        ),
      ]),
      Row(children: [
        Expanded(
          child: menuButton(
            context: context,
            title: 'ログアウト',
            onPressed: () => {_onLogOutPressed(context)},
          ),
        ),
      ]),
    ]);
  }

  // -------------------- 交通費請求 --------------------
  void _onDemandFee(BuildContext context, WidgetRef ref) {
    ref.read(feeDemandViewModelProvider).initialize();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const FeeDemandScreen()),
    );
  }

  // --------------------

  void _onAnnouncement(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(announcementListScreenViewModelProvider);
    viewModel.initList();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AnnouncementManageScreen()),
    );
  }

  // -------------------- プロジェクト管理 --------------------

  Future<void> _onProjectManage(BuildContext context, WidgetRef ref) async {
    await ref.read(projectManageViewModelProvider).loadAllProjects().then((value) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ProjectManageScreen()),
      );
    });
  }

  //

  Future<void> _openLink(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  // -------------------- カラーテーマ --------------------

  void _onChangeTheme(BuildContext context, WidgetRef ref) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ColorThemeSelectScreen()),
    );
  }

  // -------------------- ログアウト --------------------
  void _onLogOutPressed(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('ログアウト'),
          actions: <Widget>[
            TextButton(
              child: const Text("シナイ"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("スル"),
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        );
      },
    );
  }

  Widget menuButton(
      {required BuildContext context, required String title, required void Function() onPressed}) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(12),
          alignment: Alignment.center,
          child: buttonText(context, title),
        ),
      ),
    );
  }

  Widget buttonText(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
          fontSize: Theme.of(context).textTheme.bodyText1!.fontSize,
          color: Theme.of(context).primaryColor),
    );
  }
}
