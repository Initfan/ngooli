// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freelance/components/button.dart';
import 'package:freelance/model/user.dart';
import 'package:freelance/pages/auth/login.dart';
import 'package:freelance/pages/auth/signup.dart';
import 'package:freelance/pages/auth/signup_worker.dart';
import 'package:freelance/pages/authenticated.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  void createUser(BuildContext context) async {
    final signin = await signInWithGoogle();
    final registered = await FirebaseFirestore.instance
        .collection('users')
        .doc(signin.user!.uid)
        .get();

    if (!registered.exists) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(signin.user!.uid)
          .set({
        'email': signin.user!.email,
        'name': signin.user!.displayName,
        'photo_url': signin.user!.photoURL,
        'role': 'user',
      });
    }
    Provider.of<UserModel>(context, listen: false).currentUser(signin.user!);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => Authenticated()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  // borderRadius: BorderRadius.circular(200),
                  // color: Colors.grey[900],
                  image: DecorationImage(
                    image: AssetImage("assets/images/ngooli-maskot.png"),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Text(
                "Masuk ke Ngooli",
                style: Theme.of(context)
                    .textTheme
                    .displaySmall!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              Button(
                height: 50,
                padding: EdgeInsets.symmetric(horizontal: 15),
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[200],
                onTap: () => createUser(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/google-icon.svg',
                      height: 24,
                      width: 24,
                    ),
                    SizedBox(width: 15),
                    Text('Lanjut dengan Google'),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Divider(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[700]
                          : Colors.grey[100],
                    ),
                  ),
                  SizedBox(width: 10),
                  Text("atau"),
                  SizedBox(width: 10),
                  Expanded(
                    child: Divider(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[700]
                          : Colors.grey[100],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Button(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LoginPage()),
                ),
                child: Center(
                  child: Text('Masuk dengan password'),
                ),
              ),
              SizedBox(height: 10),
              Button(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SignupWorker()),
                ),
                child: Center(
                  child: Text('Daftar sebagai tukang'),
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SignupPage()),
                ),
                child: Text.rich(
                  TextSpan(
                    text: "Belum memiliki akun? ",
                    children: [
                      TextSpan(
                        text: 'Daftar',
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
