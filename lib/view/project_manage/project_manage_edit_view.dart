import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:kiite/model/kiite_snackbar.dart';
import 'package:kiite/provider/confirm_tab_close_stream.dart';
import 'package:kiite/provider/firebase_provider.dart';
import 'package:mix/mix.dart';
import 'package:kiite/model/kiite_colors.dart';
import 'package:kiite/model/kiite_icons.dart';
import 'package:kiite/model/kiite_Threshold.dart';
import 'package:kiite/provider/static_value_provider.dart';
import 'package:kiite/provider/view_model_provider.dart';
import 'package:kiite/view/project_manage/project_manage_view_model.dart';

class ProjectDetailView extends StatefulWidget {
  const ProjectDetailView({Key? key}) : super(key: key);

  @override
  ProjectDetailViewState createState() => ProjectDetailViewState();
}

class ProjectDetailViewState extends State<ProjectDetailView> {
  final double _edgeInset = 24;
  late ProjectManageViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      // タブを閉じるときの確認
      ref.watch(confirmTabCloseStreamProvider);

      viewModel = ref.watch(projectManageViewModelProvider);

      Project? project = viewModel.editingProject;
      int numOfField = viewModel.numOfField;

      return Scaffold(
        appBar: AppBar(
          title: const Text('プロジェクト情報を編集'),
          leading: _backButton(context, ref),
          actions: [_deleteButton(ref)],
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              child: Icon(KiiteIcons.done),
              onPressed: () => {_onDone(context, ref)},
            ),
            SizedBox(height: iosWebSafeAreaInset),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: KiiteThreshold.tablet),
            child: GestureDetector(
              onTap: () => {Focus.of(context).unfocus()},
              child: ListView(
                padding: const EdgeInsets.only(top: 4),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [_projectIdText(context, ref, project)],
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        _edgeInset, 0, _edgeInset, _edgeInset + iosWebSafeAreaInset),
                    child: Column(
                      children: [
                        titleFormField(context, ref),
                        const SizedBox(height: 24),
                        for (var index = 0; index < numOfField; index++)
                          _otherFormField(context, ref, index),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _backButton(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: Icon(KiiteIcons.arrow_back),
      onPressed: () => _onBackButton(context, ref),
    );
  }

  Widget titleFormField(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(projectManageViewModelProvider);
    final changeThemeViewModel = ref.watch(changeThemeViewModelProvider);
    final controller = viewModel.titleController;
    final focus = viewModel.focusList.first;

    return TextField(
      controller: controller,
      focusNode: focus,
      keyboardAppearance: changeThemeViewModel.darkMode ? Brightness.dark : Brightness.light,
      textInputAction: TextInputAction.next,
      maxLines: 1,
      textAlign: TextAlign.start,
      decoration: const InputDecoration(
        labelText: 'プロジェクト名',
        fillColor: Colors.pink,
      ),
      onChanged: (_) => {viewModel.edited = true},
    );
  }

  Widget _otherFormField(BuildContext context, WidgetRef ref, int index) {
    final viewModel = ref.watch(projectManageViewModelProvider);
    final changeThemeViewModel = ref.watch(changeThemeViewModelProvider);
    final controller = viewModel.otherControllerList[index];
    final focus = viewModel.focusList[index + 1];

    Mix mix = Mix(
      borderStyle(BorderStyle.none),
    );
    List<String> hintText = viewModel.hintText;

    return Box(
      mix: mix,
      child: TextField(
        controller: controller,
        focusNode: focus,
        keyboardAppearance: changeThemeViewModel.darkMode ? Brightness.dark : Brightness.light,
        textInputAction: TextInputAction.next,
        maxLines: 1,
        style: TextStyle(fontSize: Theme.of(context).textTheme.bodyText1!.fontSize),
        textAlign: TextAlign.start,
        decoration: InputDecoration(
          labelText: index == 0 ? '他の読み方、表記' : null,
          labelStyle: TextStyle(fontSize: Theme.of(context).textTheme.subtitle1!.fontSize),
          hintText: hintText[index],
          hintStyle: TextStyle(color: Theme.of(context).hintColor.withOpacity(0.3)),
          fillColor: Colors.pink,
        ),
        onChanged: (_) => {viewModel.edited = true},
      ),
    );
  }

  Widget _projectIdText(BuildContext context, WidgetRef ref, Project? project) {
    Color idColor = Theme.of(context).textTheme.bodyText2!.color!.withOpacity(0.5);
    TextStyle idStyle = Theme.of(context).textTheme.bodyText2!.copyWith(
          color: idColor,
          fontSize: Theme.of(context).textTheme.caption!.fontSize,
        );
    String text = project == null ? '新規作成' : 'ID : ${project.id.toString()}';

    return Padding(
      padding: const EdgeInsets.all(4),
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Text(text, style: idStyle),
        ),
        onTap: () => _onIdTapped(),
      ),
    );
  }

  Widget _deleteButton(WidgetRef ref) {
    if (viewModel.editingProject != null) {
      return IconButton(
        icon: Icon(KiiteIcons.bin),
        onPressed: () => _onDelete(ref),
      );
    } else {
      return const SizedBox();
    }
  }

  Future<void> _onBackButton(BuildContext context, WidgetRef ref) async {
    final viewModel = ref.watch(projectManageViewModelProvider);
    if (!viewModel.edited) {
      Navigator.of(context).pop();
    } else {
      final text = viewModel.editingProject == null ? 'プロジェクトを保存しますか？' : '変更を保存しますか？';
      await showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(text)],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("いいえ"),
                onPressed: () {
                  viewModel.edited = false;
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('はい'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _onDone(context, ref);
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _onDone(BuildContext context, WidgetRef ref) async {
    final viewModel = ref.watch(projectManageViewModelProvider);

    if (!viewModel.edited) {
      // 未編集時
      Navigator.of(context).pop();
    } else {
      if (viewModel.editingProject == null) {
        // 新規登録時
        showNetworkingCircular(context);
        await viewModel.add(ref).then((succeed) {
          if (succeed) {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            KiiteSnackBar(context).saved();
          } else {
            Navigator.of(context).pop();
            KiiteSnackBar(context).saveFailed();
          }
        });
      } else {
        // 編集時
        showNetworkingCircular(context);
        await viewModel.update(ref).then((succeed) {
          if (succeed) {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            KiiteSnackBar(context).saved();
          } else {
            Navigator.of(context).pop();
            KiiteSnackBar(context).saveFailed();
          }
        });
      }
    }
  }

  Future<void> _onDelete(WidgetRef ref) async {
    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [Text('プロジェクトを削除しますか？')],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("いいえ"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('はい'),
              onPressed: () async {
                Navigator.of(context).pop();
                showNetworkingCircular(context);
                await ref
                    .read(projectRepositoryProvider)!
                    .removeProject(viewModel.editingProject!)
                    .then((succeed) {
                  if (succeed) {
                    viewModel.edited = true;
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    KiiteSnackBar(context).removed();
                  } else {
                    Navigator.of(context).pop();
                    KiiteSnackBar(context).removeFailed();
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _onIdTapped() {
    if (viewModel.editingProject != null) {
      Clipboard.setData(ClipboardData(text: viewModel.editingProject!.id));
    }
  }
}
