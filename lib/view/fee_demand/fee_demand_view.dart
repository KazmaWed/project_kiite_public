import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiite/model/kiite_Threshold.dart';
import 'package:kiite/view/fee_demand/fee_demand_view_model.dart';

class FeeDemandView extends ConsumerWidget {
  const FeeDemandView({Key? key, required this.callback}) : super(key: key);
  final Function callback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      alignment: Alignment.topCenter,
      child: RefreshIndicator(
        onRefresh: () => callback(),
        child: GestureDetector(
          child: [
            if (KiiteThreshold.isMobile(context) || KiiteThreshold.isTablet(context))
              mobileMode(ref),
            if (KiiteThreshold.isPC(context)) pcMode(ref),
          ].first,
          onTap: () => {_onBlankSpaceTap(ref)},
        ),
      ),
    );
  }

  Widget mobileMode(WidgetRef ref) {
    final controller = ScrollController();
    controller.addListener(() {
      ref.read(feeDemandViewModelProvider).unFocus();
    });

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: KiiteThreshold.mobile),
      child: SingleChildScrollView(
        controller: controller,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: const [
            FeeDemandFormView(),
            SizedBox(width: 12, height: 12),
            FeeDemandHistoryList(),
          ],
        ),
      ),
    );
  }

  Widget pcMode(WidgetRef ref) {
    final controller = ScrollController();
    controller.addListener(() {
      ref.read(feeDemandViewModelProvider).unFocus();
    });

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: KiiteThreshold.tablet),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(12, 12, 0, 12),
              child: FeeDemandFormView(),
            ),
          ),
          const SizedBox(width: 12, height: 12),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
              controller: controller,
              child: const FeeDemandHistoryList(),
            ),
          ),
        ],
      ),
    );
  }

  void _onBlankSpaceTap(WidgetRef ref) {
    final viewModel = ref.watch(feeDemandViewModelProvider);
    for (var index = 0; index < 5; index++) {
      if (viewModel.focusNodeList[index].hasFocus) {
        viewModel.focusNodeList[index].unfocus();
        break;
      }
    }
  }

  // Future<void> _onRefresh(WidgetRef ref) async {
  //   final repository = ref.watch(transportFeeRepository);
  //   final viewModel = ref.watch(feeDemandViewModelProvider);
  //   viewModel.feeHistoryList
  //   ref.read(futureFeeHistoryList.state).state = repository!.getList();
  // }
}
