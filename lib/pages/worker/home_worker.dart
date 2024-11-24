// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ngooli/pages/inbox_page.dart';
import 'package:ngooli/pages/worker/home_worker_page.dart';
import 'package:ngooli/pages/worker/profile_worker.dart';
import 'package:ngooli/pages/worker/booking_worker.dart';

class HomeWorker extends StatefulWidget {
  HomeWorker({super.key, this.selected = 0});

  int selected;

  @override
  State<HomeWorker> createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeWorker> {
  DocumentSnapshot? worker;

  List<Widget> pages = [
    HomeWorkerPage(),
    BookingWorker(),
    InboxPage(role: 'worker'),
    ProfileWorker(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget.selected,
        backgroundColor: Colors.white,
        useLegacyColorScheme: false,
        fixedColor: Colors.blueAccent,
        onTap: (value) => setState(() => widget.selected = value),
        items: [
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.event_note),
            icon: Icon(Icons.event_note_outlined),
            label: 'Booking',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.chat),
            icon: Icon(Icons.chat_outlined),
            label: 'Inbox',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.person),
            icon: Icon(Icons.person_outlined),
            label: 'Profile',
          ),
        ],
      ),
      body: pages[widget.selected],
    );
  }
}
