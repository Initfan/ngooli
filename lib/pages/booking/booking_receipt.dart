// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ngooli/pages/home/home_page.dart';
import 'package:ngooli/pages/home/home_user.dart';
import 'package:ngooli/utils/currency.dart';
import 'package:ngooli/utils/route.dart';
import 'package:intl/intl.dart';

class BookingReceipt extends StatelessWidget {
  const BookingReceipt({
    super.key,
    required this.worker,
    required this.booking,
  });

  final DocumentSnapshot worker;
  final DocumentSnapshot booking;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pushReplacement(
            context,
            materialRoute(
              HomeUser(selected: 1),
            ),
          ),
          child: Icon(Icons.arrow_back),
        ),
        title: Text('E-Receipt'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            _summaryCard(context, _summaryList()),
            _summaryCard(
              context,
              Column(
                children: [
                  Row(
                    children: [
                      Text("${worker['service']} Details"),
                      Spacer(),
                      Icon(Icons.arrow_drop_down),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: booking['service'].length,
                      itemBuilder: (context, index) {
                        final data = booking['service'][index];
                        return _summaryItem(
                          "${data['quantity']}x ${data['name']}",
                          currency.format(data['price']),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            _summaryCard(
              context,
              Column(
                children: [
                  _summaryItem(
                    "Total",
                    currency.format(
                      booking['price'] + (booking['price'] * 0.05),
                    ),
                  ),
                  _summaryItem(
                    "Promo",
                    '-',
                  ),
                  _summaryItem(
                    "Metode pembayaran",
                    booking['payment_method'],
                  ),
                  _summaryItem(
                    "Tanggal",
                    DateFormat('MMM dd, yyyy | H:mm:ss').format(
                      booking['payment_date'].toDate(),
                    ),
                  ),
                  _summaryItem(
                    "Transaction ID",
                    booking.id,
                  ),
                  _summaryItem(
                    "Status",
                    booking['payment_status'],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Container _summaryCard(BuildContext context, Widget child) {
    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.grey[100]
            : Colors.grey[900],
      ),
      child: child,
    );
  }

  Column _summaryList() => Column(
        children: [
          _summaryItem('Layanan', worker['service']),
          _summaryItem('Kategori', worker['service_category']),
          _summaryItem('Pekerja', worker['name']),
          _summaryItem(
            'Tanggal & Jam',
            "${DateFormat('MM dd, yyyy').format(booking['date'].toDate())} | ${booking['working_hour']}",
          ),
          _summaryItem('Jam Kerja', "${booking['working_hour']} Jam"),
        ],
      );

  Widget _summaryItem(String title, item) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(title),
          Spacer(),
          Text(
            item,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
