// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freelance/pages/booking/booking_list.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  QuerySnapshot<Map<String, dynamic>>? booking;

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('booking')
        .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then(
      (value) {
        setState(() => (booking = value));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Booking"),
          bottom: TabBar(
            dividerColor: Colors.transparent,
            indicatorColor: Colors.blueAccent,
            labelPadding: EdgeInsets.all(15),
            unselectedLabelColor: Colors.grey,
            tabs: [
              Text('Menunggu'),
              Text('Selesai'),
              Text('Batal'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            BookingList(booking: booking, status: 'menunggu'),
            BookingList(booking: booking, status: 'selesai'),
            BookingList(booking: booking, status: 'batal'),
          ],
        ),
      ),
    );
  }
}
