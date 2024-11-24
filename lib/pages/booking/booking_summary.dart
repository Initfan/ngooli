// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ngooli/components/button.dart';
import 'package:ngooli/model/user.dart';
import 'package:ngooli/pages/booking/booking_receipt.dart';
import 'package:ngooli/pages/home/home_user.dart';
import 'package:ngooli/utils/currency.dart';
import 'package:ngooli/utils/midtrans.dart';
import 'package:ngooli/utils/route.dart';
import 'package:intl/intl.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';
import 'package:provider/provider.dart';

class BookingSummary extends StatefulWidget {
  const BookingSummary({
    super.key,
    required this.worker,
    required this.booking,
  });

  final DocumentSnapshot worker;
  final DocumentSnapshot booking;

  @override
  State<BookingSummary> createState() => _BookingSummaryState();
}

class _BookingSummaryState extends State<BookingSummary> {
  bool _loading = false;
  MidtransSDK? _midtrans;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (_midtrans == null) {
      final midtrans = await initializeMidtrans(context);
      midtrans.setTransactionFinishedCallback((result) async {
        final data = {
          'payment_status': 'paid',
          'payment_method': result.paymentType,
          'payment_date': Timestamp.now(),
        };
        await widget.booking.reference.update(data);
        final booking = await widget.booking.reference.get();
        Navigator.pushReplacement(
          context,
          materialRoute(BookingReceipt(
            booking: booking,
            worker: widget.worker,
          )),
        );
      });
      setState(() => _midtrans = midtrans);
    }
  }

  @override
  void dispose() {
    _midtrans?.removeTransactionFinishedCallback();
    super.dispose();
  }

  void updateBooking() async {
    final summary = {
      'summary': {
        'service': widget.worker['service'],
        'service_category': widget.worker['service_category'],
        'worker': widget.worker['name'],
        'promo': '-',
      }
    };
    await widget.booking.reference.update(summary);
  }

  Future bookingPayment() async {
    final user = Provider.of<UserModel>(context, listen: false).user!;
    try {
      updateBooking();
      final token = await createTransaction(
        widget.booking.id,
        widget.booking['price'] + (widget.booking['price'] * 0.05),
        {
          'first_name': user.displayName,
          'email': user.email,
        },
      );
      _midtrans!.startPaymentUiFlow(token: token);
      setState(() => _loading = !_loading);
    } catch (e) {
      setState(() => _loading = !_loading);
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review Summary'),
      ),
      persistentFooterButtons: [
        Button(
          onTap: () => _loading ? null : bookingPayment(),
          child:
              Center(child: Text(_loading ? 'Loading...' : 'Bayar sekarang')),
        )
      ],
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
                      Text("${widget.worker['service']} Details"),
                      Spacer(),
                      Icon(Icons.arrow_drop_down),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.booking['service'].length,
                      itemBuilder: (context, index) {
                        final data = widget.booking['service'][index];
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
                    widget.worker['service'],
                    currency.format(widget.booking['price']),
                  ),
                  _summaryItem(
                    "Promo",
                    '-',
                  ),
                  _summaryItem(
                    "Administrasi",
                    '5%',
                  ),
                  Divider(),
                  _summaryItem(
                    "Total",
                    currency.format(
                      widget.booking['price'] +
                          (widget.booking['price'] * 0.05),
                    ),
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
          _summaryItem('Layanan', widget.worker['service']),
          _summaryItem('Kategori', widget.worker['service_category']),
          _summaryItem('Pekerja', widget.worker['name']),
          _summaryItem(
            'Tanggal & Jam',
            "${DateFormat('MM dd, yyyy').format(widget.booking['date'].toDate())} | ${widget.booking['working_hour']}",
          ),
          _summaryItem('Jam Kerja', "${widget.booking['working_hour']} Jam"),
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
