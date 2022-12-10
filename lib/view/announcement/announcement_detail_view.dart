import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiite/provider/view_model_provider.dart';
import 'package:kiite/view/announcement/announcement_detail_components.dart';

class AnnouncementDetailView extends StatefulWidget {
  const AnnouncementDetailView({Key? key, required this.index}) : super(key: key);
  final int index;

  @override
  State<AnnouncementDetailView> createState() => _AnnouncementDetailViewState();
}

class _AnnouncementDetailViewState extends State<AnnouncementDetailView> {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final viewModel = ref.watch(announcementListScreenViewModelProvider);
      final announcement = viewModel.loadedAnnouncementList[widget.index];

      return SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            AnnouncementDetailCard(index: widget.index),
            const SizedBox(height: 8),
            ReactionButton(
              announcement: announcement,
              callback: () => setState(() {}),
            ),
          ],
        ),
      );
    });
  }
}
