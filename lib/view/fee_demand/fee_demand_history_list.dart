import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiite/model/transport_fee_model.dart';
import 'package:kiite/provider/firebase_provider.dart';
import 'package:kiite/view/fee_demand/fee_demand_history_item.dart';

class FeeDemandHistoryList extends StatefulWidget {
  const FeeDemandHistoryList({Key? key}) : super(key: key);

  @override
  FeeDemandHistoryListState createState() => FeeDemandHistoryListState();
}

class FeeDemandHistoryListState extends State<FeeDemandHistoryList> {
  var year = DateTime.now().toLocal().year;
  var month = DateTime.now().toLocal().month;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final repository = ref.watch(transportFeeRepository)!;
      final futureFeeDemandList = repository.getListByMonth(year, month);

      Widget monthSelector() {
        void prevMonth() {
          setState(() {
            if (month == 1) {
              year -= 1;
              month = 12;
            } else {
              month -= 1;
            }
          });
        }

        void nextMonth() {
          setState(() {
            if (month == 12) {
              year += 1;
              month = 1;
            } else {
              month += 1;
            }
          });
        }

        return Card(
          borderOnForeground: false,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    height: 32,
                    width: 42,
                    alignment: Alignment.center,
                    child: const Text('＜'),
                  ),
                  onTap: () => prevMonth(),
                ),
                const Spacer(),
                Text('$year年'),
                const SizedBox(width: 18),
                Text('$month月'),
                const Spacer(),
                InkWell(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    height: 32,
                    width: 42,
                    alignment: Alignment.center,
                    child: const Text('＞'),
                  ),
                  onTap: () => nextMonth(),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: const Text('請求履歴'),
          ),
          monthSelector(),
          FutureBuilder(
            future: futureFeeDemandList,
            builder: (BuildContext context, AsyncSnapshot<List<TransportFee>> snapshot) {
              // 通信中はスピナーを表示
              if (snapshot.connectionState != ConnectionState.done) {
                return Container(
                  height: 120,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                );
              }
              // エラー発生時はエラーメッセージを表示
              if (snapshot.hasError) {
                return Column(
                  children: [
                    const SizedBox(height: 12),
                    Text(snapshot.error.toString()),
                  ],
                );
              }
              // データがない時
              if (!snapshot.hasData) {
                return Container(
                  height: 48,
                  alignment: Alignment.center,
                  child: const Text('No data.'),
                );
              }

              // データ取得時
              final feeHistoryList = snapshot.data ?? <TransportFee>[];
              if (feeHistoryList.isEmpty) {
                return Container(
                  height: 48,
                  alignment: Alignment.center,
                  child: const Text('該当なし'),
                );
              } else {
                return Column(
                  children: [
                    for (var index = 0; index < feeHistoryList.length; index++)
                      FeeDemandHistoryItem(fee: feeHistoryList[index]),
                    const SizedBox(height: 18),
                  ],
                );
              }
            },
          ),
        ],
      );
    });
  }
}
