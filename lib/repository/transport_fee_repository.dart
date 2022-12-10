import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kiite/model/transport_fee_model.dart';

class TransportFeeRepository {
  final User user = FirebaseAuth.instance.currentUser!;

  Future<List<TransportFee>> getList() async {
    var output = <TransportFee>[];

    await FirebaseFirestore.instance
        .collection('fee')
        .where('userId', isEqualTo: user.uid)
        .get()
        .then((value) {
      for (var element in value.docs) {
        final transportFee = TransportFee.fromMap(element.data());
        transportFee.id = element.id;
        output.add(transportFee);
      }
    });

    output.sort((a, b) {
      return b.posted.millisecondsSinceEpoch - a.posted.millisecondsSinceEpoch;
    });

    return output;
  }

  Future<List<TransportFee>> getListByMonth(int year, int month) async {
    final output = <TransportFee>[];
    final thisMonth = DateTime.utc(year, month, 1, -9, 0, 0, 0, 0).millisecondsSinceEpoch;
    final nextMonth = DateTime.utc(year, month + 1, 1, -9, 0, 0, 0, 0).millisecondsSinceEpoch;

    await FirebaseFirestore.instance
        .collection('fee')
        .where('userId', isEqualTo: user.uid)
        .where('used', isGreaterThanOrEqualTo: thisMonth)
        .where('used', isLessThan: nextMonth)
        .get()
        .then((value) {
      for (var element in value.docs) {
        final transportFee = TransportFee.fromMap(element.data());
        transportFee.id = element.id;
        output.add(transportFee);
      }
    });

    output.sort((a, b) {
      return b.used.millisecondsSinceEpoch - a.used.millisecondsSinceEpoch;
    });

    return output;
  }

  static Future<bool> addTransportFee(TransportFee fee) async {
    bool succeed = true;
    await FirebaseFirestore.instance.collection('fee').add(fee.toFireMap()).catchError((e) {
      succeed = false;
    });
    return succeed;
  }

  static Future<void> updateTransportFee(TransportFee fee) async {
    await FirebaseFirestore.instance.collection('fee').doc(fee.id).update(fee.toFireMap());
  }

  static Future<void> deleteTransportFee(TransportFee fee) async {
    await FirebaseFirestore.instance.collection('fee').doc(fee.id).delete();
  }
}
