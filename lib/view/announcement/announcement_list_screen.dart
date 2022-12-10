import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiite/model/announcement_model.dart';
import 'package:kiite/model/kiite_Threshold.dart';
import 'package:kiite/view/announcement/announcement_edit_screen.dart';
import 'package:kiite/view/announcement/announcement_list_view.dart';
import 'package:kiite/view/fee_demand/fee_demand_view_model.dart';

class AnnouncementManageScreen extends StatefulWidget {
  const AnnouncementManageScreen({Key? key}) : super(key: key);

  @override
  State<AnnouncementManageScreen> createState() => _AnnouncementManageScreenState();
}

class _AnnouncementManageScreenState extends State<AnnouncementManageScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final viewModel = ref.watch(announcementListScreenViewModelProvider);

      // Future<void> newPost() async {
      //   viewModel.initForPost();
      //   ref.watch(futureAnnouncementProvider.state).state = Future.value(Announcement.newItem());

      //   await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      //     return const AnnouncementEditScreen();
      //   }));

      //   setState(() => viewModel.initList());
      // }

      Widget refreshButton() {
        return IconButton(
          onPressed: () {
            setState(() => viewModel.initList());
          },
          icon: const Icon(Icons.replay_rounded),
        );
      }

      return Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: KiiteThreshold.maxWidth),
            child: Scaffold(
              appBar: AppBar(
                title: const Text('おしらせ一覧'),
                actions: [refreshButton()],
              ),
              // floatingActionButton: FloatingActionButton(
              //   child: const Icon(Icons.edit),
              //   onPressed: () => newPost(),
              // ),
              body: FutureBuilder(
                  future: ref.watch(futureAnnouncementListProvider),
                  builder: (context, AsyncSnapshot<List<Announcement>> snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (!snapshot.hasData) {
                      return const Center(child: Text('No data.'));
                    } else if (snapshot.hasError) {
                      return Center(child: Text(snapshot.error.toString()));
                    } else {
                      viewModel.loadedAnnouncementList = snapshot.data!;
                      return const AnnouncementListView();
                    }
                  }),
            ),
          ),
        ),
      );
    });
  }
}
