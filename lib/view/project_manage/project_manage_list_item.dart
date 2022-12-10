import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiite/provider/firebase_provider.dart';
import 'package:kiite/provider/view_model_provider.dart';
import 'package:kiite/view/project_manage/project_manage_view_model.dart';

class ProjectListItem extends StatefulWidget {
  const ProjectListItem({Key? key, required this.project}) : super(key: key);
  final Project project;

  @override
  ProjectListItemState createState() => ProjectListItemState();
}

class ProjectListItemState extends State<ProjectListItem> {
  late Project _project;
  // 他の読み方バッジ用
  late Future<Project> _futureProject;
  late Future<Set<String>> _futureOtherForm;
  bool firstBuild = true; // リストビュー遷移とリロード後のみ、読み込み中バッジ表示

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      _project = widget.project;

      return Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            alignment: Alignment.centerLeft,
            child: _cardContent(context, ref, _project),
          ),
          onTap: () => {_onItemTap(context, ref, _project)},
        ),
      );
    });
  }

  // カードの中身
  Widget _cardContent(BuildContext context, WidgetRef ref, Project project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _titleText(context, ref, project),
        _otherFormWrap(context, ref, project),
      ],
    );
  }

  Widget _titleText(BuildContext context, WidgetRef ref, Project project) {
    _futureProject = ref.watch(projectRepositoryProvider)!.getProjectById(project.id!);

    return FutureBuilder(
        future: _futureProject,
        builder: (BuildContext context, AsyncSnapshot<Project> snapshot) {
          if ((snapshot.connectionState != ConnectionState.done && firstBuild) ||
              !snapshot.hasData) {
            firstBuild = false;
            return Text(
              'カタカタカタカタ…',
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.bodyText1!.fontSize! * 1.1,
                color: Theme.of(context).primaryColor.withOpacity(0.3),
              ),
            );
          }

          String projectTitle = snapshot.data!.title;

          return Text(
            projectTitle,
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.bodyText1!.fontSize! * 1.1,
              color: Theme.of(context).primaryColor,
            ),
          );
        });
  }

  // カードの部品、タイトル以外の読み方
  Widget _otherFormWrap(BuildContext context, WidgetRef ref, Project project) {
    _futureOtherForm = ref.watch(projectRepositoryProvider)!.getOtherFormById(project.id!);

    return FutureBuilder(
      future: _futureOtherForm,
      builder: (BuildContext context, AsyncSnapshot<Set<String>> snapshot) {
        // 通信中、更新中
        if ((snapshot.connectionState != ConnectionState.done && firstBuild) || !snapshot.hasData) {
          firstBuild = false;
          return Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 2),
            child: _otherFormLoading(),
          );
        }

        // 取得後
        Set<String> otherFormData = snapshot.data!;

        // 値が空の時
        if (otherFormData.isEmpty) {
          return Container();
        }

        // 値がある時
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 2),
          child: _otherForm(otherFormData),
        );
      },
    );
  }

  // 他の読み方バッジ
  Widget _otherForm(Set<String> otherForm) {
    Color badgeColor = Theme.of(context).textTheme.bodyText2!.color!.withOpacity(1);
    TextStyle badgeStyle = Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 12);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var otherForm in otherForm) _otherFormBadge(badgeColor, badgeStyle, otherForm),
      ],
    );
  }

  // ローディング中の半透明のバッジ
  Widget _otherFormLoading() {
    Color badgeColor = Theme.of(context).textTheme.bodyText2!.color!.withOpacity(0.3);
    TextStyle badgeStyle = Theme.of(context).textTheme.bodyText2!.copyWith(
          fontSize: 12,
          color: Theme.of(context).textTheme.bodyText2!.color!.withOpacity(0.3),
        );

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _otherFormBadge(badgeColor, badgeStyle, 'カタカタカタカタカタカタ…'),
        const SizedBox(width: 8),
        _otherFormBadge(badgeColor, badgeStyle, 'カタカタカタカタカタカタ…'),
      ],
    );
  }

  // 読み方バッジ単体
  Widget _otherFormBadge(Color badgeColor, TextStyle badgeStyle, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: badgeColor,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      height: Theme.of(context).textTheme.bodyText1!.fontSize! * 1.7,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: badgeStyle,
        strutStyle:
            StrutStyle(fontSize: Theme.of(context).textTheme.bodyText1!.fontSize, height: 1.4),
      ),
    );
  }

  // カードタップ画面背に
  Future<void> _onItemTap(BuildContext context, WidgetRef ref, Project project) async {
    final viewModel = ref.watch(projectManageViewModelProvider);

    // 遷移前に初期化
    await viewModel.initEditView(project).whenComplete(() async {
      // 連続タップ防止
      if (viewModel.firstTap) {
        viewModel.firstTap = false;
        // 遷移
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ProjectDetailView(),
          ),
        );
        // 編集後に戻ってからカード更新
        if (viewModel.edited) {
          await refreshCard(ref, project);
        }
        viewModel.firstTap = true;
      }
    });
  }

  Future<void> refreshCard(WidgetRef ref, Project project) async {
    _futureOtherForm = ref.watch(projectManageViewModelProvider).otherFormById(ref, project.id!);

    Future.wait([_futureOtherForm]).then((value) => {setState(() {})});
  }
}
