// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:freelance/components/input.dart';
import 'package:freelance/components/profile_image.dart';
import 'package:freelance/pages/auth_page.dart';
import 'package:freelance/pages/authenticated.dart';
import 'package:freelance/pages/auth/login.dart';
import 'package:freelance/utils/google_drive.dart';
import 'package:freelance/utils/route.dart';
import 'package:image_picker/image_picker.dart';

class SignupWorker extends StatefulWidget {
  const SignupWorker({super.key});

  @override
  State<SignupWorker> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupWorker> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  String? selectedService;
  XFile? _image;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final service = TextEditingController();

  Future<XFile?> selectImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() => (_imageFile = File(image!.path), _image = image));
    return image;
  }

  Future<UserCredential> signupUser() async {
    final userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email.text,
      password: password.text,
    );
    userCredential.user!.updateProfile(displayName: name.text);
    return userCredential;
  }

  Future<void> createUser(String userId, String photoUrl) async {
    FirebaseFirestore.instance.collection('users').doc(userId).set({
      "role": "worker",
      "photo_url": photoUrl,
    });
  }

  Future<void> createWorker(XFile file) async {
    final userCredential = await signupUser();
    final fileLink = await uploadImageToGoogleDrive(file);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .set({
      "name": name.text,
      "email": email.text,
      "role": "worker",
      "photo_url": fileLink,
    });

    await FirebaseFirestore.instance.collection('worker').add({
      'name': name.text,
      'user_id': userCredential.user!.uid,
      'photo_url': fileLink,
      'service': service.text,
      'service_category': selectedService,
      'balance': 0,
    });
  }

  void signup(BuildContext context) async {
    try {
      setState(() => _loading = !_loading);
      await createWorker(_image!);
      setState(() => _loading = !_loading);
      Navigator.pushReplacement(
        context,
        materialRoute(Authenticated()),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    ValidationBuilder.setLocale('id');
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
                "Daftar sebagai \nTukang",
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
                controller: name,
                validation: ValidationBuilder().minLength(3),
                hintText: "Nama",
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
                validation: ValidationBuilder().minLength(6),
                hintText: "Password",
                secureText: true,
                icon: Icon(Icons.lock_outline),
              ),
              SizedBox(height: 10),
              Text('Pilih kategori layanan'),
              SizedBox(height: 10),
              services(),
              SizedBox(height: 10),
              Text('Nama layanan'),
              SizedBox(height: 10),
              Input(
                controller: service,
                validation: ValidationBuilder().minLength(6),
                hintText: "Contoh: Perbaikan elektronik",
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () => _loading ? null : signup(context),
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
                          text: 'Login',
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

  SizedBox services() {
    return SizedBox(
      height: 40,
      child: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('services').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final data = snapshot.data!.docs[index];
                return GestureDetector(
                  onTap: () => setState(() => selectedService = data['title']),
                  child: Container(
                    margin: EdgeInsets.only(
                      right: 10,
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: data['title'] == selectedService
                            ? Colors.blueAccent
                            : null,
                        border: Border.all(
                          color: Colors.blueAccent,
                          // width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(data['title']),
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return Text('');
        },
      ),
    );
  }
}
