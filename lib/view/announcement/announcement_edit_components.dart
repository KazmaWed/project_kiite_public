import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kiite/provider/view_model_provider.dart';

Widget announcementTitleField(WidgetRef ref) {
  final viewModel = ref.watch(announcementListScreenViewModelProvider);
  // viewModel.titleController.text = announcement.title;

  return Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextFormField(
        controller: viewModel.titleController,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'タイトル',
          // alignLabelWithHint: false,
        ),
      ),
    ),
  );
}

Widget bodyField(WidgetRef ref) {
  final viewModel = ref.watch(announcementListScreenViewModelProvider);
  // viewModel.bodyController.text = announcement.body;

  return Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        minLines: 10,
        maxLines: null,
        decoration: const InputDecoration(
          hintText: '本文',
          // alignLabelWithHint: true,
          border: InputBorder.none,
        ),
        controller: viewModel.bodyController,
      ),
    ),
  );
}

Widget reacitonField(WidgetRef ref) {
  final viewModel = ref.watch(announcementListScreenViewModelProvider);
  // viewModel.reactionTitleController.text = announcement.reactionTitle;

  return Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: viewModel.reactionTitleController,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: '対応ボタンラベル',
        ),
      ),
    ),
  );
}

Widget deliverDatePicker(BuildContext context, WidgetRef ref, Function callback) {
  final viewModel = ref.watch(announcementListScreenViewModelProvider);
  const rowHeight = 48.0;

  // viewModel.deliverDate = announcement.deliverDate;

  Future<void> onTap() async {
    final DateTime? dayPicked = await showDatePicker(
      context: context,
      initialDate: viewModel.deliverDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (dayPicked != null) {
      viewModel.deliverDate = dayPicked;
      callback();

      final TimeOfDay? timePicked = await showTimePicker(
        context: context,
        initialEntryMode: TimePickerEntryMode.input,
        initialTime: TimeOfDay(hour: DateTime.now().hour + 1, minute: 0),
      );

      if (timePicked != null) {
        viewModel.deliverDate = DateTime(
          dayPicked.year,
          dayPicked.month,
          dayPicked.day,
          timePicked.hour,
          timePicked.minute,
        );
        callback();
      }
    }
  }

  return Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () async => onTap(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.centerLeft,
        height: rowHeight,
        child: Text(DateFormat('配信日：yyyy/MM/dd - E. HH:mm').format(viewModel.deliverDate)),
      ),
    ),
  );
}

Widget dueDatePicker(BuildContext context, WidgetRef ref, Function callback) {
  final viewModel = ref.watch(announcementListScreenViewModelProvider);
  const rowHeight = 48.0;

  // viewModel.dueDate = announcement.dueDate;

  Future<void> onTap() async {
    final DateTime? dayPicked = await showDatePicker(
      context: context,
      initialDate: viewModel.dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (dayPicked != null) {
      viewModel.dueDate = dayPicked;
      callback();

      final TimeOfDay? timePicked = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 19, minute: 0),
      );

      if (timePicked != null) {
        viewModel.dueDate = DateTime(
          dayPicked.year,
          dayPicked.month,
          dayPicked.day,
          timePicked.hour,
          timePicked.minute,
        );
        callback();
      }
    }
  }

  return Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      customBorder: Border.all(),
      onTap: () async => onTap(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.centerLeft,
        height: rowHeight,
        child: Text(DateFormat('対応期限：yyyy/MM/dd - E. HH:mm').format(viewModel.dueDate)),
      ),
    ),
  );
}
