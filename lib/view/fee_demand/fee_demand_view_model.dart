import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiite/model/kiite_snackbar.dart';
import 'package:kiite/model/transport_fee_model.dart';
import 'package:kiite/repository/transport_fee_repository.dart';
export 'package:kiite/view/fee_demand/fee_demand_screen.dart';
export 'package:kiite/view/fee_demand/fee_demand_view.dart';
export 'package:kiite/view/fee_demand/fee_demand_form_view.dart';
export 'package:kiite/view/fee_demand/fee_demand_history_list.dart';
export 'package:kiite/view/fee_demand/fee_demand_history_item.dart';
export 'package:kiite/provider/view_model_provider.dart';
export 'package:kiite/provider/firebase_provider.dart';
export 'package:kiite/provider/static_value_provider.dart';

class FeeDemandViewModel {
  FeeDemandViewModel(this.ref);

  final StateProviderRef ref;

  TransportFee? editingFee;
  User? user = FirebaseAuth.instance.currentUser;

  late DateTime datePicked;
  final fromTitleController = TextEditingController(text: '');
  final toTitleController = TextEditingController(text: '');
  final fromStationController = TextEditingController(text: '');
  final toStationController = TextEditingController(text: '');
  final priceController = TextEditingController(text: '');

  final focusNodeList = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
  ];

  final toTitleFocus = FocusNode();
  final toStationFocus = FocusNode();
  final fromTitleFocus = FocusNode();
  final fromStationFocus = FocusNode();

  void initialize() {
    datePicked = DateTime.now();
    fromTitleController.clear();
    toTitleController.clear();
    fromStationController.clear();
    toStationController.clear();
    priceController.clear();
  }

  TransportFee fee(DateTime used) {
    final output = TransportFee.fromMap({
      'userId': user!.uid,
      'posted': DateTime.now().millisecondsSinceEpoch,
      'used': datePicked.millisecondsSinceEpoch,
      'fromTitle': fromTitleController.text,
      'toTitle': toTitleController.text,
      'fromStation': fromStationController.text,
      'toStation': toStationController.text,
      'price': int.parse(priceController.text),
    });

    return output;
  }

  Future<void> add(BuildContext context) async {
    await TransportFeeRepository.addTransportFee(fee(DateTime.now())).then((succeed) {
      // スナックバー
      final snack = KiiteSnackBar(context);
      if (succeed) {
        snack.sent();
      } else {
        snack.sendFailed();
      }
    });
  }

  Future<void> update(TransportFee feeInput) async {
    await TransportFeeRepository.updateTransportFee(feeInput);
  }

  Future<void> delete(TransportFee feeInput) async {
    await TransportFeeRepository.deleteTransportFee(feeInput);
  }

  void unFocus() {
    for (var focus in focusNodeList) {
      if (focus.hasFocus) {
        focus.unfocus();
        break;
      }
    }
  }
}
