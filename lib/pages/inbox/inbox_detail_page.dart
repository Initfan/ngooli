// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freelance/components/input.dart';

class InboxDetailPage extends StatelessWidget {
  InboxDetailPage({
    super.key,
    required this.name,
    required this.data,
    required this.role,
  });

  final String name;
  final String role;
  final DocumentSnapshot data;

  final controller = TextEditingController();

  void sendMessage() async {
    if (controller.text.isEmpty) return;
    await data.reference.update({
      "chat": [
        ...data['chat'],
        {
          "from": role,
          "message": controller.text,
        }
      ]
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(name),
      ),
      body: SingleChildScrollView(
        reverse: true,
        padding: EdgeInsets.all(15),
        child: StreamBuilder(
          stream: data.reference.snapshots(),
          builder: (context, snapshot) {
            final _data = snapshot.data!.data() as Map;
            if (_data.containsKey('chat')) {
              return ListView.builder(
                shrinkWrap: true,
                reverse: true,
                itemCount: snapshot.data!['chat'].length,
                itemBuilder: (context, index) {
                  final chat = snapshot.data!['chat'][index];
                  return Column(
                    crossAxisAlignment: chat['from'] == role
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      chatBubble(context, chat),
                    ],
                  );
                },
              );
            }
            return Text('');
          },
        ),
      ),
    );
  }

  Container chatBubble(
    BuildContext context,
    Map chat,
  ) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.7,
      ),
      margin: EdgeInsets.only(top: 15),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: chat['from'] == role
            ? Colors.blueAccent.shade700
            : Colors.grey.shade900,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(chat['message']),
          Text(
            '10:01',
            style: Theme.of(context)
                .textTheme
                .labelSmall!
                .copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Container timeChat(BuildContext context) => Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          'Today',
          style: Theme.of(context)
              .textTheme
              .labelMedium!
              .copyWith(color: Colors.grey[600]),
        ),
      );
}
