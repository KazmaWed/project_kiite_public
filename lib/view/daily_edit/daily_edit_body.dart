import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiite/model/kiite_icons.dart';

import 'package:kiite/view/daily_edit/daily_edit_view_model.dart';

// ignore: must_be_immutable
class DailyEditBodyView extends ConsumerWidget {
  const DailyEditBodyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(dailyEditViewModelProvider);
    double horizontalInset = 16;
    double topInset = 16;
    double bottomInset = 4;

    final changeThemeViewModel = ref.watch(changeThemeViewModelProvider);
    final fontSize = Theme.of(context).textTheme.bodyMedium!.fontSize!;

    return Card(
      child: Container(
        padding: EdgeInsets.fromLTRB(horizontalInset, topInset, horizontalInset, bottomInset),
        child: Column(
          children: [
            Row(
              children: [
                Icon(KiiteIcons.daily, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text('ホンブン', style: TextStyle(color: Theme.of(context).primaryColor)),
              ],
            ),
            TextFormField(
              focusNode: viewModel.focusList.last,
              style: TextStyle(
                fontSize: fontSize,
                height: 1.2,
              ),
              keyboardAppearance:
                  changeThemeViewModel.darkMode ? Brightness.dark : Brightness.light,
              cursorHeight: fontSize * 1.32,
              controller: viewModel.bodyEditingController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              minLines: 3,
              decoration: const InputDecoration(border: InputBorder.none),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
