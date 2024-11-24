// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ngooli/model/user.dart';
import 'package:ngooli/pages/auth_page.dart';
import 'package:ngooli/pages/landing_page.dart';
import 'package:ngooli/utils/route.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Authenticated extends StatefulWidget {
  const Authenticated({super.key});

  @override
  State<Authenticated> createState() => _AuthenticatedState();
}

class _AuthenticatedState extends State<Authenticated> {
  User? _user;

  Future<bool> redirectToLanding() async {
    final prefs = await SharedPreferences.getInstance();
    final doneLanding = prefs.getBool('doneLanding') ?? false;
    if (doneLanding) {
      return true;
    }
    prefs.setBool('doneLanding', true);
    return false;
  }

  Future checkAuthorize() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      final passLanding = await redirectToLanding();
      if (passLanding) {
        return Navigator.pushReplacementNamed(context, '/auth');
      }
      return Navigator.pushReplacement(context, materialRoute(LandingPage()));
    }

    setState(() => _user = currentUser);
    final user = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    if (user.exists &&
        user.data() != null &&
        user.data()!.containsKey('role')) {
      if (user['role'] == 'worker') {
        return Navigator.pushReplacementNamed(context, '/home/worker');
      }
      return Navigator.pushReplacementNamed(context, '/home/user');
    }
    return AuthPage();
  }

  @override
  void initState() {
    super.initState();
    checkAuthorize();
  }

  @override
  Widget build(BuildContext context) {
    if (_user != null) {
      Provider.of<UserModel>(context).currentUser(_user!);
    }

    return SizedBox();
  }
}
