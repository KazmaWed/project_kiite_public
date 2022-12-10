import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiite/model/kiite_Threshold.dart';
import 'package:kiite/model/project_model.dart';
import 'package:kiite/provider/view_model_provider.dart';
import 'package:kiite/view/project_manage/project_manage_view_model.dart';

Future<void> addProjectDialog(BuildContext context, WidgetRef ref) async {
  final viewModel = ref.watch(projectManageViewModelProvider);
  // final index = viewModel.controllerIndex;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return GestureDetector(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: KiiteThreshold.mobile),
            child: SingleChildScrollView(
              child: AlertDialog(
                insetPadding: const EdgeInsets.all(24),
                titlePadding: const EdgeInsets.only(left: 24, top: 24, right: 24, bottom: 0),
                contentPadding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                actionsPadding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                title: const Text('プロジェクトを追加'),
                content: content(context, ref),
                actions: [
                  TextButton(
                    child: Text(
                      '戻る',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                    onPressed: () => viewModel.onCancel(context, ref),
                  ),
                  TextButton(
                    child: Text(
                      '確定',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                    onPressed: () {
                      _onSubmit(context, ref);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        onTap: () => {viewModel.unFocus()},
      );
    },
  );
}

// 確定ボタン押し下
Future<void> _onSubmit(BuildContext context, WidgetRef ref) async {
  final viewModel = ref.watch(projectManageViewModelProvider);
  viewModel.onSubmit(context, ref);
}

// アラート本体
Widget content(BuildContext context, WidgetRef ref) {
  final viewModel = ref.watch(projectManageViewModelProvider);

  return Container(
    padding: const EdgeInsets.all(12),
    width: MediaQuery.of(context).size.width,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleTextField(context, ref),
        const SizedBox(height: 8),
        for (var formIdx = 0; formIdx < viewModel.dialogHintText.length; formIdx++)
          otherFormField(context, ref, formIdx),
        const SizedBox(height: 36),
        suggestButtonColumn(context, ref),
      ],
    ),
  );
}

// プロジェクトタイトルフィールド
Widget titleTextField(BuildContext context, WidgetRef ref) {
  final dailyEditViewModel = ref.watch(dailyEditViewModelProvider);
  final viewModel = ref.watch(projectManageViewModelProvider);
  final changeThemeViewModel = ref.watch(changeThemeViewModelProvider);
  int index = viewModel.controllerIndex;

  Color hintColor = Theme.of(context).textTheme.bodyText2!.color!.withOpacity(0.4);
  // TextStyle hintStyle = Theme.of(context)
  //     .textTheme
  //     .bodyText2!
  //     .copyWith(color: hintColor, fontSize: Theme.of(context).textTheme.bodyText2!.fontSize);

  String initialValue = dailyEditViewModel.titleCtrlerList[index].text;
  viewModel.titleController.text = initialValue;

  return TextFormField(
    controller: viewModel.titleController,
    focusNode: viewModel.focusList.first,
    keyboardType: TextInputType.text,
    keyboardAppearance: changeThemeViewModel.darkMode ? Brightness.dark : Brightness.light,
    textInputAction: TextInputAction.next,
    maxLines: 1,
    decoration: InputDecoration(
      labelText: 'プロジェクト名',
      hintStyle: TextStyle(color: hintColor),
      fillColor: Colors.pink,
    ),
    style: TextStyle(fontSize: Theme.of(context).textTheme.bodyText1!.fontSize),
    textAlign: TextAlign.start,
    onTap: () => {},
    onChanged: (value) {
      dailyEditViewModel.titleCtrlerList[index].text = viewModel.titleController.text;
    },
    onEditingComplete: () => {_onEnderTapped(ref, viewModel.titleController, 0)},
  );
}

// 他の読み方フィールド
Widget otherFormField(BuildContext context, WidgetRef ref, int formIndex) {
  // final dailyEditViewModel = ref.watch(dailyEditViewModelProvider);
  final viewModel = ref.watch(projectManageViewModelProvider);
  final changeThemeViewModel = ref.watch(changeThemeViewModelProvider);
  final focusIndex = formIndex + 1;

  Color hintColor = Theme.of(context).textTheme.bodyText2!.color!.withOpacity(0.5);

  return TextFormField(
    controller: viewModel.otherControllerList[formIndex],
    focusNode: viewModel.focusList[formIndex + 1],
    keyboardType: TextInputType.text,
    keyboardAppearance: changeThemeViewModel.darkMode ? Brightness.dark : Brightness.light,
    textInputAction: formIndex < 3 ? TextInputAction.next : TextInputAction.done,
    maxLines: 1,
    decoration: InputDecoration(
      hintText: viewModel.dialogHintText[formIndex],
      hintStyle: TextStyle(color: hintColor),
      // fillColor: Theme.of(context).primaryColor,
      contentPadding: const EdgeInsets.all(0),
    ),
    style: TextStyle(fontSize: Theme.of(context).textTheme.bodyText2!.fontSize),
    textAlign: TextAlign.start,
    onEditingComplete: () =>
        {_onEnderTapped(ref, viewModel.otherControllerList[formIndex], focusIndex)},
  );
}

// こちらではないですかボタンカラム
Widget suggestButtonColumn(BuildContext context, WidgetRef ref) {
  final viewModel = ref.watch(projectManageViewModelProvider);

  Color hintColor = Theme.of(context).textTheme.bodyText2!.color!.withOpacity(0.8);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'こちらではありません？',
        style:
            TextStyle(fontSize: Theme.of(context).textTheme.bodyText2!.fontSize, color: hintColor),
      ),
      const SizedBox(height: 4),
      for (var idx = 0; idx < viewModel.suggestedProject.length; idx++)
        suggestButton(context, ref, viewModel.suggestedProject[idx]),
    ],
  );
}

// こちらではないですかボタンアイテム
Widget suggestButton(BuildContext context, WidgetRef ref, Project project) {
  return Row(
    children: [
      Expanded(
        child: SizedBox(
          height: 28,
          child: TextButton(
            style: ButtonStyle(
              alignment: Alignment.centerLeft,
              padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 5)),
            ),
            child: Text(
              project.title,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
            onPressed: () => {_onSuggestButtonTap(context, ref, project)},
          ),
        ),
      ),
    ],
  );
}

void _onSuggestButtonTap(BuildContext context, WidgetRef ref, Project project) {
  final viewModel = ref.watch(projectManageViewModelProvider);
  viewModel.onSuggestButtonTap(context, project);
}

void _onEnderTapped(WidgetRef ref, TextEditingController controller, int index) {
  final viewModel = ref.watch(projectManageViewModelProvider);
  if (index < viewModel.focusList.length - 1 && controller.text.isNotEmpty) {
    viewModel.focusList[index + 1].requestFocus();
  } else {
    viewModel.unFocus();
  }
}
