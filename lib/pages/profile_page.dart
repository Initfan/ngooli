// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ngooli/components/profile_image.dart';
import 'package:ngooli/model/user.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    Provider.of<UserModel>(context, listen: false).logout();
    Navigator.pushReplacementNamed(context, '/auth');
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context).user;
    if (user == null) {
      return SizedBox();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get(),
              builder: (context, snapshot) => snapshot.hasData
                  ? profileInfo(
                      user,
                      snapshot.data!,
                      context,
                    )
                  : SizedBox(),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(
                Icons.logout,
                color: Colors.redAccent,
              ),
              onTap: () => logout(context),
              title: Text(
                "Logout",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row profileInfo(
    User user,
    DocumentSnapshot data,
    BuildContext context,
  ) {
    return Row(
      children: [
        ProfileImage(
          image: NetworkImage(data['photo_url']),
          user: user,
        ),
        SizedBox(width: 20),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data['name'],
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Icon(Icons.settings_outlined),
            ],
          ),
        ),
      ],
    );
  }
}
