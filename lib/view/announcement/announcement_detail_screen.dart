import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiite/model/announcement_model.dart';
import 'package:kiite/model/kiite_Threshold.dart';
import 'package:kiite/provider/firebase_provider.dart';
import 'package:kiite/view/announcement/announcement_detail_view.dart';

class AnnouncementDetailScreen extends StatefulWidget {
  const AnnouncementDetailScreen({Key? key, required this.index}) : super(key: key);
  final int index;

  @override
  State<AnnouncementDetailScreen> createState() => _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState extends State<AnnouncementDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: KiiteThreshold.maxWidth),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('おしらせ詳細'),
          ),
          body: Container(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: KiiteThreshold.tablet),
              child: FutureBuilder(
                  future: ref.watch(futureAnnouncementProvider),
                  builder: (context, AsyncSnapshot<Announcement> snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (!snapshot.hasData) {
                      return const Center(child: Text('取得できませんでした'));
                    } else if (snapshot.hasError) {
                      return Center(child: Text(snapshot.error.toString()));
                    } else {
                      return AnnouncementDetailView(index: widget.index);
                    }
                  }),
            ),
          ),
        ),
      );
    });
  }
}
