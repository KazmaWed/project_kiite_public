import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiite/model/kiite_colors.dart';
import 'package:kiite/model/kiite_icons.dart';
import 'package:kiite/provider/static_value_provider.dart';

class UserConfigRepository {
  UserConfigRepository(this.ref);
  final StateProviderRef ref;

  // -------------------- ユーザー名取得 --------------------

  final User? user = FirebaseAuth.instance.currentUser;

  Map<String, String> userNameMap = {};

  // ID, ユーザー名マップ取得
  Future<Map<String, String>> futureUserList() async {
    final output = <String, String>{};
    await FirebaseFirestore.instance.collection('user').get().then((value) {
      for (var user in value.docs) {
        output[user.id] = user.data()['nickname'];
      }
    });
    return output;
  }

  // -------------------- カラー・テーマ・フォント --------------------

  Future<void> saveTheme(WidgetRef ref, int colorThemeNum, bool darkMode, int fontNumber) async {
    await saveUserConfig(ref);
  }

  Future<void> loadTheme() async {
    await loadTheme();
  }

  // themeData生成
  ThemeData themeData({required int themeNum, required int fontNum, required bool darkMode}) {
    int trueThemeNum = darkMode ? themeNum + themeNameList.length : themeNum;
    if (darkMode) {
      return coloredDarkTheme(primaryColorList[trueThemeNum], googleFonts[fontNum]);
    } else {
      return lightTheme(primaryColorList[trueThemeNum], googleFonts[fontNum]);
    }
  }

  int get colorListLength => themeNameList.length * 2;
  int get fontListLength => googleFonts.length;

  MaterialColor unselectedIconColor(bool darkMode) {
    return darkMode ? KiiteColors.white : KiiteColors.grey;
  }

  // ---------- 規定値 ----------

  List<String> get fontNameList => ['マル', 'カク', 'ポップ', 'マジック', 'アンティーク'];

  List<Function> googleFonts = [
    GoogleFonts.mPlusRounded1cTextTheme,
    GoogleFonts.sawarabiGothicTextTheme,
    GoogleFonts.yomogiTextTheme,
    GoogleFonts.yuseiMagicTextTheme,
    GoogleFonts.kaiseiOptiTextTheme,
  ];

  List<IconData> fontIconList = const [
    Icons.circle_outlined,
    Icons.crop_square_sharp,
    Icons.child_care_rounded,
    Icons.edit_outlined,
    Icons.brush_outlined,
  ];

  List<String> get themeNameList => [
        'サーモン',
        'ラベンダー',
        'インディゴ',
        'マッチャ',
        'マホガニー',
        'スミ',
      ];

  List<Icon> get iconList => [
        Icon(KiiteIcons.salmon),
        Icon(KiiteIcons.lavender),
        Icon(KiiteIcons.laundry),
        Icon(KiiteIcons.cafe),
        Icon(KiiteIcons.park),
        Icon(KiiteIcons.fire),
      ];

  List<MaterialColor> get primaryColorList => [
        // ライトテーマ
        KiiteColors.pink,
        KiiteColors.purple,
        KiiteColors.blue,
        KiiteColors.green,
        KiiteColors.blown,
        KiiteColors.darkGray,
        // ダークテーマ
        KiiteColors.fromString('ffb9f0'),
        KiiteColors.fromString('d5beff'),
        KiiteColors.materialColor(Colors.tealAccent),
        KiiteColors.materialColor(Colors.lightGreenAccent),
        KiiteColors.fromString('ffff64'),
        KiiteColors.white,
      ];

  MaterialColor get darkCardColor => KiiteColors.fromString('303234');

  MaterialColor get backgroundColor => KiiteColors.fromString('202224');

  ThemeData themeDataList(int colorNum, bool darkMode, int fontNum) {
    if (darkMode) {
      return coloredDarkTheme(primaryColorList[colorNum + 6], googleFonts[fontNum]);
    } else {
      return lightTheme(primaryColorList[colorNum], googleFonts[fontNum]);
    }
  }

  ThemeData lightTheme(MaterialColor primaryColor, Function googleFont) {
    return ThemeData(
      primarySwatch: primaryColor,
      appBarTheme: const AppBarTheme(elevation: 0),
      textTheme: googleFont(ThemeData.light().textTheme),
      drawerTheme: const DrawerThemeData(elevation: 0),
    );
  }

  ThemeData coloredDarkTheme(MaterialColor color, Function googleFont) {
    return ThemeData.dark().copyWith(
      // フォント
      textTheme: googleFont(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(elevation: 0),

      // 文字色など
      primaryColor: color,
      switchTheme: SwitchThemeData(
        overlayColor: MaterialStateProperty.all(KiiteColors.grey),
        thumbColor: MaterialStateProperty.all(KiiteColors.white),
        trackColor: MaterialStateProperty.all(Colors.grey),
      ),
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: color,
        brightness: Brightness.dark,
        accentColor: color,
        backgroundColor: ThemeData.dark().appBarTheme.foregroundColor,
      ),
      cardTheme: CardTheme(color: darkCardColor),
      scaffoldBackgroundColor: backgroundColor,
    );
  }

  ThemeData loadingTheme() {
    return ThemeData.light().copyWith(
      // 文字色など
      primaryColor: primaryColorList.first,
      switchTheme: SwitchThemeData(
        overlayColor: MaterialStateProperty.all(primaryColorList.first),
        thumbColor: MaterialStateProperty.all(primaryColorList.first),
        trackColor: MaterialStateProperty.all(primaryColorList.first),
      ),
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: primaryColorList.first,
        brightness: Brightness.light,
        accentColor: primaryColorList.first,
      ),
      appBarTheme: const AppBarTheme(elevation: 0),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: primaryColorList.first,
        selectedIconTheme: IconThemeData(color: primaryColorList.first),
        unselectedIconTheme: IconThemeData(color: primaryColorList.first),
        selectedLabelStyle: TextStyle(color: primaryColorList.first),
        unselectedLabelStyle: TextStyle(color: primaryColorList.first),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        foregroundColor: primaryColorList.first,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: primaryColorList.first,
        elevation: 0,
      ),
      scaffoldBackgroundColor: primaryColorList.first,
    );
  }
}
