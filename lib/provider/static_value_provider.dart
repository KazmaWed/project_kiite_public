import 'package:flutter/material.dart';
import 'package:kiite/model/kiite_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiite/provider/view_model_provider.dart';
import 'package:kiite/repository/user_config_repository.dart';

// ユーザー名リスト
final futureUserListProvider = Provider<Future<Map<String, String>>>((ref) async {
  return ref.read(userConfigRepositoryProvider).futureUserList();
});

// ニックネーム格納・参照用
var userNameMap = <String, String>{};

// -------------------- Daily --------------------

final selectedDailyIdProvider = StateProvider<String>((ref) {
  return '';
});

// -------------------- ColorTheme --------------------

// テーマ
final themeDataProvider = StateProvider<ThemeData>((ref) {
  final viewModel = ref.watch(changeThemeViewModelProvider);
  viewModel.initViewModel();
  final repository = ref.watch(userConfigRepositoryProvider);
  return repository.loadingTheme();
});

// ダークモード
final darkModeProvider = StateProvider<bool>((ref) {
  final viewModel = ref.watch(changeThemeViewModelProvider);
  return viewModel.darkMode;
});

final userConfigRepositoryProvider = StateProvider((ref) {
  return UserConfigRepository(ref);
});

// 設定の保存、呼び出し

Future<void> saveUserConfig(WidgetRef ref) async {
  final viewModel = ref.watch(changeThemeViewModelProvider);

  final pref = await SharedPreferences.getInstance();
  await pref.setInt('colorThemeNumber', viewModel.currentThemeNum);
  await pref.setBool('darkMode', viewModel.darkMode);
  await pref.setInt('fontNumber', viewModel.currentFontNum);
}

// -------------------- FloatingActionButtonIcon --------------------

final commentButtonIconProvider = StateProvider<IconData>((ref) {
  return KiiteIcons.sms;
});

final staticFocusNode = FocusNode();

// -------------------- for Flutter web on iOS --------------------

double iosWebSafeAreaInset = 0;
