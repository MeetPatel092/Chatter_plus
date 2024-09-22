import 'dart:async';
import 'package:chatter_plus/helpers/local_helper.dart';
import 'package:chatter_plus/pages/chat_page.dart';
import 'package:chatter_plus/pages/sign_in_page.dart';
import 'package:chatter_plus/pages/sign_up_page.dart';
import 'package:chatter_plus/pages/splash_page.dart';
import 'package:chatter_plus/providers/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'pages/home_page.dart';

@pragma('vm:entry-point')
Future<void> BGFCM(RemoteMessage remoteMessage) async {
  await Firebase.initializeApp();

  LocalHelper.localHelper.showeSimpleNotification(
      title: remoteMessage.notification!.title!,
      body: remoteMessage.notification!.body!);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {
    LocalHelper.localHelper.showeSimpleNotification(
        title: remoteMessage.notification!.title!,
        body: remoteMessage.notification!.body!);
  });

  FirebaseMessaging.onBackgroundMessage(BGFCM);

  runApp(
    myApp(),
  );
}

class myApp extends StatefulWidget {
  const myApp({super.key});

  @override
  State<myApp> createState() => _myAppState();
}

class _myAppState extends State<myApp> {
  @override
  void initState() {
    super.initState();
    checkUser();
  }

  String page = "/";

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(useMaterial3: true),
        darkTheme: ThemeData(useMaterial3: true),
        initialRoute: page,
        routes: {
          '/': (context) => HomePage(),
          'splash_page': (context) => SplashPage(),
          'signIn_page': (context) => SignInPage(),
          'signUp_page': (context) => SignUpPage(),
          'chat_page': (context) => ChatPage(),
        },
      ),
    );
  }

  checkUser() async {
    FirebaseAuth.instance.currentUser != null
        ? page = "/"
        : page = "splash_page";
  }
}
