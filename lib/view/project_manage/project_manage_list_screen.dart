import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiite/model/kiite_icons.dart';
import 'package:kiite/model/kiite_Threshold.dart';
import 'package:kiite/view/comment_timeline/comment_timeline_view_model.dart';
import 'package:kiite/view/project_manage/project_manage_view_model.dart';
import 'package:kiite/view/project_manage/project_manage_search_bar.dart';

class ProjectManageScreen extends StatefulWidget {
  const ProjectManageScreen({Key? key}) : super(key: key);

  @override
  ProjectManageScreenState createState() => ProjectManageScreenState();
}

class ProjectManageScreenState extends State<ProjectManageScreen> {
  late ProjectManageViewModel viewModel;
  late Future<void> _future;

  @override
  Widget build(context) {
    return Consumer(builder: (context, ref, child) {
      viewModel = ref.watch(projectManageViewModelProvider);
      _future = viewModel.loadAllProjects();

      return Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: KiiteThreshold.maxWidth),
            child: Scaffold(
              appBar: AppBar(title: const Text('プロジェクト管理')),
              floatingActionButton: _floatingActionButton(ref),
              body: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: KiiteThreshold.tablet),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SearchBar(),
                      _futureListView(ref),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  // リストビューをフューチャーでラップ
  Widget _futureListView(WidgetRef ref) {
    return FutureBuilder(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        // 通信中はスピナーを表示
        if (snapshot.connectionState != ConnectionState.done) {
          return Expanded(
            child: Container(
              padding: const EdgeInsets.only(bottom: 102),
              child: const Center(child: CircularProgressIndicator()),
            ),
          );
        }
        // エラー発生時はエラーメッセージを表示
        if (snapshot.hasError) {
          return Expanded(
            child: Center(child: Text(snapshot.error.toString())),
          );
        }

        return Expanded(
          child: RefreshIndicator(
            child: ProjectListView(projectList: viewModel.allProjects),
            onRefresh: () async => {_onRefresh(ref)},
          ),
        );
      },
    );
  }

  void _onRefresh(WidgetRef ref) {
    _future = ref.watch(projectManageViewModelProvider).futureAllProject().whenComplete(() {
      setState(() {});
    });
  }

  // FAB
  Widget _floatingActionButton(WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          child: Icon(KiiteIcons.addImage),
          onPressed: () => {_onAdd(ref)},
        ),
        SizedBox(height: iosWebSafeAreaInset),
      ],
    );
  }

  // FABタップ
  Future<void> _onAdd(WidgetRef ref) async {
    // 遷移前に初期化
    await viewModel.initEditView(null).whenComplete(() async {
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
          _onRefresh(ref);
        }
        viewModel.firstTap = true;
      }
    });
  }
}
