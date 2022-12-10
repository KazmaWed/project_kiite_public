import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import 'package:kiite/model/daily_model.dart';
import 'package:kiite/model/project_model.dart';
import 'package:kiite/provider/firebase_provider.dart';
import 'package:kiite/provider/view_model_provider.dart';
import 'package:kiite/view/daily_edit/daily_edit_add_project.dart';
import 'package:image_picker/image_picker.dart';

export 'package:kiite/model/daily_model.dart';
export 'package:kiite/view/daily_edit/daily_edit_add_project.dart';
export 'package:kiite/view/daily_edit/daily_edit_body.dart';
export 'package:kiite/view/daily_edit/daily_edit_effort_form_view.dart';
export 'package:kiite/view/daily_edit/daily_edit_screen.dart';
export 'package:kiite/view/daily_edit/daily_edit_date_pick.dart';
export 'package:kiite/view/daily_edit/daily_edit_image_picker.dart';
export 'package:kiite/view/daily_list/daily_list_item.dart';
export 'package:kiite/view/daily_list/daily_list_view.dart';
export 'package:kiite/view/draft_list/daily_list_draft_button.dart';
export 'package:kiite/view/daily_detail/daily_detali_screen.dart';
export 'package:kiite/view/daily_detail/daily_detail_comment_list.dart';
export 'package:kiite/view/daily_edit/daily_edit_effort_field.dart';
export 'package:kiite/provider/view_model_provider.dart';
export 'package:kiite/provider/firebase_provider.dart';
export 'package:kiite/provider/static_value_provider.dart';

class DailyEditViewModel {
  DailyEditViewModel(this.ref);

  final StateProviderRef ref;
  int effortItemNum = 6;

  // 編集か、下書きかチェック
  late Daily? editingDaily;
  late bool draft = false;

  // 日付
  late DateTime dateTime;
  late DateTime posted;

  // 作業時間
  late List<TextEditingController> titleCtrlerList;
  late List<TextEditingController> lengthCtrlerList;
  bool lengthFixed = false;
  String lengthLastValue = '';
  bool lengthReenter = false;

  // 本文
  late TextEditingController bodyEditingController;

  // フォーカス
  late List<FocusNode> focusList;

  // 画像
  late List<Image> _imageList; // 表示用
  late List<XFile> _xFileList; // Firestorageアップロード用
  late List<Photo> _removingPhotoList;
  late List<bool> _ifAddedFileList;

  List<Image> get imageList => _imageList;

  // -------------------- 初期化 --------------------

  Future<void> initControllers(BuildContext context) async {
    // 編集モード確認系プロパティ
    editingDaily = null;
    draft = false;

    // 日付、登校日初期化
    dateTime = DateTime.now();
    posted = DateTime.now();

    // エフォート用配列
    titleCtrlerList = [];
    lengthCtrlerList = [];
    for (var idx = 0; idx < effortItemNum; idx++) {
      titleCtrlerList.add(TextEditingController());
      lengthCtrlerList.add(TextEditingController());
    }

    // 本文
    bodyEditingController = TextEditingController();
    bodyEditingController.text = Daily.defaultBody;

    // フォーカス
    focusList = [];
    for (int index = 0; index < effortItemNum * 2 + 1; index++) {
      focusList.add(FocusNode());
    }

    // 画像
    _imageList = [];
    _xFileList = [];
    _ifAddedFileList = [];

    await ref.read(projectManageViewModelProvider).loadAllProjects();
  }

  //

  Future<void> setDaily(BuildContext context, Daily dailyInput) async {
    // 編集モード
    editingDaily = dailyInput;
    draft = false;

    // 日付、登校日初期化
    dateTime = dailyInput.dateTime;
    posted = dailyInput.posted;

    // エフォート用配列
    lengthCtrlerList = [];
    titleCtrlerList = [];
    for (var index = 0; index < effortItemNum; index++) {
      if (index < dailyInput.effortList.length) {
        // タイトルコントローラー
        final titleEditingController = TextEditingController();
        titleEditingController.text = dailyInput.effortList[index].title;
        titleCtrlerList.add(titleEditingController);
        // レングスコントローラー
        final lengthEditingController = TextEditingController();
        lengthEditingController.text = dailyInput.effortList[index].length;
        lengthCtrlerList.add(lengthEditingController);
      } else {
        titleCtrlerList.add(TextEditingController());
        lengthCtrlerList.add(TextEditingController());
      }
    }

    // 本文
    bodyEditingController = TextEditingController();
    bodyEditingController.text = dailyInput.body;

    // フォーカス
    focusList = [];
    for (var index = 0; index < effortItemNum * 2 + 1; index++) {
      focusList.add(FocusNode());
    }

    // 画像
    _imageList = [];
    _xFileList = [];
    _ifAddedFileList = [];
    _removingPhotoList = [];
    for (var photo in dailyInput.photoList) {
      imageList.add(Image.network(photo.imageUrl));
      _xFileList.add(XFile(''));
      _ifAddedFileList.add(false);
    }

    ref.read(projectManageViewModelProvider).loadAllProjects();
  }

  Future<void> setDraft(BuildContext context, Daily dailyInput) async {
    await setDaily(context, dailyInput);
    draft = true;
  }

  // -------------------- テキストコントローラーからEffortリスト生成 --------------------

  List<Effort> get effortList {
    List<Effort> list = [];
    for (var i = 0; i < titleCtrlerList.length; i++) {
      if (titleCtrlerList[i].text != '') {
        list.add(
          Effort(
            title: titleCtrlerList[i].text,
            length: lengthCtrlerList[i].text,
          ),
        );
      }
    }
    list.sort((a, b) {
      return a.length == '' && b.length != '' ? 1 : -1;
    });
    list.sort((a, b) {
      return a.title == '' && b.title != '' ? 1 : -1;
    });
    return list;
  }

  // -------------------- フォーカスコントロール・フィールド自動フォーマット --------------------

  // タイトル決定時
  void onProjectSelected(WidgetRef ref, Project project, int controllerIndex) {
    // 入力
    final titleController = titleCtrlerList[controllerIndex];
    titleController.text = project.title;

    // フォーカス移動
    focusOnLength(controllerIndex);
  }

  void onTitleTapped(TextEditingController controller) {
    controller.selection = TextSelection(baseOffset: 0, extentOffset: controller.text.length);
  }

  void onEnterProject(WidgetRef ref, Project? project, int controllerIndex) {
    final titleController = titleCtrlerList[controllerIndex];
    final input = titleController.text;

    // 空白で決定でボディに移動
    if (input.isEmpty) {
      focusList.last.requestFocus();
      bodyEditingController.selection = TextSelection.fromPosition(
        TextPosition(offset: bodyEditingController.text.indexOf('\n\n') + 1),
      );

      // タイトル入力済み時は時間に移動
    } else {
      // タイトルの自動選択
      titleCtrlerList[controllerIndex].text = project!.title;
      // ref.read(projectManageViewModelProvider).firstItem(input).title;
      // フォーカス移動
      focusOnLength(controllerIndex);
    }
  }

  void onEnterLength(WidgetRef ref, String? value, int controllerIndex) {
    final lengthController = lengthCtrlerList[controllerIndex];
    final focusIndex = controllerIndex * 2 + 1;

    lengthController.text = value ?? '';
    focusList[focusIndex + 1].requestFocus();
  }

  Future<void> onAddProjectTapped(
    BuildContext context,
    WidgetRef ref,
    int controllerIndex,
  ) async {
    // アンフォーカス
    focusList[controllerIndex * 2].unfocus();
    // 追加画面に遷移
    final projectManageViewModel = ref.watch(projectManageViewModelProvider);
    await projectManageViewModel
        .initForDialog(
      context,
      titleCtrlerList[controllerIndex].text,
      controllerIndex,
    )
        .whenComplete(() {
      addProjectDialog(context, ref);
    });
  }

  void onLengthTap(int controllerIndex) {
    final controller = lengthCtrlerList[controllerIndex];
    lengthLastValue = controller.text;
    if (controller.text.isEmpty) {
      lengthReenter = true;
    }
    // カーソルの末尾固定
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
  }

  void onNumChanged(WidgetRef ref, String value, int controllerIndex) {
    // コントローラー取得
    final controller = lengthCtrlerList[controllerIndex];

    if (double.tryParse(controller.text) == null) {
      // ----- 無効な値はクリア -----
      controller.clear();
      lengthLastValue = '';
    } else if (_backspaced(value)) {
      // ----- 既入力時のバックスペースは全消し -----
      controller.clear();
      lengthLastValue = '';
    } else if (controller.text.length >= 3 && lengthReenter) {
      // ----- 既入力時は新しい値で上書き -----
      // 最後の値を取得
      String newValue = value[value.length - 1];
      // 値を上書き
      controller.value = TextEditingValue(text: newValue);
      lengthLastValue = newValue;

      // ----- ２ケタ入力で値をフォーマット＆フォーカス移動 -----
    } else if (_validNum(value)) {
      // 値のフォーマット
      String formedValue = _round(value);

      // 処理のループガード
      if (!lengthFixed) {
        lengthFixed = true;
        // 値を更新
        controller.value = TextEditingValue(text: formedValue);

        // フォーカス移動
        focusList[controllerIndex * 2 + 2].requestFocus();
        if (controllerIndex == effortItemNum - 1) {
          bodyEditingController.selection = TextSelection.fromPosition(
            TextPosition(offset: bodyEditingController.text.indexOf('\n\n') + 1),
          );
        }
        lengthFixed = false;
      }
    }

    // カーソルの末尾固定
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
    lengthReenter = false;

    ref.read(dailyTotalEffortLength.state).state = totalLength();
  }

  // 時間にフォーカス移動
  void focusOnLength(int controllerIndex) {
    // 時間の値確認
    final lengthController = lengthCtrlerList[controllerIndex];
    lengthLastValue = lengthController.text;
    // フォーカス移動
    int numFocusIdx = controllerIndex * 2 + 1;
    focusList[numFocusIdx].requestFocus();
    // 時間既入力チェック
    if (lengthController.text.isNotEmpty) {
      lengthReenter = true;
    }
  }

  // 二桁入力チェック
  bool _validNum(String value) {
    String rawValue = value.replaceAll('.', '');
    return rawValue.length >= 2;
  }

  // 0.25四捨五入処理
  String _round(String value) {
    String rawValue = value.replaceAll('.', '');
    double decimaledNum = int.parse(rawValue) / 10;
    double roundedNum = (decimaledNum * 4).round() / 4;
    return roundedNum.toString();
  }

  bool _backspaced(String newValue) {
    return newValue.length < lengthLastValue.length;
  }

  // -------------------- Daily生成 --------------------

  Daily get getDaily {
    List<String> titleList = [];
    List<String> lengthList = [];

    List<Effort> sorted = effortList;
    for (var element in sorted) {
      titleList.add(element.title);
      lengthList.add(element.length);
    }

    // List<Photo> photoList = [];
    List<String> imageUrlList = [];
    List<String> imagePathList = [];
    if (editingDaily != null) {
      for (var removingPhoto in _removingPhotoList) {
        for (var index = 0; index < editingDaily!.photoList.length; index++) {
          bool found = false;
          if (removingPhoto.imagePath == editingDaily!.photoList[index].imagePath) {
            found = true;
            break;
          }
          if (!found) {
            imagePathList.add(editingDaily!.photoList[index].imagePath);
            imageUrlList.add(editingDaily!.photoList[index].imageUrl);
          }
        }
      }
    }
    Daily output = Daily.fromMap({
      'id': editingDaily == null ? null : editingDaily!.id,
      'posted': posted.millisecondsSinceEpoch,
      'dateTime': dateTime.millisecondsSinceEpoch,
      'titleList': titleList,
      'lengthList': lengthList,
      'body': bodyEditingController.text,
      'imageUrlList': imageUrlList,
      'imagePathList': imagePathList,
    });

    output.photoList = editingDaily == null ? [] : editingDaily!.photoList;

    return output;
  }

  // -------------------- 画像リスト操作 --------------------

  void addXFileList(List<XFile>? xFileList) {
    if (xFileList != null) {
      for (var xFile in xFileList) {
        _addXFile(xFile);
      }
    }
  }

  void _addXFile(XFile xFile) {
    _xFileList.add(xFile);
    if (kIsWeb) {
      _imageList.add(Image.network(File(xFile.path).path));
    } else {
      _imageList.add(Image.file(File(xFile.path)));
    }
    _ifAddedFileList.add(true);
  }

  Future<void> removeImageAt(int at) async {
    _imageList.removeAt(at);
    _xFileList.removeAt(at);
    if (editingDaily != null) {
      if (_ifAddedFileList[at] == false) {
        _removingPhotoList.add(editingDaily!.photoList[at]);
      }
    }
    _ifAddedFileList.removeAt(at);
  }

  // -------------------- 時間トータル計算 --------------------

  double totalLength() {
    double output = 0.0;
    for (var element in lengthCtrlerList) {
      double length = element.text == '' ? 0.0 : double.parse(element.text);
      output += length;
    }
    return output;
  }

  // -------------------- Cloud Firestore -------------------

  Future<bool> addDaily() async {
    // アップするダイアリー
    Daily newDaily = getDaily;
    // リポジトリー
    final dailyRepository = ref.read(dailyRepositoryProvider)!;
    List<Photo> photoList = await dailyRepository.addXFileList(_xFileList);

    newDaily.photoList = photoList;
    return await dailyRepository.addDaily(newDaily);
  }

  Future<bool> postDraft() async {
    var output = true;
    // リポジトリー
    final dailyRepository = ref.read(dailyRepositoryProvider)!;

    await addDaily().then((value) async {
      output = await dailyRepository.removeDraft(editingDaily!);
    }).onError((error, stackTrace) {
      output = false;
    });

    return output;
  }

  Future<bool> saveDraft() async {
    final dailyRepository = ref.read(dailyRepositoryProvider);
    return await dailyRepository!.addDaily(getDaily, collection: 'draft');
  }

  Future<bool> removeDaily() async {
    final dailyRepository = ref.read(dailyRepositoryProvider);
    return await dailyRepository!.removeDaily(getDaily);
  }

  Future<bool> removeDraft() async {
    final dailyRepository = ref.read(dailyRepositoryProvider);
    return await dailyRepository!.removeDraft(editingDaily!);
    // return await dailyRepository!.removeDraft(daily);
  }

  Future<bool> updateDaily() async {
    // 更新するダイアリー
    Daily newDaily = getDaily;
    // リポジトリー
    final dailyRepository = ref.read(dailyRepositoryProvider)!;

    // 削除Photo
    List<Photo> photoList = [];
    for (var photo in editingDaily!.photoList) {
      bool found = false;
      for (var removedPhoto in _removingPhotoList) {
        if (photo.imagePath == removedPhoto.imagePath) {
          found = true;
          break;
        }
      }
      if (!found) {
        photoList.add(photo);
      }
    }
    // 追加Photo
    final List<XFile> addedXFileList = [];
    for (var index = 0; index < _xFileList.length; index++) {
      if (_ifAddedFileList[index]) {
        addedXFileList.add(_xFileList[index]);
      }
    }
    // 画像アップデート
    await dailyRepository.removePhotoList(_removingPhotoList);
    List<Photo> addedPhotoList = await dailyRepository.addXFileList(addedXFileList);
    newDaily.photoList = [...photoList, ...addedPhotoList];
    return await dailyRepository.updateDaily(newDaily);
  }

  Future<bool> updateDraft(BuildContext context) async {
    final dailyRepository = ref.read(dailyRepositoryProvider);
    return await dailyRepository!.updateDaily(getDaily, collection: 'draft');
    // スナックバー
  }

  // -------------------- その他 -------------------

  @override
  String toString() {
    String output = dateTime.toString();
    output += '\n$effortList';
    return output;
  }
}
