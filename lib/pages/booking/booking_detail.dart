// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freelance/components/input.dart';
import 'package:freelance/model/user.dart';
import 'package:freelance/pages/home/home_user.dart';
import 'package:freelance/utils/currency.dart';
import 'package:freelance/utils/route.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';
import 'package:freelance/utils/midtrans.dart';
import 'package:provider/provider.dart';

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
  TimeOfDay time = TimeOfDay.now();
  DateTime date = DateTime.now();

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (_midtrans == null) {
      final midtrans = await initializeMidtrans(context);
      midtrans.setTransactionFinishedCallback((result) async {
        await FirebaseFirestore.instance
            .collection('booking')
            .doc(widget.bookingId)
            .update({
          'payment_status': 'done',
          'payment_type': result.paymentType,
          'status_message': result.statusMessage,
        });
        Navigator.pushReplacement(
          context,
          materialRoute(HomeUser(selected: 1)),
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

  Future bookingPayment() async {
    setState(() => _loading = !_loading);
    final currentUser = Provider.of<UserModel>(context, listen: false).user!;
    final user = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    final data = {
      'address': user.get('address') ?? '',
      'date': date,
      'working_hour': "${time.hour}:${time.minute == 0 ? '00' : time.minute}",
      'working_time': currentQuantity,
    };

    try {
      await FirebaseFirestore.instance
          .collection('booking')
          .doc(widget.bookingId)
          .update(data);

      final token = await createTransaction(
        widget.bookingId,
        widget.totalPrice + (widget.totalPrice * 0.05),
        {
          'first_name': currentUser.displayName,
          'email': currentUser.email,
        },
      );
      print(token);
      setState(() => _loading = !_loading);
      print(_midtrans);
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
      body: SingleChildScrollView(
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
              onDateChanged: (value) {
                setState(() => date = value);
              },
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
            buttonValue('remove', null),
            SizedBox(width: 10),
            Text("$currentQuantity"),
            SizedBox(width: 10),
            buttonValue('add', null),
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
            ).then((value) => setState(() => time = value!)),
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
                    child: Text(time.hour.toString()),
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
                    child: Text(time.minute.toString()),
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
    String action,
    BorderRadius? radius,
  ) {
    return GestureDetector(
      onTap: () {
        if (action == 'remove') {
          if (currentQuantity > 0) {
            setState(() => currentQuantity -= 1);
          }
        } else {
          setState(() => currentQuantity += 1);
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
