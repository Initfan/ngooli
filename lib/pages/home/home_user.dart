// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, must_be_immutable

import 'package:flutter/material.dart';
import 'package:freelance/pages/home/home_page.dart';
import 'package:freelance/pages/inbox_page.dart';
import 'package:freelance/pages/profile_page.dart';
import 'package:freelance/pages/booking_page.dart';
import 'package:freelance/pages/calendar_page.dart';

class HomeUser extends StatefulWidget {
  HomeUser({super.key, this.selected = 0});

  int selected;

  @override
  State<HomeUser> createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeUser> {
  List<Widget> pages = [
    HomePage(),
    BookingPage(),
    CalendarPage(),
    InboxPage(),
    ProfilePage()
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
            activeIcon: Icon(Icons.calendar_month),
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Calendar',
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
