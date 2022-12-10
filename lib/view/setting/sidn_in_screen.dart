import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiite/model/kiite_colors.dart';
import 'package:kiite/model/kiite_Threshold.dart';
import 'package:kiite/provider/view_model_provider.dart';

class SignInScreen extends ConsumerWidget {
  SignInScreen({Key? key}) : super(key: key);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final changeThemeViewModel = ref.watch(changeThemeViewModelProvider);
    final emailFocusNode = FocusNode();
    final passwordFocusNode = FocusNode();

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: KiiteThreshold.maxWidth),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('サインイン'),
            ),
            body: Container(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: KiiteThreshold.mobile),
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          focusNode: emailFocusNode,
                          autofillHints: const [AutofillHints.email],
                          decoration: const InputDecoration(labelText: 'メールアドレス'),
                          keyboardType: TextInputType.emailAddress,
                          keyboardAppearance:
                              changeThemeViewModel.darkMode ? Brightness.dark : Brightness.light,
                          validator: (String? value) {
                            if (value?.isEmpty == true) {
                              return 'メールアドレスを入力してください';
                            } else {
                              return null;
                            }
                          },
                          onEditingComplete: () => passwordFocusNode.requestFocus(),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          focusNode: passwordFocusNode,
                          autofillHints: const [AutofillHints.password],
                          autocorrect: false,
                          enableInteractiveSelection: false,
                          decoration: const InputDecoration(labelText: 'パスワード'),
                          keyboardType: TextInputType.visiblePassword,
                          keyboardAppearance:
                              changeThemeViewModel.darkMode ? Brightness.dark : Brightness.light,
                          obscureText: true,
                          validator: (String? value) {
                            if (value?.isEmpty == true) {
                              return 'パスワードを入力してください';
                            } else {
                              return null;
                            }
                          },
                          onEditingComplete: () async => await _onSignIn(context),
                        ),
                        const SizedBox(height: 32),
                        // ボタン
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () async => await _onSignIn(context),
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Text('送信'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onSignIn(BuildContext context) async {
    try {
      if (_formKey.currentState?.validate() != true) {
        return;
      }
      showNetworkingCircular(context);

      // 入力値を取得
      final String email = _emailController.text;
      final String password = _passwordController.text;
      // ユーザーサインイン
      // await FirebaseAuth.instance
      //     .signInWithEmailAndPassword(email: email, password: password)
      //     .then((value) {
      //   Navigator.of(context).pop();
      // });
      await signin(email, password).then((value) {
        Navigator.of(context).pop();
      });
      // ユーザーインスタンス取得
      User user = FirebaseAuth.instance.currentUser!;

      // ニックネームがあるか取得
      late bool hasNickname;
      await FirebaseFirestore.instance.doc('user/${user.uid}').get().then((value) {
        hasNickname = value.data()?['nickname'] != null;
      });
      // ニックネームがなければ初期値を設定
      if (!hasNickname) {
        String? nickname = user.email?.split('@')[0];
        await FirebaseFirestore.instance.doc('user/${user.uid}').set({'nickname': nickname});
      }

      Map<String, String> userList = {};
      await FirebaseFirestore.instance.collection('user').get().then((value) {
        for (var element in value.docs) {
          userList[element.id] = element['nickname'];
        }
      });
    } catch (e) {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('サインイン出来ませんでした'),
            content: Text(e.toString()),
          );
        },
      ).then((value) => Navigator.of(context).pop());
    }
  }

  Future<User?> signin(String email, String password) async {
    User? output;
    final auth = FirebaseAuth.instance;
    await auth.signInWithEmailAndPassword(email: email, password: password).then((value) async {
      // final prefs = await SharedPreferences.getInstance();
      // await prefs.setString('idToken', await value.user!.getIdToken());
      // print(await value.user!.getIdToken());
      output = value.user;
    });
    return output;
  }
}
