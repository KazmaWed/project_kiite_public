import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiite/provider/static_value_provider.dart';
import 'package:kiite/repository/user_config_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangeThemeViewModel {
  ChangeThemeViewModel(this.ref);
  StateProviderRef ref;

  // Set<String> readDailies = {};
  late UserConfigRepository repository;
  int _themeNum = 0;
  bool _darkMode = false;
  int _fontNum = 0;

  void initViewModel() {
    repository = ref.watch(userConfigRepositoryProvider);
  }

  // -------------------- ゲッター --------------------

  // テーマ
  ThemeData get themeData {
    return repository.themeData(themeNum: _themeNum, fontNum: 0, darkMode: _darkMode);
  }

  Future<void> loadTheme() async {
    final pref = await SharedPreferences.getInstance();
    _themeNum = pref.getInt('colorThemeNumber') ?? 0;
    _darkMode = pref.getBool('darkMode') ?? false;
    _fontNum = pref.getInt('fontNumber') ?? 0;
    ref.read(themeDataProvider.state).state = themeData;
  }

  // 選択中カラーの番号
  int get currentThemeNum => _themeNum;

  // ダークモード
  bool get darkMode => _darkMode;

  // フォント番号
  int get currentFontNum => _fontNum;

  // カラーの名前配列
  List<String> get themeNameList => repository.themeNameList;

  // カラーのアイコン
  List<Icon> get iconList => repository.iconList;

  // フォント選択ボタンに使われるカラー
  MaterialColor get unselectedIconColor => repository.unselectedIconColor(_darkMode);

  // カラーの数
  int get colorListLength => repository.colorListLength;

  // フォント名配列
  List<String> get fontNameList => repository.fontNameList;

  // フォントアイコン
  List<IconData> get fontIconList => repository.fontIconList;

  // フォントの数
  int get fontListLength => repository.fontListLength;

  // -------------------- メソッド --------------------

  void changeThemeTo(WidgetRef ref, int to) {
    _themeNum = to;
    ref.read(themeDataProvider.state).state = repository.themeData(
      themeNum: _themeNum,
      fontNum: _fontNum,
      darkMode: _darkMode,
    );
    repository.saveTheme(ref, _themeNum, darkMode, _fontNum);
  }

  void toggleDarkMode(WidgetRef ref) {
    _darkMode = !_darkMode;
    ref.read(darkModeProvider.state).state = _darkMode;
    ref.read(themeDataProvider.state).state = repository.themeData(
      themeNum: _themeNum,
      fontNum: _fontNum,
      darkMode: _darkMode,
    );
    repository.saveTheme(ref, _themeNum, darkMode, _fontNum);
  }

  void changeFontTo(WidgetRef ref, int to) {
    _fontNum = to;
    ref.read(themeDataProvider.state).state = repository.themeData(
      themeNum: _themeNum,
      fontNum: _fontNum,
      darkMode: _darkMode,
    );
    repository.saveTheme(ref, _themeNum, darkMode, _fontNum);
  }

  TextTheme font(BuildContext context, int index) {
    Function font = repository.googleFonts[index];
    return font();
  }
}
