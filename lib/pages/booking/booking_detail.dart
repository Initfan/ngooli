// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:freelance/components/input.dart';
import 'package:freelance/utils/currency.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';
import 'package:http/http.dart' as http;
import 'package:freelance/utils/midtrans.dart';

class BookingDetail extends StatefulWidget {
  const BookingDetail({
    super.key,
    required this.totalPrice,
    required this.bookingId,
  });

  final int totalPrice;
  final String bookingId;

  @override
  State<BookingDetail> createState() => _BookingDetailState();
}

class _BookingDetailState extends State<BookingDetail> {
  bool _loading = false;
  MidtransSDK? _midtrans;
  int currentQuantity = 0;
  TimeOfDay? time;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_midtrans == null) {
      initializeMidtrans(context);
    }
  }

  @override
  void dispose() {
    _midtrans?.removeTransactionFinishedCallback();
    super.dispose();
  }

  Future bookingPayment() async {
    try {
      setState(() => _loading = !_loading);
      // final data = {
      //   'date': date,
      //   'address': {
      //     'longitude': position?.longitude,
      //     'latitude': position?.latitude,
      //   },
      // };

      // await FirebaseFirestore.instance
      //     .collection('booking')
      //     .doc(widget.bookingId)
      //     .update(data);

      final key = dotenv.env['MIDTRANS_SERVER_KEY']!;
      final res = await http.post(
        Uri.parse("https://app.sandbox.midtrans.com/snap/v1/transactions"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic ${base64Encode(utf8.encode(key))}:',
        },
        body: jsonEncode(
          {
            "transaction_details": {
              "order_id": widget.bookingId,
              "gross_amount": widget.totalPrice + (widget.totalPrice * 0.05),
            },
            "credit_card": {"secure": true},
            "customer_details": {
              "first_name": "budi",
              "last_name": "pratama",
              "email": "budi.pra@example.com",
              "phone": "08111222333"
            },
          },
        ),
      );
      setState(() => _loading = !_loading);
      final token = jsonDecode(res.body)['token'];
      _midtrans!.startPaymentUiFlow(token: token);
    } catch (e) {
      setState(() => _loading = !_loading);
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back),
        ),
        title: Text("Booking Details"),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Expanded(
              child: Text(currency.format(
                widget.totalPrice + (widget.totalPrice * 0.05),
              )),
            ),
            SizedBox(width: 15),
            ElevatedButton(
              onPressed: () {
                bookingPayment();
              },
              child: Text(_loading ? 'Loading...' : 'Bayar'),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih tanggal',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            CalendarDatePicker(
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2050),
              onDateChanged: (_) {},
            ),
            _buildWorkingStart(context),
            SizedBox(height: 20),
            _buildWorkingTime(context),
            SizedBox(height: 20),
            Input(hintText: 'Kode Promo'),
          ],
        ),
      ),
    );
  }

  Row _buildWorkingTime(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            "Jam Kerja",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        Row(
          children: [
            buttonValue(currentQuantity, 'remove', null),
            SizedBox(width: 10),
            Text("$currentQuantity"),
            SizedBox(width: 10),
            buttonValue(currentQuantity, 'add', null),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkingStart(BuildContext context) {
    return Builder(builder: (context) {
      return Row(
        children: [
          Expanded(
            child: Text(
              "Jam Mulai",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          GestureDetector(
            onTap: () => showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            ).then((value) => setState(() => time = value)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.grey[100]
                        : Colors.grey[900],
                  ),
                  child: Center(
                    child: Text("10"),
                  ),
                ),
                SizedBox(width: 5),
                Text(':'),
                SizedBox(width: 5),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.grey[100]
                        : Colors.grey[900],
                  ),
                  child: Center(
                    child: Text("10"),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  GestureDetector buttonValue(
    int currentQuantity,
    String action,
    BorderRadius? radius,
  ) {
    return GestureDetector(
      onTap: () {
        if (action == 'remove') {
          if (currentQuantity > 0) {
            setState(() => currentQuantity += 1);
          }
        } else {
          setState(() => currentQuantity -= 1);
        }
      },
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: radius ?? BorderRadius.circular(25),
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.grey[100]
              : Colors.grey[900],
        ),
        child: Icon(action == 'add' ? Icons.add : Icons.remove),
      ),
    );
  }
}
