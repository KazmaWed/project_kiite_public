import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiite/model/kiite_colors.dart';
import 'package:kiite/model/project_model.dart';
import 'package:kiite/provider/firebase_provider.dart';
import 'package:kiite/provider/view_model_provider.dart';

export 'package:kiite/view/project_manage/project_manage_edit_view.dart';
export 'package:kiite/view/project_manage/project_manage_list_view.dart';
export 'package:kiite/view/project_manage/project_manage_list_item.dart';
export 'package:kiite/view/project_manage/project_manage_list_screen.dart';
export 'package:kiite/model/project_model.dart';

class ProjectManageViewModel {
  ProjectManageViewModel(this.ref);
  final StateProviderRef ref;
  late Function searchBarOnChange;

  late List<Project> allProjects;
  late List<Project> suggestedProject;

  // ---------------------------------------- プロジェクト一覧画面 ----------------------------------------

  String searchText = '';
  bool firstTap = true;
  ScrollController controller = ScrollController();

  // 全プロジェクトをallProjectsに格納後、出力
  Future<List<Project>> futureAllProject() async {
    await loadAllProjects();
    return allProjects;
  }

  // id指定でプロジェクトを取得
  Future<Project> projectById(WidgetRef ref, String id) async {
    return ref.read(projectRepositoryProvider)!.getProjectById(id);
  }

  Future<Set<String>> otherFormById(WidgetRef ref, String projectId) async {
    return ref.read(projectRepositoryProvider)!.getOtherFormById(projectId);
  }

  // ---------------------------------------- プロジェクト情報変更画面 ----------------------------------------

  // ---------- プロジェクト情報、ダイアリー登録画面のダイアログ画面共用 ----------
  late int controllerIndex;
  late TextEditingController titleController;
  late List<TextEditingController> otherControllerList;
  late List<FocusNode> focusList;

  // ---------- プロジェクト管理画面用プロパティ ----------
  final searchBarController = TextEditingController();
  final searchBarFocus = FocusNode();

  Project? editingProject;
  late bool edited;
  final int _leastFieldNum = 8;

  final hintText = [
    'ひらがな表記',
    'アルファベット表記',
    '漢字表記',
    '略称や他の書き方',
    '検索されやすい表記や文字列',
    '検索されやすい表記や文字列',
    '検索されやすい表記や文字列',
    '検索されやすい表記や文字列',
  ];

  // ---------- 初期化 ----------
  Future<void> initEditView(Project? project) async {
    edited = false;
    // プロジェクト最新の値取得
    final repository = ref.read(projectRepositoryProvider)!;
    if (project == null) {
      editingProject = null;
    } else {
      editingProject = await repository.getProjectById(project.id!);
    }

    // タイトル
    final title = editingProject == null ? '' : editingProject!.title;
    titleController = TextEditingController(text: title);
    // 他の読み方
    otherControllerList = [];
    int numOfOtherForm = editingProject == null ? 0 : editingProject!.otherForm.length;
    int numOfBlankField = _leastFieldNum > numOfOtherForm ? _leastFieldNum - numOfOtherForm : 0;
    // フィールドに初期値代入
    for (var index = 0; index < numOfOtherForm; index++) {
      otherControllerList
          .add(TextEditingController(text: editingProject!.otherForm.toList()[index]));
    }
    // 空のフィールド
    for (var index = 0; index < numOfBlankField; index++) {
      otherControllerList.add(TextEditingController());
    }

    // フォーカスノード
    focusList = [];
    for (var index = 0; index < otherControllerList.length + 1; index++) {
      focusList.add(FocusNode());
    }
  }

  // 他の読み方用に生成するフィールドの数
  int get numOfField {
    if (editingProject == null) {
      return _leastFieldNum;
    } else {
      return editingProject!.otherForm.length > _leastFieldNum
          ? editingProject!.otherForm.length
          : _leastFieldNum;
    }
  }

  // Firebase保存用
  Project editedProject() {
    String title = titleController.text;
    Set<String> otherForm = {};
    for (var controller in otherControllerList) {
      otherForm.add(controller.text);
    }
    final edited = Project(title: title, otherForm: otherForm);
    if (editingProject != null) {
      edited.id = editingProject!.id;
    }
    return edited;
  }

  Future<bool> add(WidgetRef ref) async {
    final repository = ref.watch(projectRepositoryProvider)!;
    return repository.addProject(editedProject());
  }

  // プロジェクト情報更新
  Future<bool> update(WidgetRef ref) async {
    final repository = ref.watch(projectRepositoryProvider)!;
    return await repository.updateProject(editedProject());
  }

  // ---------------------------------------- ダイアリー登録画面のダイアログ ----------------------------------------

  // ---------- ダイアログ用プロパティ ----------
  final dialogHintText = [
    'ひらがな表記',
    'アルファベット表記',
    '略称や他の書き方',
    '検索されやすい物なんでも',
  ];

  // ダイアリー編集画面プロジェクト登録ダイアログ表示の準備
  Future<void> initForDialog(BuildContext context, String initialValue, int controllerIndex) async {
    showNetworkingCircular(context);

    titleController = TextEditingController();
    otherControllerList = [];
    for (var index = 0; index < dialogHintText.length; index++) {
      otherControllerList.add(TextEditingController());
    }
    focusList = [];
    for (var idx = 0; idx < dialogHintText.length + 1; idx++) {
      focusList.add(FocusNode());
    }
    await ref.read(projectRepositoryProvider)!.getSuggestion(initialValue).then((value) {
      suggestedProject = value;
      suggestedProject =
          suggestedProject.length < 5 ? suggestedProject : suggestedProject.getRange(0, 5).toList();

      this.controllerIndex = controllerIndex;

      Navigator.of(context).pop();
    });
  }

  // ---------- ボタンアクション ----------

  // 確定ボタン
  Future<void> onSubmit(BuildContext context, WidgetRef ref) async {
    // プログレスインジケータ
    showNetworkingCircular(context);

    // テキストフィールドに反映
    final dailyEditViewModel = ref.watch(dailyEditViewModelProvider);
    dailyEditViewModel.titleCtrlerList[controllerIndex].text = titleController.text;

    // Firebase保存
    final newProject = ref.watch(projectManageViewModelProvider).newProject(ref);
    final repository = ref.watch(projectRepositoryProvider)!;
    await repository.addProject(newProject);

    dailyEditViewModel.focusList[controllerIndex * 2 + 1].requestFocus();

    allProjects = await ref.read(projectRepositoryProvider)!.getSuggestion('').whenComplete(() {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    });
  }

  // 戻るボタン
  void onCancel(BuildContext context, WidgetRef ref) {
    final dailyEditViewModel = ref.watch(dailyEditViewModelProvider);

    int focusIndex = controllerIndex * 2;
    Navigator.of(context).pop();
    dailyEditViewModel.focusList[focusIndex].requestFocus();
  }

  // 候補ボタン
  void onSuggestButtonTap(BuildContext context, Project project) {
    final viewModel = ref.watch(dailyEditViewModelProvider);
    viewModel.titleCtrlerList[controllerIndex].text = project.title;
    Navigator.of(context).pop();
    ref.read(dailyEditViewModelProvider).focusOnLength(controllerIndex);
  }

  // ---------- その他 ----------

  // アンフォーカス
  void unFocus() {
    for (var focus in focusList) {
      if (focus.hasPrimaryFocus) {
        focus.unfocus();
        break;
      }
    }
  }

  // 新規プロジェクト出力
  Project newProject(WidgetRef ref) {
    String title = titleController.text;
    Set<String> otherForm = {};
    for (var controller in otherControllerList) {
      otherForm.add(controller.text);
    }
    return Project(title: title, otherForm: otherForm);
  }

  Project firstItem(String pattern) {
    return getSuggestion(pattern).first;
  }

  // 全プロジェクトをallProjectsに格納
  Future<void> loadAllProjects() async {
    allProjects = await ref.read(projectRepositoryProvider)!.allProject();
  }

  // allProjectsを先頭一致、部分一致でフィルター
  List<Project> getSuggestion(String pattern) {
    allProjects.sort((a, b) => a.title.compareTo(b.title));
    final prefixMatch = <Project>[];
    final contains = <Project>[];
    final others = <Project>[];
    late final List<Project> output;

    // ひらがな＆小文字化
    String patternInHira = pattern.hiragana.toLowerCase();

    // 全件先頭一致確認
    for (var project in allProjects) {
      bool matched = false;
      // タイトル先頭一致確認
      String titleInHira = project.title.hiragana.toLowerCase();
      if (titleInHira.startsWith(patternInHira)) {
        prefixMatch.add(project);
        matched = true;
      } else {
        // 読み方先頭一致確認
        for (var otherForm in project.otherForm) {
          String otherFormInHira = otherForm.hiragana.toLowerCase();
          if (otherFormInHira.startsWith(patternInHira)) {
            prefixMatch.add(project);
            matched = true;
            break;
          }
        }
      }
      // 見つからなければ
      if (!matched) {
        others.add(project);
      }
    }

    // 先頭一致しなかった物の部分一致確認
    for (var project in others) {
      // タイトルの部分一致確認
      String titleInHira = project.title.hiragana.toLowerCase();
      if (titleInHira.contains(patternInHira)) {
        contains.add(project);
      } else {
        for (var otherForm in project.otherForm) {
          String otherFormInHira = otherForm.hiragana.toLowerCase();
          if (otherFormInHira.contains(patternInHira)) {
            prefixMatch.add(project);
            break;
          }
        }
      }
    }

    output = [...prefixMatch, ...contains];
    return output;
  }
}
