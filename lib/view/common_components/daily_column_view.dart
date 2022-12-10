import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiite/model/daily_model.dart';
import 'package:kiite/provider/firebase_provider.dart';
import 'package:kiite/provider/static_value_provider.dart';
import 'package:kiite/provider/view_model_provider.dart';
import 'package:kiite/view/common_components/daily_column_view_components.dart';
import 'package:kiite/view/daily_detail/daily_detail_card.dart';
import 'package:kiite/view/daily_detail/daily_detail_comment_list.dart';
import 'package:kiite/view/daily_detail/daily_detail_photo_view.dart';
import 'package:kiite/view/setting/setting_screen.dart';

class DailyColumnView extends StatefulWidget {
  const DailyColumnView({Key? key, required this.dailyId, required this.callback})
      : super(key: key);
  final String? dailyId;
  final Function callback;

  @override
  State<DailyColumnView> createState() => _DailyColumnViewState();
}

class _DailyColumnViewState extends State<DailyColumnView> {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final viewModel = ref.watch(dailyDetailViewModelProvider);
      viewModel.callback = widget.callback;

      if (widget.dailyId == '') {
        return Container(
          padding: const EdgeInsets.all(12),
          child: SettingViewButtons(ref: ref),
        );
      } else {
        final repository = ref.watch(dailyRepositoryProvider)!;
        final futureDaily = repository.futureDailyById(widget.dailyId!);

        return FutureBuilder(
            future: futureDaily,
            builder: (context, AsyncSnapshot<Daily> snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: Card(child: Center(child: CircularProgressIndicator())),
                );
              } else if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: Center(child: Text(snapshot.error.toString())),
                );
              } else if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(child: Text('データなし')),
                );
              } else {
                final daily = snapshot.data!;

                return Scaffold(
                  body: Container(
                    alignment: Alignment.topCenter,
                    child: SingleChildScrollView(
                      controller: viewModel.scrollController,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          DailyColumnTitleView(daily: daily),
                          DairyCard(daily: daily),
                          const DailyPhotoView(),
                          DailyCommentCard(daily: daily),
                          const SizedBox(height: 72),
                          SizedBox(height: iosWebSafeAreaInset),
                        ],
                      ),
                    ),
                  ),
                  floatingActionButton: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ReactionButtonRow(ref: ref, dailyId: widget.dailyId!),
                          MessageButton(ref: ref),
                        ],
                      ),
                      SizedBox(height: iosWebSafeAreaInset),
                    ],
                  ),
                );
              }
            });
      }
    });
  }
}
