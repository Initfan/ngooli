// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:ngooli/components/button.dart';
import 'package:ngooli/components/input.dart';
import 'package:ngooli/pages/auth_page.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _LoginPageState();
}

class _LoginPageState extends State<ForgetPassword> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  bool _loading = false;

  Future resetPassword() async {
    setState(() => _loading = !_loading);
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text);
    setState(() => _loading = !_loading);
  }

  @override
  Widget build(BuildContext context) {
    ValidationBuilder.setLocale('id');
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => AuthPage()),
          ),
          child: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/ngooli-maskot.png"),
                ),
              ),
            ),
            SizedBox(height: 40),
            Text(
              "Atur ulang password",
              style: Theme.of(context)
                  .textTheme
                  .displaySmall!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            Input(
              controller: email,
              validation: ValidationBuilder().email(),
              hintText: "Email",
              icon: Icon(Icons.email_outlined),
            ),
            SizedBox(height: 20),
            Button(
              onTap: resetPassword,
              child: Center(
                child: Text(_loading ? 'Loading...' : 'Kirim'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
