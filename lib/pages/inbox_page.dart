// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freelance/model/user.dart';
import 'package:freelance/pages/inbox/inbox_detail_page.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key, required this.role});

  final String role;

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context).user!;
    return Scaffold(
      appBar: AppBar(
        title: Text("Inbox"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .where('user_id', isEqualTo: user.uid)
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
                  widget.role == 'user' ? data['worker_id'] : data['user_id'];
              return _card(user, data, uid);
            },
          );
        },
      ),
    );
  }

  Widget _card(
    User currentUser,
    DocumentSnapshot chat,
    String uid,
  ) {
    return StreamBuilder(
      stream:
          FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        return Skeletonizer(
          enabled: !snapshot.hasData,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => InboxDetailPage(
                    name: snapshot.data!['name'],
                    userId: currentUser.uid,
                    workerId: chat['worker_id'],
                    role: widget.role,
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
                        image: NetworkImage(snapshot.data?['photo_url'] ?? ''),
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
      },
    );
  }
}
