import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiite/model/kiite_colors.dart';
import 'package:kiite/provider/static_value_provider.dart';
import 'package:kiite/provider/view_model_provider.dart';
import 'package:kiite/view/project_manage/project_manage_view_model.dart';

class ProjectListView extends StatefulWidget {
  const ProjectListView({Key? key, required this.projectList}) : super(key: key);
  // final WidgetRef ref;
  final List<Project> projectList;

  @override
  ProjectListViewState createState() => ProjectListViewState();
}

class ProjectListViewState extends State<ProjectListView> {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final viewModel = ref.watch(projectManageViewModelProvider);
      viewModel.searchBarOnChange = _onSearchWordChange();

      final projectList = viewModel.getSuggestion(viewModel.searchBarController.text);

      if (projectList.isEmpty) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: iosWebSafeAreaInset + 74),
            child: Center(
              child: Text('ミツカリマセン…', style: TextStyle(color: KiiteColors.grey)),
            ),
          ),
        );
      } else {
        return ListView(
          controller: viewModel.controller,
          cacheExtent: MediaQuery.of(context).size.height * 1000,
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 112),
          children: [
            for (var index = 0; index < projectList.length; index++)
              ProjectListItem(project: projectList[index]),
          ],
        );
      }
    });
  }

  Function _onSearchWordChange() {
    return () => {setState(() {})};
  }
}
