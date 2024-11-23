// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Event extends StatefulWidget {
  const Event({super.key});

  @override
  State<Event> createState() => _EventState();
}

class _EventState extends State<Event> {
  List<QueryDocumentSnapshot> events = [];

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('events')
        .limit(5)
        .get()
        .then((value) {
      setState(() {
        events = value.docs;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: events.isEmpty,
      child: SizedBox(
        height: 200,
        width: double.maxFinite,
        child: PageView.builder(
          controller: PageController(viewportFraction: 0.9),
          scrollDirection: Axis.horizontal,
          itemCount: events.length,
          itemBuilder: (context, index) {
            final data = events[index];
            return Container(
              width: 400,
              margin: EdgeInsets.only(right: index != 2 ? 15 : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                  image: NetworkImage(data['image']),
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
