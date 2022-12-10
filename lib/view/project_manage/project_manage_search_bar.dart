import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiite/model/kiite_icons.dart';
import 'package:kiite/view/daily_list/daily_list_view_model.dart';
import 'package:mix/mix.dart';

class SearchBar extends ConsumerWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  Widget build(context, ref) {
    final viewModel = ref.watch(projectManageViewModelProvider);

    final double barHeight = Theme.of(context).textTheme.bodyText1!.fontSize! * 2.8;
    final fieldMix = Mix(
      rounded(barHeight / 2),
      bgColor(Theme.of(context).cardColor),
      height(barHeight),
      paddingVertical(0),
      align(Alignment.bottomLeft),
      // textColor(Colors.white),
      elevation(0),
      shadow(
        spreadRadius: 0,
        blurRadius: 0,
        color: Colors.blue,
        offset: Offset.zero,
      ),
    );
    final buttonMix = Mix(
      rounded(barHeight / 2),
      bgColor(Theme.of(context).cardColor),
      height(barHeight),
      width(barHeight),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 0.2,
          ),
        ),
      ),
      child: Box(
        mix: fieldMix,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: viewModel.searchBarController,
                style: TextStyle(fontSize: Theme.of(context).textTheme.bodyText1!.fontSize),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(
                    barHeight / 3.0,
                    0,
                    0,
                    Theme.of(context).textTheme.bodyText1!.fontSize! * 0.8,
                  ),
                  border: InputBorder.none,
                  hintText: 'ケンサク',
                ),
                onChanged: (_) => {viewModel.searchBarOnChange()},
              ),
            ),
            Box(
              mix: buttonMix,
              child: TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child:
                    Icon(KiiteIcons.clear, size: Theme.of(context).textTheme.bodyText1!.fontSize),
                onPressed: () {
                  viewModel.searchBarController.clear();
                  viewModel.searchBarOnChange();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
