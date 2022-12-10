import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiite/model/kiite_icons.dart';
import 'package:kiite/provider/static_value_provider.dart';
import 'package:kiite/provider/view_model_provider.dart';
import 'package:kiite/model/kiite_Threshold.dart';

class ColorThemeSelectScreen extends ConsumerWidget {
  const ColorThemeSelectScreen({Key? key}) : super(key: key);

  @override
  Widget build(context, ref) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: KiiteThreshold.maxWidth),
          child: Scaffold(
            appBar: AppBar(title: const Text('テーマ・フォント変更')),
            body: Container(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: KiiteThreshold.mobile),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 4),
                      colorThemePickerView(context, ref),
                      const SizedBox(height: 4),
                      const Divider(),
                      const SizedBox(height: 12),
                      fontPickerView(context, ref),
                      Container(height: iosWebSafeAreaInset),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget colorThemePickerView(BuildContext context, WidgetRef ref) {
  final viewModel = ref.watch(changeThemeViewModelProvider);
  final groupValue = viewModel.currentThemeNum;
  final colorCount = viewModel.colorListLength / 2;
  final darkTheme = ref.watch(darkModeProvider);

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text('カラーテーマ'),
      const SizedBox(height: 4),
      for (var index = 0; index < colorCount; index++)
        SizedBox(
          height: 56,
          child: RadioListTile(
            selected: viewModel.currentThemeNum == index,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            activeColor: viewModel.themeData.primaryColor,
            controlAffinity: ListTileControlAffinity.trailing,
            title: Text(viewModel.themeNameList[index]),
            secondary: viewModel.iconList[index],
            value: index,
            groupValue: groupValue,
            onChanged: (value) => {
              _onColorChanged(ref, int.parse(value.toString())),
            },
          ),
        ),
      SizedBox(
        height: 56,
        child: InkWell(
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 32, 0),
                child: Icon(
                  KiiteIcons.nightlight,
                  color: viewModel.unselectedIconColor,
                ),
              ),
              Text(
                'ダークモード',
                style: TextStyle(fontSize: Theme.of(context).textTheme.subtitle1!.fontSize),
              ),
              const Spacer(),
              Switch(
                value: darkTheme,
                onChanged: (value) {
                  viewModel.toggleDarkMode(ref);
                },
              ),
            ],
          ),
          onTap: () {
            viewModel.toggleDarkMode(ref);
          },
        ),
      ),
    ],
  );
}

void _onColorChanged(WidgetRef ref, int to) {
  final viewModel = ref.watch(changeThemeViewModelProvider);
  viewModel.changeThemeTo(ref, to);
}

Widget fontPickerView(BuildContext context, WidgetRef ref) {
  final viewModel = ref.watch(changeThemeViewModelProvider);
  int groupValue = viewModel.currentFontNum;
  final fontCount = viewModel.fontListLength;

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text('フォントテーマ'),
      const SizedBox(height: 4),
      for (var index = 0; index < fontCount; index++)
        SizedBox(
          height: 56,
          child: RadioListTile(
            selected: groupValue == index,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            activeColor: Theme.of(context).primaryColor,
            controlAffinity: ListTileControlAffinity.trailing,
            title: Text(viewModel.fontNameList[index],
                style: TextStyle(fontFamily: viewModel.font(context, index).bodyText2!.fontFamily)),
            secondary: Icon(viewModel.fontIconList[index]),
            value: index,
            groupValue: groupValue,
            onChanged: (value) => {
              viewModel.changeFontTo(ref, int.parse(value.toString())),
            },
          ),
        ),
    ],
  );
}
