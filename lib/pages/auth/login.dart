// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:form_validator/form_validator.dart';
import 'package:freelance/components/button.dart';
import 'package:freelance/components/input.dart';
import 'package:freelance/model/user.dart';
import 'package:freelance/pages/auth/forget_password.dart';
import 'package:freelance/pages/auth_page.dart';
import 'package:freelance/pages/authenticated.dart';
import 'package:freelance/pages/auth/signup.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController email = TextEditingController();

  final TextEditingController password = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool? _remember = false;

  Future<UserCredential> signInWithGoogle(BuildContext context) async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    final user = await FirebaseAuth.instance.signInWithCredential(credential);
    if (context.mounted) {
      Provider.of<UserModel>(context, listen: false).currentUser(user.user!);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Authenticated()),
      );
    }
    return user;
  }

  Future<void> signInPassword(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() => _loading = !_loading);
        final res = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.text,
          password: password.text,
        );
        setState(() => _loading = !_loading);
        Provider.of<UserModel>(context, listen: false).currentUser(res.user!);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Authenticated()),
        );
      } on FirebaseAuthException catch (e) {
        print(e);
        setState(() => _loading = !_loading);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Email atau password salah"),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
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
        child: Form(
          key: _formKey,
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
                "Masuk ke akunmu!",
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
              SizedBox(height: 10),
              Input(
                controller: password,
                secureText: true,
                hintText: "Password",
                icon: Icon(Icons.lock_outline),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: _remember,
                        onChanged: (value) {
                          setState(() => _remember = value);
                        },
                      ),
                      Text('Ingat saya'),
                    ],
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ForgetPassword()),
                    ),
                    child: Text(
                      'Lupa password?',
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Button(
                onTap: () => signInPassword(context),
                child: Center(
                  child: Text(_loading ? "Loading..." : "Sign In"),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  SizedBox(width: 20),
                  Text("or"),
                  SizedBox(width: 20),
                  Expanded(
                    child: Divider(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Button(
                height: 50,
                padding: EdgeInsets.symmetric(horizontal: 15),
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[200],
                onTap: () => signInWithGoogle(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
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
              SizedBox(height: 10),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SignupPage()),
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Text.rich(
                    TextSpan(
                      text: "Tidak memiliki akun? ",
                      children: [
                        TextSpan(
                          text: 'Sign up',
                          style: TextStyle(color: Colors.blueAccent),
                        ),
                      ],
                    ),
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
