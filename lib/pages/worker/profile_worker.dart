// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freelance/components/profile_image.dart';
import 'package:freelance/model/user.dart';
import 'package:freelance/pages/auth_page.dart';
import 'package:freelance/pages/worker/profile_worker_update.dart';
import 'package:freelance/pages/worker/service.dart';
import 'package:freelance/utils/route.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class ProfileWorker extends StatelessWidget {
  const ProfileWorker({super.key});

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    Provider.of<UserModel>(context, listen: false).logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => AuthPage()),
    );
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
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final data = snapshot.data!;
          return FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('worker')
                .where('user_id', isEqualTo: data.id)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox();
              }
              final worker = snapshot.data!.docs.first;
              return Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    profileInfo(data, user, worker, context),
                    SizedBox(height: 20),
                    if (!worker['profile_completed'])
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          materialRoute(ProfileWorkerUpdate(worker: worker)),
                        ),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.redAccent,
                          ),
                          child: Center(
                            child: Text(
                                'Lengkapi profile untuk dapat menerima pesanan'),
                          ),
                        ),
                      ),
                    ListView(
                      shrinkWrap: true,
                      children: [
                        ListTile(
                          onTap: () => Navigator.push(
                            context,
                            materialRoute(MyService(worker: worker.reference)),
                          ),
                          leading: Icon(Icons.cleaning_services_outlined),
                          title: Text('Layanan ku'),
                        ),
                      ],
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
              );
            },
          );
        },
      ),
    );
  }

  Row profileInfo(
    DocumentSnapshot<Map<String, dynamic>> data,
    User user,
    QueryDocumentSnapshot<Map<String, dynamic>> worker,
    BuildContext context,
  ) {
    return Row(
      children: [
        ProfileImage(
          editable: false,
          image: data['photo_url'] != null
              ? NetworkImage(data['photo_url'])
              : null,
          user: user,
        ),
        SizedBox(width: 15),
        Expanded(
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['name'],
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    worker['service'],
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: Colors.grey),
                  ),
                ],
              ),
              Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).push(
                  materialRoute(
                    ProfileWorkerUpdate(worker: worker),
                  ),
                ),
                icon: Icon(Icons.settings),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
