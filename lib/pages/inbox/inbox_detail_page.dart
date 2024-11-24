// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freelance/components/input.dart';
import 'package:intl/intl.dart';

class InboxDetailPage extends StatefulWidget {
  const InboxDetailPage({
    super.key,
    required this.name,
    required this.role,
    required this.userId,
    required this.workerId,
  });

  final String name;
  final String role;
  final String userId;
  final String workerId;

  @override
  State<InboxDetailPage> createState() => _InboxDetailPageState();
}

class _InboxDetailPageState extends State<InboxDetailPage> {
  final controller = TextEditingController();

  DocumentSnapshot? inbox;

  Map get chat => {
        'from': widget.role,
        'message': controller.text,
        'timestamp': Timestamp.now(),
      };

  void newMessage() async {
    final data = {
      'chat': [chat],
      'last_chat': controller.text,
      'last_chat_time': Timestamp.now(),
      'user_id': widget.userId,
      'worker_id': widget.workerId,
    };
    FirebaseFirestore.instance.collection('chat').add(data);
  }

  void sendMessage() async {
    if (inbox == null) {
      newMessage();
    }

    final inboxData = inbox!.data() as Map;
    try {
      if (inboxData.containsKey('chat')) {
        inbox!.reference.update(
          {
            'chat': [...inbox!['chat'], chat],
            'last_chat': controller.text,
            'last_chat_time': Timestamp.now()
          },
        );
      } else {
        inbox!.reference.update(
          {
            'chat': [chat],
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
            Expanded(child: _buildChat()),
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

  Widget _buildChat() {
    return Column(
      children: [
        StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('chat')
              .where('user_id', isEqualTo: widget.userId)
              .where('worker_id', isEqualTo: widget.workerId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return SizedBox();
            }
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
