import 'package:kiite/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kiite/model/kiite_Threshold.dart';
import 'package:kiite/provider/static_value_provider.dart';
import 'package:kiite/view/main_screen.dart';
import 'package:kiite/view/setting/sidn_in_screen.dart';
import 'provider/view_model_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(context, ref) {
    var themeData = ref.watch(themeDataProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeData,
      home: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: KiiteThreshold.maxWidth),
            child: const ThemeLoadScreen(),
          ),
        ),
      ),
    );
  }
}

class ThemeLoadScreen extends ConsumerWidget {
  const ThemeLoadScreen({Key? key}) : super(key: key);

  @override
  Widget build(context, ref) {
    final future = ref.read(changeThemeViewModelProvider).loadTheme();

    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else {
          return const StartUpScreen();
        }
      },
    );
  }
}

class StartUpScreen extends ConsumerWidget {
  const StartUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStream = FirebaseAuth.instance.authStateChanges();

    return StreamBuilder(
      stream: userStream,
      builder: (context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const MainScreen();
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(snapshot.error.toString())),
          );
        } else {
          return SignInScreen();
        }
      },
    );
  }
}
