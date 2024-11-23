// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freelance/components/title.dart';
import 'package:intl/intl.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  QuerySnapshot<Map<String, dynamic>>? booking;
  DateTime dateSelected = DateTime.now();

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.collection('booking').get().then((value) {
      setState(() {
        booking = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (booking == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    final filter = booking!.docs
        .where((x) => x['date'] == Timestamp.fromDate(dateSelected))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("My Calendar"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                showDatePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                ).then((date) {
                  setState(() {
                    dateSelected = date!;
                  });
                });
              },
              child: Row(
                children: [
                  Text(
                    DateFormat('EEEE d MMM, yyyy').format(dateSelected),
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .copyWith(color: Colors.blueAccent),
                  ),
                  Spacer(),
                  Icon(
                    Icons.date_range_outlined,
                    color: Colors.blueAccent,
                  )
                ],
              ),
            ),
            SizedBox(height: 15),
            TitleMore(title: "Service Booking (${filter.length})"),
            if (filter.isEmpty)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/notes.png',
                      color: Theme.of(context).colorScheme.secondary,
                      width: 75,
                    ),
                    SizedBox(height: 20),
                    Text("You have no service booking"),
                    SizedBox(height: 5),
                    Text("You don't have service booking on this time"),
                  ],
                ),
              ),
            SingleChildScrollView(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filter.length,
                itemBuilder: (context, index) {
                  // final data = filter[index];
                  // DocumentReference worker = data['worker'];
                  return Text('');
                  // return CardWorker(worker: worker, bookingData: data);
                  // CardWorker(data: worker, ),
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
