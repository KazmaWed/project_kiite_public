import 'package:flutter/material.dart';

class KiiteSnackBar {
  KiiteSnackBar(this.context);

  final BuildContext context;

  void sent() {
    ScaffoldMessenger.of(context).showSnackBar(halfSnackBar(context, '送信シマシタ'));
  }

  void saved() {
    ScaffoldMessenger.of(context).showSnackBar(halfSnackBar(context, '保存シマシタ'));
  }

  void posted() {
    ScaffoldMessenger.of(context).showSnackBar(halfSnackBar(context, '投稿シマシタ'));
  }

  void removed() {
    ScaffoldMessenger.of(context).showSnackBar(halfSnackBar(context, '削除シマシタ'));
  }

  void sendFailed() {
    ScaffoldMessenger.of(context).showSnackBar(halfSnackBar(context, '送信デキマセンデシタ…'));
  }

  void saveFailed() {
    ScaffoldMessenger.of(context).showSnackBar(halfSnackBar(context, '保存デキマセンデシタ…'));
  }

  void postFailed() {
    ScaffoldMessenger.of(context).showSnackBar(halfSnackBar(context, '投稿デキマセンデシタ…'));
  }

  void removeFailed() {
    ScaffoldMessenger.of(context).showSnackBar(halfSnackBar(context, '削除デキマセンデシタ…'));
  }

  void refreshed() {
    ScaffoldMessenger.of(context).showSnackBar(halfSnackBar(context, '更新シマシタ'));
  }

  void copied() {
    ScaffoldMessenger.of(context).showSnackBar(halfSnackBar(context, 'コピーシマシタ'));
  }

  SnackBar halfSnackBar(BuildContext context, String str) {
    const barWidth = 160.0;

    return SnackBar(
      behavior: SnackBarBehavior.floating,
      dismissDirection: DismissDirection.down,
      duration: const Duration(seconds: 2),
      width: barWidth,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      content: SizedBox(
        width: barWidth,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_fire_department_outlined,
              color: Theme.of(context).cardColor,
              size: Theme.of(context).textTheme.subtitle1!.fontSize,
            ),
            const SizedBox(width: 6),
            Text(
              str,
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.subtitle1!.fontSize,
                fontStyle: Theme.of(context).textTheme.bodyText1!.fontStyle,
                color: Theme.of(context).canvasColor,
              ),
            ),
            const SizedBox(width: 2),
          ],
        ),
      ),
    );
  }
}
