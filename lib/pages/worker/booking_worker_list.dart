// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ngooli/model/user.dart';
import 'package:ngooli/pages/inbox/inbox_detail_page.dart';
import 'package:ngooli/pages/worker/booking_complete.dart';
import 'package:ngooli/utils/route.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BookingWorkerList extends StatelessWidget {
  const BookingWorkerList({
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
          Timestamp date = bookingData['date'];
          return Container(
            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.grey[100]
                  : Colors.grey[900],
              borderRadius: BorderRadiusDirectional.circular(10),
            ),
            padding: EdgeInsets.symmetric(horizontal: 15).copyWith(bottom: 15),
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(bookingData['user_id'])
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return SizedBox();
                  }

                  return Column(
                    children: [
                      cardBooking(bookingData, snapshot.data!),
                      Divider(height: 2),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Tanggal"),
                          Text(
                            DateFormat('EEEE d MMM, yyyy').format(
                              date.toDate(),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Text("Alamat"),
                          Spacer(),
                          Expanded(
                            child: Text(
                              snapshot.data!['address'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      if (bookingData['status'] == 'menunggu')
                        button(
                          'Selesai',
                          true,
                          BookingComplete(
                            data: bookingData,
                          ),
                        )
                    ],
                  );
                }),
          );
        },
      ),
    );
  }

  Widget cardBooking(DocumentSnapshot bookingData, DocumentSnapshot user) {
    return Builder(
      builder: (context) {
        final currentUser = Provider.of<UserModel>(context).user;
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
                        image: NetworkImage(user['photo_url']),
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
                              user['name'],
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              bookingData['payment_status'] == 'paid'
                                  ? 'Terbayar'
                                  : 'Belum dibayar',
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
                        if (bookingData['status'] == 'menunggu')
                          IconButton.filledTonal(
                            onPressed: () => Navigator.push(
                              context,
                              materialRoute(
                                InboxDetailPage(
                                  name: user['name'],
                                  userId: user.id,
                                  workerId: currentUser!.uid,
                                  role: 'worker',
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

  Builder button(String text, bool solid, Widget widget) {
    return Builder(builder: (context) {
      return GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => widget),
        ),
        child: Container(
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
        ),
      );
    });
  }
}
