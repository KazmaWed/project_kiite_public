import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiite/model/kiite_Threshold.dart';
import 'package:kiite/view/daily_edit/daily_edit_view_model.dart';
import 'package:kiite/view/project_manage/project_manage_view_model.dart';

class EffortItem extends StatefulWidget {
  const EffortItem({Key? key, required this.context, required this.ref, required this.index})
      : super(key: key);
  final BuildContext context;
  final WidgetRef ref;
  final int index;

  @override
  State<EffortItem> createState() => _EffortItemState();
}

class _EffortItemState extends State<EffortItem> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 4),
        Expanded(
          child: titleField(context, widget.ref, widget.index),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.only(bottom: 2),
          height: 40,
          width: 48,
          child: lengthField(context, widget.ref, widget.index),
        ),
        const SizedBox(width: 0),
      ],
    );
  }
}

// 案件名テキストフィールド
Widget titleField(BuildContext context, WidgetRef ref, int index) {
  // 入力候補枠サイズ
  final screenWidth = MediaQuery.of(context).size.width;
  late final double autocompleteWidth;
  //  = isWideScreen ? 300.0 : screenWidth - 80;
  if (KiiteThreshold.isFullWidth(context)) {
    autocompleteWidth = KiiteThreshold.maxWidth / 2 - 64;
  } else if (KiiteThreshold.isPC(context)) {
    autocompleteWidth = screenWidth / 2 - 64;
  } else {
    autocompleteWidth = screenWidth - 80;
  }

  const autocompleteHeight = 200.0;
  const addProjectTileTitle = 'プロジェクトを追加する';
  final addProject = Project(title: addProjectTileTitle, otherForm: {});

  final titleFocusIdx = index * 2;
  final hintColor = Theme.of(context).textTheme.bodyText2!.color!.withOpacity(0.3);
  final hintStyle = Theme.of(context).textTheme.bodyText2!.copyWith(color: hintColor);
  const hintText = 'シタコト';
  final decoration = InputDecoration(
    hintText: hintText,
    hintStyle: hintStyle,
    border: InputBorder.none,
    fillColor: Colors.pink,
  );

  final changeThemeViewModel = ref.watch(changeThemeViewModelProvider);
  final dailyEditVM = ref.watch(dailyEditViewModelProvider);
  final projectManageVM = ref.watch(projectManageViewModelProvider);

  Project? projectHighlighted;

  Future<void> _onTitleComplete(int index) async {
    if (projectHighlighted!.title != addProjectTileTitle) {
      dailyEditVM.onEnterProject(ref, projectHighlighted, index);
    } else {
      final initailValue = dailyEditVM.titleCtrlerList[index].text;
      await projectManageVM.initForDialog(context, initailValue, index).then((value) async {
        await addProjectDialog(context, ref);
      });
    }
  }

  Future<void> _onAddProject(int controllerIndex) async {
    final initailValue = dailyEditVM.titleCtrlerList[controllerIndex].text;
    await projectManageVM.initForDialog(context, initailValue, controllerIndex).then((value) async {
      await addProjectDialog(context, ref);
    });
  }

  return Autocomplete<Project>(
    optionsBuilder: (TextEditingValue value) {
      if (value.text.isEmpty) {
        projectHighlighted = null;
        return [];
      } else {
        final suggestedProjects = [...projectManageVM.getSuggestion(value.text), addProject];
        projectHighlighted = suggestedProjects.first;
        return suggestedProjects;
      }
    },
    onSelected: (Project project) {
      dailyEditVM.titleCtrlerList[index].text = project.title;
      dailyEditVM.focusList[titleFocusIdx + 1].requestFocus();
    },
    fieldViewBuilder: (BuildContext context, TextEditingController controller, FocusNode focusNode,
        VoidCallback onFieldSubmitted) {
      controller.text = dailyEditVM.titleCtrlerList[index].text;
      dailyEditVM.titleCtrlerList[index] = controller;
      dailyEditVM.focusList[titleFocusIdx] = focusNode;
      return TextField(
        controller: dailyEditVM.titleCtrlerList[index],
        focusNode: dailyEditVM.focusList[titleFocusIdx],
        keyboardType: TextInputType.text,
        keyboardAppearance: changeThemeViewModel.darkMode ? Brightness.dark : Brightness.light,
        textInputAction: TextInputAction.next,
        maxLines: 1,
        decoration: decoration,
        style: TextStyle(fontSize: Theme.of(context).textTheme.bodyText2!.fontSize),
        onEditingComplete: () => _onTitleComplete(index),
      );
    },
    optionsViewBuilder: (
      BuildContext context,
      void Function(Project) onSelected,
      Iterable<Project> projects,
    ) {
      return Align(
        alignment: Alignment.topLeft,
        child: Card(
          elevation: 4.0,
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: autocompleteWidth,
              maxHeight: autocompleteHeight,
            ),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: projects.length,
              itemBuilder: (BuildContext context, int listIndex) {
                final project = projects.elementAt(listIndex);

                if (project.title != addProjectTileTitle) {
                  return InkWell(
                    child: Builder(builder: (BuildContext context) {
                      final bool highlight = AutocompleteHighlightedOption.of(context) == listIndex;
                      if (highlight) {
                        projectHighlighted = project;
                        SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
                          Scrollable.ensureVisible(context, alignment: 0.5);
                        });
                      }
                      return Container(
                        color: highlight ? Theme.of(context).focusColor : null,
                        padding: const EdgeInsets.all(8.0),
                        child: Text(project.title),
                      );
                    }),
                    onTap: () => onSelected(project),
                  );
                } else {
                  return InkWell(
                    child: Builder(builder: (BuildContext context) {
                      final bool highlight = AutocompleteHighlightedOption.of(context) == listIndex;
                      if (highlight) {
                        projectHighlighted = project;
                        SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
                          Scrollable.ensureVisible(context, alignment: 0.5);
                        });
                      }
                      return Container(
                        alignment: Alignment.centerRight,
                        color: highlight ? Theme.of(context).focusColor : null,
                        padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                        child: Text(
                          addProjectTileTitle,
                          style: TextStyle(color: Theme.of(context).primaryColor),
                        ),
                      );
                    }),
                    onTap: () async => await _onAddProject(index),
                  );
                }
              },
            ),
          ),
        ),
      );
    },
  );
}

// 時間テキストフィールド
Widget lengthField(BuildContext context, WidgetRef ref, int index) {
  const autocompleteWidth = 44.0;
  const autocompleteHeight = 300.0;

  final numFocusIdx = index * 2 + 1;
  final hintColor = Theme.of(context).textTheme.bodyText2!.color!.withOpacity(0.3);
  final hintStyle = Theme.of(context).textTheme.bodyText2!.copyWith(color: hintColor);
  const hintText = '0.0';
  final decoration = InputDecoration(
    hintText: hintText,
    hintStyle: hintStyle,
    border: InputBorder.none,
    fillColor: Colors.pink,
  );
  final changeThemeViewModel = ref.watch(changeThemeViewModelProvider);
  final viewModel = ref.watch(dailyEditViewModelProvider);

  String? valueHighlighted;

  var nums = [''];
  for (var n = 0.5; n <= 10; n += 0.5) {
    nums.add(n.toStringAsFixed(1));
  }

  void _onLengthComplete(BuildContext context, WidgetRef ref, index) {
    viewModel.onEnterLength(ref, valueHighlighted, index);
  }

  return Autocomplete(
    optionsBuilder: (_) {
      return nums;
    },
    onSelected: (String value) {
      viewModel.lengthCtrlerList[index].text = value;
      viewModel.focusList[numFocusIdx + 1].requestFocus();
    },
    fieldViewBuilder: (BuildContext context, TextEditingController controller, FocusNode focusNode,
        VoidCallback onFieldSubmitted) {
      controller.text = viewModel.lengthCtrlerList[index].text;
      viewModel.lengthCtrlerList[index] = controller;
      viewModel.focusList[numFocusIdx] = focusNode;
      return TextField(
        controller: viewModel.lengthCtrlerList[index],
        focusNode: viewModel.focusList[numFocusIdx],
        keyboardType: TextInputType.none,
        keyboardAppearance: changeThemeViewModel.darkMode ? Brightness.dark : Brightness.light,
        textInputAction: TextInputAction.next,
        maxLines: 1,
        decoration: decoration,
        style: TextStyle(fontSize: Theme.of(context).textTheme.bodyText2!.fontSize),
        onEditingComplete: () => _onLengthComplete(context, ref, index),
      );
    },
    optionsViewBuilder: (
      BuildContext context,
      void Function(String) onSelected,
      Iterable<String> values,
    ) {
      return Align(
        alignment: Alignment.topLeft,
        child: Card(
          elevation: 4.0,
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: autocompleteWidth,
              maxHeight: autocompleteHeight,
            ),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: values.length,
              itemBuilder: (BuildContext context, int index) {
                final value = values.elementAt(index);

                return InkWell(
                  onTap: () => onSelected(value),
                  child: Builder(builder: (BuildContext context) {
                    final bool highlight = AutocompleteHighlightedOption.of(context) == index;
                    if (highlight) {
                      valueHighlighted = value;
                      SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
                        Scrollable.ensureVisible(context, alignment: 0.5);
                      });
                    }
                    return Container(
                      alignment: Alignment.center,
                      color: highlight ? Theme.of(context).focusColor : null,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(value),
                    );
                  }),
                );
              },
            ),
          ),
        ),
      );
    },
  );

  // return TextFormField(
  //   controller: viewModel.lengthCtrlerList[index],
  //   focusNode: viewModel.focusList[numFocusIdx],
  //   // keyboardType: const TextInputType.numberWithOptions(decimal: true),
  //   keyboardType: TextInputType.none,
  //   keyboardAppearance: changeThemeViewModel.darkMode ? Brightness.dark : Brightness.light,
  //   maxLines: 1,
  //   decoration: InputDecoration(
  //     hintText: '0.0',
  //     hintStyle: hintStyle,
  //     border: InputBorder.none,
  //     fillColor: Colors.pink,
  //   ),
  //   style: const TextStyle(fontSize: 14),
  //   textAlign: TextAlign.center,
  //   cursorHeight: 18,
  //   onTap: () => _onLengthTap(index),
  //   onChanged: (value) => _onNumChanged(ref, value, index),
  // );
}
