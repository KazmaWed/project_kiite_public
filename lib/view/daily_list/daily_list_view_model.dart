import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiite/model/daily_model.dart';
import 'package:kiite/provider/firebase_provider.dart';

export 'package:kiite/view/daily_list/daily_list_view.dart';
export 'package:kiite/view/daily_list/daily_list_reaction.dart';
export 'package:kiite/view/daily_list/daily_list_item.dart';
export 'package:kiite/view/daily_list/daily_list_loading_view.dart';
export 'package:kiite/provider/view_model_provider.dart';
export 'package:kiite/provider/firebase_provider.dart';
export 'package:kiite/provider/static_value_provider.dart';

class DailyListViewModel {
  DailyListViewModel(this.ref);
  final StateProviderRef ref;
  late Function callback;

  bool firstTap = true;
  bool firstBuild = true;
  String? filterBy;
  List<Daily> dailyList = [];

  void createFirstItems(List<Daily> firstDailyList) {
    if (firstBuild) {
      // for (var daily in dailyList) {
      //   dailyCardList.add(DailyListCard(daily: daily));
      // }
      dailyList += firstDailyList;
      firstBuild = false;
    }
  }

  Future<void> refreshDailyList() async {
    firstBuild = true;
    // FutureBuilder再描画
    dailyList = [];
    ref.read(futureDailyListProvider.state).state =
        ref.read(dailyRepositoryProvider)!.futureDailyList(filterBy);
    ref.read(futureDraftListProvider.state).state =
        ref.read(dailyRepositoryProvider)!.futureDraftList();
  }

  Future<void> loadMoreDailies() async {
    final loadedItems = await _moreDailies();
    // for (var index = 0; index < loadedItems.length; index++) {
    //   output.add(DailyListCard(daily: loadedItems[index]));
    // }
    dailyList += loadedItems;
    // return output;
  }

  void updateItem(Daily daily) {
    for (var index = 0; index < dailyList.length; index++) {
      if (dailyList[index].id! == daily.id!) {
        dailyList[index] = daily;
        break;
      }
    }
  }

  Future<List<Daily>> _moreDailies() async {
    final repository = ref.read(dailyRepositoryProvider)!;
    final dailiesLoaded = await repository.additionalDailyList(filterBy);
    return dailiesLoaded;
  }
}
