import 'package:chat_app/helper/cache_helper.dart';
import 'package:chat_app/screens/home_screen.dart';
import 'package:chat_app/screens/auth/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // CacheHelper.clear();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isSignedIn = false;
  @override
  void initState() {
    getUserLoggedIn;
    super.initState();
  }

  get getUserLoggedIn async {
    await CacheHelper.getUserLoggedIn().then((value) {
      if (value != null) {
        setState(() {
          isSignedIn = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

          primaryColor: const Color(0xFFee7b64),
          appBarTheme:
              AppBarTheme(backgroundColor: Theme.of(context).primaryColor),
          scaffoldBackgroundColor: Colors.white),
      home: isSignedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}
