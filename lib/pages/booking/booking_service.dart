// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freelance/pages/booking/booking_detail.dart';
import 'package:freelance/utils/route.dart';
import 'package:intl/intl.dart';

class BookingService extends StatefulWidget {
  const BookingService({super.key, required this.worker});

  final QueryDocumentSnapshot worker;

  @override
  State<BookingService> createState() => _BookingServiceState();
}

class _BookingServiceState extends State<BookingService> {
  bool _loading = false;
  int totalPrice = 0;
  Map<String, int> qty = {};
  List<QueryDocumentSnapshot>? services;
  List<Map<String, dynamic>> bookingData = [];

  final currency = NumberFormat.simpleCurrency(
    locale: 'id_ID',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    widget.worker.reference.collection('services').get().then(
          (query) => setState(() {
            services = query.docs;
            for (var service in services!) {
              qty[service.id] = 0;
            }
          }),
        );
  }

  Future<void> saveBooking() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    setState(() => _loading = !_loading);
    final data = await FirebaseFirestore.instance.collection('booking').add({
      'service': bookingData,
      'user_id': userId,
      'worker': widget.worker.reference,
      'status': 'menunggu',
      'payment_status': 'unpaid',
      'price': totalPrice,
    });

    final booking = await data.get();
    setState(() => _loading = !_loading);
    Navigator.push(
      context,
      materialRoute(BookingDetail(
        booking: booking,
        worker: widget.worker,
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (services == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back),
        ),
        title: Text("${widget.worker['service']}"),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Expanded(
              child: Text(currency.format(totalPrice)),
            ),
            SizedBox(width: 15),
            ElevatedButton(
              onPressed: saveBooking,
              child: Text(_loading ? 'Loading...' : 'Continue'),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: services!.length,
          itemBuilder: (context, index) {
            final data = services![index];
            int price = data['price'];
            int currentQuantity = qty[data.id] ?? 0;
            return Container(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${data['name']}",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          currency.format(data['price']),
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      buttonValue(currentQuantity, data, price, 'remove'),
                      SizedBox(width: 10),
                      Text("$currentQuantity"),
                      SizedBox(width: 10),
                      buttonValue(currentQuantity, data, price, 'add'),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  GestureDetector buttonValue(
    int currentQuantity,
    QueryDocumentSnapshot<Object?> data,
    int price,
    String action,
  ) {
    return GestureDetector(
      onTap: () {
        final exist = bookingData.where(
          (x) => x['name'] == data['name'],
        );

        if (action == 'remove') {
          if (currentQuantity > 0) {
            exist.first['quantity'] = currentQuantity - 1;

            setState(() {
              qty[data.id] = currentQuantity - 1;
              totalPrice -= price;
            });
          }
        } else {
          if (exist.isEmpty) {
            bookingData.add({
              'name': data['name'],
              'price': price,
              'quantity': 1,
            });
          } else {
            exist.first['quantity'] = currentQuantity + 1;
          }

          setState(() {
            qty[data.id] = currentQuantity + 1;
            totalPrice += price;
          });
        }
      },
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Colors.grey[800],
        ),
        child: Icon(action == 'add' ? Icons.add : Icons.remove),
      ),
    );
  }
}
