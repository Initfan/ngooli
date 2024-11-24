// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, no_leading_underscores_for_local_identifiers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ngooli/components/create_review.dart';
import 'package:ngooli/model/user.dart';
import 'package:ngooli/pages/booking/booking_receipt.dart';
import 'package:ngooli/pages/inbox/inbox_detail_page.dart';
import 'package:ngooli/utils/route.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BookingList extends StatelessWidget {
  const BookingList({
    super.key,
    this.booking,
    required this.status,
  });

  final String status;
  final QuerySnapshot<Map<String, dynamic>>? booking;

  @override
  Widget build(BuildContext context) {
    if (booking == null) {
      return Center(child: CircularProgressIndicator());
    }

    final filter = booking!.docs.where((x) => x['status'] == status).toList();
    if (filter.isEmpty) {
      return Center(child: Text('No data'));
    }

    return Padding(
      padding: const EdgeInsets.all(15),
      child: ListView.builder(
        itemCount: filter.length,
        itemBuilder: (context, index) {
          final bookingData = filter[index];
          final _data = bookingData.data();
          Timestamp date = bookingData['date'];
          DocumentReference worker = bookingData['worker'];
          return Container(
            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.grey[100]
                  : Colors.grey[900],
              borderRadius: BorderRadiusDirectional.circular(10),
            ),
            padding: EdgeInsets.symmetric(horizontal: 15).copyWith(
              bottom: 15,
            ),
            child: Column(
              children: [
                _bookingCard(worker, bookingData),
                Divider(height: 2),
                SizedBox(height: 15),
                _bookingInfo(date, bookingData, _data, worker),
              ],
            ),
          );
        },
      ),
    );
  }

  StreamBuilder<DocumentSnapshot<Object?>> _bookingCard(
    DocumentReference<Object?> worker,
    QueryDocumentSnapshot<Map<String, dynamic>> bookingData,
  ) {
    return StreamBuilder(
      stream: worker.snapshots(),
      builder: (context, snapshot) {
        final user = Provider.of<UserModel>(context).user!;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('');
        }

        return Column(
          children: [
            Container(
              width: double.maxFinite,
              height: 150,
              margin: EdgeInsets.symmetric(vertical: 5),
              padding: EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                // color: Colors.grey[900],
              ),
              child: Row(
                children: [
                  Container(
                    width: MediaQuery.sizeOf(context).width * 0.3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        image: NetworkImage(snapshot.data!['photo_url']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              snapshot.data!['service'],
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              snapshot.data!['name'],
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Container(
                              padding: EdgeInsetsDirectional.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(bookingData['status']),
                            ),
                          ],
                        ),
                        if (bookingData['payment_status'] == 'paid' &&
                            bookingData['status'] != 'selesai')
                          IconButton.filledTonal(
                            // onPressed: null,
                            onPressed: () => Navigator.push(
                              context,
                              materialRoute(
                                InboxDetailPage(
                                  name: snapshot.data!['name'],
                                  userId: user.uid,
                                  workerId: snapshot.data!['user_id'],
                                  role: 'user',
                                ),
                              ),
                            ),
                            icon: Icon(Icons.chat_outlined),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _bookingInfo(
    Timestamp date,
    QueryDocumentSnapshot<Map<String, dynamic>> bookingData,
    Map<String, dynamic> _data,
    DocumentReference<Object?> worker,
  ) {
    final workingHour = bookingData['working_hour'] +
        int.parse(bookingData['working_time'].toString().split(':')[0]);
    return Builder(builder: (context) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Tanggal"),
              Text.rich(
                TextSpan(
                  text: DateFormat('MMM d, yyyy | ').format(date.toDate()),
                  children: [
                    TextSpan(text: bookingData['working_time']),
                    TextSpan(text: ' - '),
                    TextSpan(
                      text: "${workingHour.toString()}:00",
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Text("Alamat"),
              Spacer(),
              Expanded(
                child: Text(
                  _data['address'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          if (_data['status'] == 'Completed') button('Detail', false),
          if (_data['payment_status'] == 'unpaid')
            button('Bayar pesanan', true),
          if (_data['payment_status'] == 'paid')
            GestureDetector(
                onTap: () async {
                  final _worker = await worker.get();
                  Navigator.push(
                    context,
                    materialRoute(
                        BookingReceipt(worker: _worker, booking: bookingData)),
                  );
                },
                child: button('Lihat resi', true)),
          if (_data.containsKey('reviewed') && !_data['reviewed'])
            CreateReview(
              worker: worker,
              booking: bookingData.reference,
            )
        ],
      );
    });
  }

  Container button(String text, bool solid) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: solid ? Colors.blueAccent : null,
        border: !solid ? Border.all(color: Colors.blueAccent) : null,
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: solid ? Colors.white : Colors.blueAccent,
          ),
        ),
      ),
    );
  }
}
