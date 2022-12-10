import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiite/model/kiite_Threshold.dart';
import 'package:kiite/provider/firebase_provider.dart';
import 'package:kiite/provider/view_model_provider.dart';
import 'package:kiite/view/announcement/announcement_list_components.dart';
import 'package:visibility_detector/visibility_detector.dart';

class AnnouncementListView extends StatefulWidget {
  const AnnouncementListView({Key? key}) : super(key: key);

  @override
  State<AnnouncementListView> createState() => _AnnouncementListViewState();
}

class _AnnouncementListViewState extends State<AnnouncementListView> {
  bool bottomReached = false;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final viewModel = ref.watch(announcementListScreenViewModelProvider);
      final repository = ref.watch(announcementRepositoryProvider)!;

      Future<void> loadMoreDaily(WidgetRef ref) async {
        viewModel.loadedAnnouncementList += await repository.futureAdditionalAnnouncementList();
        bottomReached = false;
        setState(() {});
      }

      Widget bottomCircular(WidgetRef ref) {
        if (!repository.allAnnouncementLoaded) {
          return VisibilityDetector(
            key: const Key('daily_list'),
            onVisibilityChanged: (visibilityInfo) {
              if (!bottomReached && visibilityInfo.visibleFraction > 0) {
                loadMoreDaily(ref);
                bottomReached = true;
              }
            },
            child: Container(
              alignment: Alignment.bottomCenter,
              height: 84,
              child: const CircularProgressIndicator(),
            ),
          );
        } else {
          return Container();
        }
      }

      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: KiiteThreshold.tablet),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 84),
            cacheExtent: 2000,
            children: [
              for (var index = 0; index < viewModel.loadedAnnouncementList.length; index++)
                AnnouncementListItem(index: index),
              bottomCircular(ref),
            ],
          ),
        ),
      );
    });
  }
}
