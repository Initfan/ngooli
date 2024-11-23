// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:freelance/firebase_options.dart';
import 'package:freelance/model/user.dart';
import 'package:freelance/pages/auth_page.dart';
import 'package:freelance/pages/authenticated.dart';
import 'package:freelance/pages/home/home_user.dart';
import 'package:freelance/pages/worker/home_worker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // FirebaseAuth.instance.setPersistence(Persistence.LOCAL);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            // seedColor: Color(0xff0e5bc9),
            seedColor: Colors.blueAccent,
            brightness: Brightness.light,
          ),
          // useMaterial3: true,
          // brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            // seedColor: Color(0xff042c5f),
            seedColor: Colors.blueAccent.shade700,
            brightness: Brightness.dark,
          ),
          // useMaterial3: true,
          // brightness: Brightness.dark,
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => Authenticated(),
          '/home/user': (_) => HomeUser(),
          '/home/worker': (_) => HomeWorker(),
          '/auth': (_) => AuthPage(),
        },
      ),
    ),
  );
}
