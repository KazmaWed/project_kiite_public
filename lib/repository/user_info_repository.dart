import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserInfoRepository {
  Future<bool> adminCheck(User user) async {
    late final bool isAdmin;

    await FirebaseFirestore.instance.doc('admin/${user.uid}').get().then((value) {
      isAdmin = value['admin'] ?? false;
    }).catchError((e) {
      isAdmin = false;
    });

    return isAdmin;
  }

  Future<Map<String, Map<String, String>>> futureUserList() async {
    final output = <String, Map<String, String>>{};
    await FirebaseFirestore.instance.collection('user').get().then((value) {
      for (var user in value.docs) {
        final Map<String, String> body = {
          'nickname': user.data()['nickname'],
          'userName': user.data()['userName'] ?? '',
          'email': user.data()['email'],
        };
        output[user.id] = body;
      }
    });
    return output;
  }

  Future<String> userNameFromId(String userId) async {
    var output = userId;
    await FirebaseFirestore.instance.doc('user/$userId').get().then((value) {
      output = value.data()!['userName'];
    });
    return output;
  }
}
