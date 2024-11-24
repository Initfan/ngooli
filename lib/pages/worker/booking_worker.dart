// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ngooli/model/user.dart';
import 'package:ngooli/pages/worker/booking_worker_list.dart';
import 'package:provider/provider.dart';

class BookingWorker extends StatefulWidget {
  const BookingWorker({super.key});

  @override
  State<BookingWorker> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingWorker> {
  QuerySnapshot<Map<String, dynamic>>? booking;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    final user = Provider.of<UserModel>(context, listen: false).user;
    final worker = await FirebaseFirestore.instance
        .collection('worker')
        .where('user_id', isEqualTo: user!.uid)
        .get();

    await FirebaseFirestore.instance
        .collection('booking')
        .where('worker', isEqualTo: worker.docs.first.reference)
        .get()
        .then(
      (value) {
        setState(() => booking = value);
        print(value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (booking == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
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
            BookingWorkerList(
              booking: booking,
              status: 'menunggu',
            ),
            BookingWorkerList(
              booking: booking,
              status: 'selesai',
            ),
            BookingWorkerList(
              booking: booking,
              status: 'batal',
            ),
          ],
        ),
      ),
    );
  }
}
