import 'package:kiite/view/announcement/announcement_list_screen_view_model.dart';
import 'package:kiite/view/comment_timeline/comment_timeline_view_model.dart';
import 'package:kiite/view/project_manage/project_manage_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiite/view/daily_list/daily_list_view_model.dart';
import 'package:kiite/view/fee_demand/fee_demand_view_model.dart';
import 'package:kiite/view/daily_edit/daily_edit_view_model.dart';
import 'package:kiite/view/daily_detail/daily_detail_view_model.dart';
import 'package:kiite/view/setting/change_theme_view_model.dart';
import 'package:kiite/view/wide_screen/wide_screen_view_model.dart';

// -------------------- ViewModel --------------------

final wideScreenViewModelProvider = StateProvider<WideScreenViewModel>((ref) {
  return WideScreenViewModel(ref);
});

final dailyListViewModelProvider = StateProvider<DailyListViewModel>((ref) {
  return DailyListViewModel(ref);
});

final commentTimelineViewModelProvider = StateProvider<CommentTimelineViewModel>((ref) {
  return CommentTimelineViewModel(ref);
});

final dailyEditViewModelProvider = StateProvider<DailyEditViewModel>((ref) {
  return DailyEditViewModel(ref);
});

final dailyTotalEffortLength = StateProvider<double>((ref) {
  return 0;
});

final dailyDetailViewModelProvider = StateProvider<DailyDetailViewModel>((ref) {
  return DailyDetailViewModel(ref);
});

final feeDemandViewModelProvider = StateProvider<FeeDemandViewModel>((ref) {
  return FeeDemandViewModel(ref);
});

final projectManageViewModelProvider = StateProvider<ProjectManageViewModel>((ref) {
  return ProjectManageViewModel(ref);
});

final changeThemeViewModelProvider = StateProvider<ChangeThemeViewModel>((ref) {
  return ChangeThemeViewModel(ref);
});

final announcementListScreenViewModelProvider =
    StateProvider<AnnouncementListScreenViewModel>((ref) {
  return AnnouncementListScreenViewModel(ref);
});
