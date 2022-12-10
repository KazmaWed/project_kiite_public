import 'package:firebase_auth/firebase_auth.dart';
import 'package:kiite/model/announcement_model.dart';
import 'package:kiite/provider/static_value_provider.dart';
import 'package:kiite/repository/announcement_repository.dart';
import 'package:kiite/repository/user_info_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiite/repository/project_repository.dart';
import 'package:kiite/repository/reaction_repository.dart';
import 'package:kiite/view/daily_detail/daily_detail_view_model.dart';
import 'package:kiite/model/daily_model.dart';
import 'package:kiite/model/comment_model.dart';
import 'package:kiite/repository/daily_repository.dart';
import 'package:kiite/repository/transport_fee_repository.dart';
import 'package:kiite/repository/comment_repository.dart';

// -------------------- Daily Cloud Firestore --------------------

final dailyRepositoryProvider = StateProvider<DailyRepository?>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  return user == null ? null : DailyRepository();
});

final futureDailyByIdProvider = StateProvider<Future<Daily?>>((ref) async {
  final dailyRepository = ref.watch(dailyRepositoryProvider);
  final dailyId = ref.watch(selectedDailyIdProvider);
  return dailyRepository == null ? Future.value(null) : dailyRepository.futureDailyById(dailyId);
});

final futureDailyListProvider = StateProvider<Future<List<Daily>>>((ref) async {
  final dailyRepository = ref.watch(dailyRepositoryProvider);
  return dailyRepository == null ? Future.value(<Daily>[]) : dailyRepository.futureDailyList();
});

// -------------------- Comment Timeline Cloud Firestore --------------------

final commentRepositoryProvider = StateProvider((ref) {
  final user = FirebaseAuth.instance.currentUser;
  return user == null ? null : CommentRepository();
});

final futureCommentTimelineProvider = StateProvider<Future<List<CommentTimeline>>>((ref) async {
  final repository = ref.watch(commentRepositoryProvider);
  return repository == null ? Future.value(<CommentTimeline>[]) : repository.futureCommentTLList();
});

final futureDraftListProvider = StateProvider<Future<List<Daily>>>((ref) async {
  final repository = ref.watch(dailyRepositoryProvider);
  return repository == null ? Future.value(<Daily>[]) : repository.futureDraftList();
});

// -------------------- Reaction Cloud Firestore --------------------

final reactionRepositoryProvider = StateProvider((ref) {
  final user = FirebaseAuth.instance.currentUser;
  return user == null ? null : ReactionRepository();
});

// -------------------- Comment Cloud Firestore --------------------

// final selectedDailyIdProvider = StateProvider<String>((ref) {
//   return '';
// });

// -------------------- Project Cloud Firestore --------------------

final projectRepositoryProvider = StateProvider((ref) {
  final user = FirebaseAuth.instance.currentUser;
  return user == null ? null : ProjectRepository();
});

// -------------------- Transport Fee --------------------

final transportFeeRepository = StateProvider((ref) {
  final user = FirebaseAuth.instance.currentUser;
  return user == null ? null : TransportFeeRepository();
});

// -------------------- Announcement --------------------

final futureAnnouncementListProvider = StateProvider<Future<List<Announcement>>>((ref) {
  return Future<List<Announcement>>.value([]);
});

final futureAnnouncementProvider = StateProvider<Future<Announcement>>((ref) {
  return Future.value(Announcement.newItem());
});

final announcementRepositoryProvider = StateProvider((ref) {
  final user = FirebaseAuth.instance.currentUser;
  return user == null ? null : AnnouncementRepository();
});

final userInfoRepositoryProvider = StateProvider<UserInfoRepository>((ref) {
  // final user = FirebaseAuth.instance.currentUser;
  return UserInfoRepository();
});
