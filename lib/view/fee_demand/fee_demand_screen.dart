import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiite/model/kiite_icons.dart';
import 'package:kiite/model/kiite_Threshold.dart';
import 'package:kiite/provider/confirm_tab_close_stream.dart';
import 'package:kiite/view/fee_demand/fee_demand_view.dart';
import 'package:kiite/view/fee_demand/fee_demand_info.dart';

class FeeDemandScreen extends StatefulWidget {
  const FeeDemandScreen({Key? key}) : super(key: key);

  @override
  State<FeeDemandScreen> createState() => _FeeDemandScreenState();
}

class _FeeDemandScreenState extends State<FeeDemandScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (BuildContext context, WidgetRef ref, Widget? child) {
      // タブを閉じるときの確認
      ref.watch(confirmTabCloseStreamProvider);

      return Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: KiiteThreshold.maxWidth),
            child: Scaffold(
              appBar: AppBar(
                title: const Text('交通費請求'),
                actions: [
                  IconButton(
                    onPressed: () {
                      _onPress(context);
                    },
                    icon: Icon(KiiteIcons.info),
                  )
                ],
              ),
              body: FeeDemandView(callback: () => setState(() {})),
            ),
          ),
        ),
      );
    });
  }
}

void _onPress(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const FeeDemandInfoScreen(),
    ),
  );
}
