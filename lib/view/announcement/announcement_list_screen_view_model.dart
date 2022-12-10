import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiite/model/announcement_model.dart';
import 'package:kiite/provider/firebase_provider.dart';

class AnnouncementListScreenViewModel {
  AnnouncementListScreenViewModel(this.ref);
  final StateProviderRef ref;

  // Future<List<Announcement>> futureAnnouncementList = Future<List<Announcement>>.value([]);
  List<Announcement> loadedAnnouncementList = [];
  bool firstBuild = true;

  String? id;
  final titleController = TextEditingController();
  final bodyController = TextEditingController();
  late DateTime deliverDate;
  late DateTime dueDate;
  final reactionTitleController = TextEditingController();
  List<String> reactedBy = [];

  // リストビューのための初期処理
  void initList() {
    ref.read(futureAnnouncementListProvider.state).state = announcementList();
  }

  // 編集画面のための初期処理
  void initForPost() {
    id = null;
    titleController.clear();
    bodyController.clear();
    deliverDate = DateTime.now();
    dueDate = DateTime.now();
    reactionTitleController.text = '対応しました';
    reactedBy = [];
  }

  void initForEdit(Announcement announcement) {
    id = announcement.id;
    titleController.text = announcement.title;
    bodyController.text = announcement.body;
    deliverDate = announcement.deliverDate;
    dueDate = announcement.dueDate;
    reactionTitleController.text = announcement.reactionTitle;
    reactedBy = announcement.reactedBy ?? [];
  }

  Future<List<Announcement>> announcementList() async {
    final repository = ref.read(announcementRepositoryProvider)!;
    return repository.futureAnnouncementList();
  }

  Future<List<Announcement>> additionalAnnouncementList() async {
    final repository = ref.read(announcementRepositoryProvider)!;
    return repository.futureAdditionalAnnouncementList();
  }

  Announcement announcement() {
    return Announcement(
      id: id,
      title: titleController.text,
      body: bodyController.text,
      created: DateTime.now(),
      deliverDate: deliverDate,
      dueDate: dueDate,
      reactionTitle: reactionTitleController.text,
    );
  }

  // -------------------- Firebase --------------------

  Future<Announcement> futureAnnouncement(String id) async {
    final repository = ref.read(announcementRepositoryProvider)!;
    return repository.futureAnnouncementById(id);
  }

  Future<List<String>> futureReactedUserList(String id) async {
    final repository = ref.read(announcementRepositoryProvider)!;
    return repository.reactedUserlist(id);
  }

  Future<bool> post() async {
    var succeed = true;
    await ref.read(announcementRepositoryProvider)!.post(announcement()).catchError((e) {
      succeed = false;
    });
    return succeed;
  }

  Future<bool> update() async {
    var succeed = true;
    await ref.read(announcementRepositoryProvider)!.update(announcement()).catchError((e) {
      succeed = false;
    });
    return succeed;
  }
}
