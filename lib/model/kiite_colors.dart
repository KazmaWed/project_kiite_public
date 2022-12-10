import 'package:flutter/material.dart';

class KiiteColors {
  static MaterialColor get pink => fromString('f05980');

  static MaterialColor get purple => fromString('8C60C0');

  static MaterialColor get blue => fromString('428bca');

  static MaterialColor get yellow => Colors.amber;

  static MaterialColor get green => fromString('5CA28A');

  static MaterialColor get blown => fromString('A25C5C');
  static MaterialColor get darkGray => fromString('384048');

  static MaterialColor get grey => Colors.grey;

  // static Color get iconPink => Colors.pink.withOpacity(0.7);
  static Color get iconPink => pink;

  // static Color get iconBlue => Colors.cyan.withOpacity(0.8);
  static Color get iconBlue => blue;

  // static Color get iconYellow => Colors.amber.withOpacity(1);
  static Color get iconYellow => Colors.orange;

  static Color get textYellow => Colors.orange;

  // static double get iconOpacity => 0.9;

  static MaterialColor get white => const MaterialColor(
        0xFFFFFFFF,
        <int, Color>{
          50: Color(0xFFFFFFFF),
          100: Color(0xFFFFFFFF),
          200: Color(0xFFFFFFFF),
          300: Color(0xFFFFFFFF),
          400: Color(0xFFFFFFFF),
          500: Color(0xFFFFFFFF),
          600: Color(0xFFFFFFFF),
          700: Color(0xFFFFFFFF),
          800: Color(0xFFFFFFFF),
          900: Color(0xFFFFFFFF),
        },
      );

  static MaterialColor materialColor(Color color) {
    final hexCodeStr = '0xFF${color.value.toRadixString(16).substring(2, 8)}';
    final hexCodeInt = int.parse(hexCodeStr);
    return MaterialColor(
      hexCodeInt,
      <int, Color>{
        50: Color(hexCodeInt),
        100: Color(hexCodeInt),
        200: Color(hexCodeInt),
        300: Color(hexCodeInt),
        400: Color(hexCodeInt),
        500: Color(hexCodeInt),
        600: Color(hexCodeInt),
        700: Color(hexCodeInt),
        800: Color(hexCodeInt),
        900: Color(hexCodeInt),
      },
    );
  }

  static MaterialColor fromString(String colorStr) {
    final hexCodeStr = '0xFF$colorStr';
    final hexCodeInt = int.parse(hexCodeStr);
    return MaterialColor(
      hexCodeInt,
      <int, Color>{
        50: Color(hexCodeInt),
        100: Color(hexCodeInt),
        200: Color(hexCodeInt),
        300: Color(hexCodeInt),
        400: Color(hexCodeInt),
        500: Color(hexCodeInt),
        600: Color(hexCodeInt),
        700: Color(hexCodeInt),
        800: Color(hexCodeInt),
        900: Color(hexCodeInt),
      },
    );
  }

  String colorToHexString(Color color) {
    return '#FF${color.value.toRadixString(16).substring(2, 8)}';
  }
}

void showNetworkingCircular(BuildContext context) {
  showDialog(
    barrierDismissible: false, // 周辺タップで戻らない
    context: context,
    builder: (_) {
      return WillPopScope(
        onWillPop: () async => false, // 戻るボタンで戻らない
        child: const SimpleDialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.all(0),
          insetPadding: EdgeInsets.all(0),
          children: [
            Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ],
        ),
      );
    },
  );
}

// String hiragana(String str) {
//   if (str.isEmpty) {
//     return '';
//   } else {
//     return str.replaceAllMapped(RegExp("[ァ-ヴ]"), (Match m) => String.fromCharCode(m.group(0)!.codeUnitAt(0) - 0x60));
//   }
// }

extension JapaneseFormatter on String {
  String get hiragana {
    if (isEmpty) {
      return '';
    } else {
      return replaceAllMapped(
          RegExp("[ァ-ヴ]"), (Match m) => String.fromCharCode(m.group(0)!.codeUnitAt(0) - 0x60));
    }
  }
}

extension NameListFormatter on List<String> {
  List<String> get san {
    List<String> output = [];
    forEach((element) {
      output.add('$elementさん');
    });
    output.sort((a, b) => a.hiragana.compareTo(b.hiragana));
    return output;
  }
}
