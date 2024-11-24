// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freelance/components/input.dart';
import 'package:intl/intl.dart';

class InboxDetailPage extends StatefulWidget {
  InboxDetailPage({
    super.key,
    required this.name,
    required this.role,
    required this.uid,
  });

  final String name;
  final String role;
  final String uid;

  @override
  State<InboxDetailPage> createState() => _InboxDetailPageState();
}

class _InboxDetailPageState extends State<InboxDetailPage> {
  final controller = TextEditingController();

  DocumentSnapshot? inbox;
  String get id => widget.role == 'user' ? 'user_id' : 'worker_id';

  void sendMessage() async {
    final inboxData = inbox!.data() as Map;
    try {
      if (inboxData.containsKey('chat')) {
        inbox!.reference.update(
          {
            'chat': [
              ...inbox!['chat'],
              {
                'from': widget.role,
                'message': controller.text,
                'timestamp': Timestamp.now(),
              }
            ],
            'last_chat': controller.text,
            'last_chat_time': Timestamp.now()
          },
        );
      } else {
        inbox!.reference.update(
          {
            'chat': [
              {
                'from': widget.role,
                'message': controller.text,
                'timestamp': Timestamp.now(),
              }
            ],
            'last_chat': controller.text,
            'last_chat_time': Timestamp.now()
          },
        );
      }
    } catch (e) {
      print(e);
    }
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(child: chat(id)),
            Row(
              children: [
                Expanded(
                  child: Input(controller: controller),
                ),
                SizedBox(width: 15),
                IconButton.filledTonal(
                  onPressed: sendMessage,
                  icon: Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget chat(String id) {
    return Column(
      children: [
        StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('chat')
              .where(id, isEqualTo: widget.uid)
              .snapshots(),
          builder: (context, snapshot) {
            final data = snapshot.data!.docs.first;
            inbox = data;
            if (data.data().containsKey('chat')) {
              final dataLength = data['chat'].length;
              return ListView.builder(
                shrinkWrap: true,
                reverse: true,
                itemCount: dataLength,
                itemBuilder: (context, index) {
                  final chat = snapshot.data!.docs.first['chat']
                      [(dataLength - 1) - index];
                  return Column(
                    crossAxisAlignment: chat['from'] == widget.role
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [chatBubble(context, chat)],
                  );
                },
              );
            }
            return SizedBox();
          },
        ),
      ],
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
        color: chat['from'] == widget.role
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
            DateFormat('H:mm').format(chat['timestamp'].toDate()),
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
