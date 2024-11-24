// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, no_leading_underscores_for_local_identifiers

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:form_validator/form_validator.dart';
import 'package:ngooli/components/button.dart';
import 'package:ngooli/components/input.dart';
import 'package:ngooli/components/profile_image.dart';
import 'package:ngooli/model/user.dart';
import 'package:ngooli/pages/auth_page.dart';
import 'package:ngooli/pages/auth/login.dart';
import 'package:ngooli/pages/authenticated.dart';
import 'package:ngooli/utils/current_location.dart';
import 'package:ngooli/utils/google_drive.dart';
import 'package:ngooli/utils/route.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController username = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController address = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  XFile? _image;
  File? _imageFile;
  Placemark? placemark;
  bool _loadingAddress = false;
  bool _loading = false;

  String get userAddress =>
      "${placemark!.country} ${placemark!.administrativeArea} ${placemark!.subAdministrativeArea} ${placemark!.locality} ${placemark!.subLocality} ${placemark!.street} ${placemark!.postalCode}";

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
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => Authenticated()),
      );
    }
    return user;
  }

  Future<XFile?> selectImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = File(image!.path);
      _image = image;
    });
    return image;
  }

  Future<UserCredential> signupUser() async {
    final userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email.text,
      password: password.text,
    );
    userCredential.user!.updateProfile(displayName: username.text);
    return userCredential;
  }

  Future<void> createUser() async {
    setState(() => _loading = !_loading);
    final user = await signupUser();
    final fileLink = await uploadImageToGoogleDrive(_image!);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.user!.uid)
        .set({
      "name": username.text,
      "email": email.text,
      "role": "user",
      "photo_url": fileLink,
      "address": userAddress,
    });

    setState(() => _loading = !_loading);
    Navigator.pushReplacement(
      context,
      materialRoute(Authenticated()),
    );
  }

  void setAddressUser() async {
    setState(() => _loadingAddress = !_loadingAddress);
    final position = await getCurrentLocation();
    final _placemark = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    setState(() {
      placemark = _placemark.first;
      _loadingAddress = !_loadingAddress;
      address.text = userAddress;
    });
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Text(
                "Daftar ke \nNgooli",
                style: Theme.of(context)
                    .textTheme
                    .displaySmall!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40),
              Center(
                child: ProfileImage(
                  selectImage: selectImage,
                  image: _imageFile == null
                      ? AssetImage('assets/images/user-default.png')
                      : FileImage(_imageFile!) as ImageProvider,
                ),
              ),
              SizedBox(height: 20),
              Input(
                controller: username,
                validation: ValidationBuilder().minLength(3),
                hintText: "Username",
                icon: Icon(Icons.person_outline),
              ),
              SizedBox(height: 10),
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
                validation: ValidationBuilder().minLength(6),
              ),
              SizedBox(height: 10),
              Input(
                controller: address,
                hintText: "Alamat",
                icon: Icon(Icons.location_on_outlined),
                validation: ValidationBuilder(),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: _loadingAddress ? null : setAddressUser,
                child: Text(
                  _loadingAddress ? 'Loading...' : 'Gunakan lokasi terkini',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge!
                      .copyWith(color: Colors.blueAccent),
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () => _loading ? null : createUser(),
                child: Container(
                  height: 40,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.blueAccent,
                  ),
                  child: Center(
                    child: Text(_loading ? "Loading..." : "Daftar"),
                  ),
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
                  Text("atau"),
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
                  MaterialPageRoute(builder: (_) => LoginPage()),
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Text.rich(
                    TextSpan(
                      text: "Sudah memiliki akun? ",
                      children: [
                        TextSpan(
                          text: 'Sign in',
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
