// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freelance/model/user.dart';
import 'package:freelance/pages/inbox/inbox_detail_page.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserModel>(context).user;
    return Scaffold(
      appBar: AppBar(
        title: Text("Inbox"),
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final role = snapshot.data!['role'];
          return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('chat')
                .where(
                  role == 'user' ? 'user_id' : 'worker_id',
                  isEqualTo: snapshot.data!.id,
                )
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final data = snapshot.data!.docs[index];
                  final uid =
                      role == 'user' ? data['worker_id'] : data['user_id'];
                  return _card(context, uid, data, role);
                },
              );
            },
          );
        },
      ),
    );
  }

  FutureBuilder _card(
    BuildContext context,
    String uid,
    DocumentSnapshot chat,
    String role,
  ) {
    return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
        builder: (context, snapshot) {
          // if (!snapshot.hasData) {
          //   return Center(child: CircularProgressIndicator());
          // }
          return Skeletonizer(
            enabled: !snapshot.hasData,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InboxDetailPage(
                      name: snapshot.data?['name'] ?? 'username',
                      data: chat,
                      role: role,
                    ),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.all(15),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.grey[900],
                        image: DecorationImage(
                          image:
                              NetworkImage(snapshot.data?['photo_url'] ?? ''),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                snapshot.data?['name'] ?? 'username',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              Spacer(),
                              // Badge(label: Text('4'))
                            ],
                          ),
                          SizedBox(height: 3),
                          Row(
                            children: [
                              Text(
                                chat['last_chat'],
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              Spacer(),
                              Text(
                                '10:34',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
