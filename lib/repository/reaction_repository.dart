import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReactionRepository {
  // いいねユーザーID配列
  Future<Set<String>> futureLikedBy(String dailyId) async {
    final Set<String> output = {};
    await FirebaseFirestore.instance.collection('reaction/$dailyId/likedBy').get().then((value) {
      for (var doc in value.docs) {
        output.add(doc.id);
      }
    });
    return output;
  }

  // いててユーザーID配列
  Future<Set<String>> futureEncouragedBy(String dailyId) async {
    final Set<String> output = {};
    await FirebaseFirestore.instance
        .collection('reaction/$dailyId/encouragedBy')
        .get()
        .then((value) {
      for (var doc in value.docs) {
        output.add(doc.id);
      }
    });
    return output;
  }

  // ぴかりユーザーID配列
  Future<Set<String>> futureInspired(String dailyId) async {
    final Set<String> output = {};
    await FirebaseFirestore.instance.collection('reaction/$dailyId/inspired').get().then((value) {
      for (var doc in value.docs) {
        output.add(doc.id);
      }
    });
    return output;
  }

  // いいね
  Future<void> like(String dailyId) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.doc('reaction/$dailyId/likedBy/$uid').set(
      {'reacted': DateTime.now().millisecondsSinceEpoch},
    );
  }

  Future<void> unlike(String dailyId) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.doc('reaction/$dailyId/likedBy/$uid').delete();
  }

  // いてて
  Future<void> encourage(String dailyId) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.doc('reaction/$dailyId/encouragedBy/$uid').set(
      {'reacted': DateTime.now().millisecondsSinceEpoch},
    );
  }

  Future<void> unEncourage(String dailyId) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.doc('reaction/$dailyId/encouragedBy/$uid').delete();
  }

  // ぴかり
  Future<void> inspired(String dailyId) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.doc('reaction/$dailyId/inspired/$uid').set(
      {'reacted': DateTime.now().millisecondsSinceEpoch},
    );
  }

  Future<void> unInspired(String dailyId) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.doc('reaction/$dailyId/inspired/$uid').delete();
  }
}
