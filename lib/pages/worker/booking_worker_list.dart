// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freelance/pages/worker/booking_complete.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

class BookingWorkerList extends StatelessWidget {
  const BookingWorkerList({
    super.key,
    this.booking,
    required this.status,
  });

  final String status;
  final QuerySnapshot<Map<String, dynamic>>? booking;

  Future<String> getAddress(double latitude, double longitude) async {
    List<Placemark> placemark = await placemarkFromCoordinates(
      latitude,
      longitude,
    );
    final location = placemark.first;

    return "${location.subLocality}";
  }

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
            child: Column(
              children: [
                cardBooking(bookingData),
                Divider(height: 2),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Tanggal"),
                    Text(DateFormat('EEEE d MMM, yyyy').format(date.toDate())),
                  ],
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Alamat"),
                    FutureBuilder<String>(
                      future: getAddress(
                        bookingData['address']['latitude'],
                        bookingData['address']['longitude'],
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text('');
                        }
                        return Text(snapshot.data!);
                      },
                    )
                  ],
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: button(
                        'Detail',
                        false,
                        Placeholder(),
                      ),
                    ),
                    SizedBox(width: 20),
                    if (bookingData['status'] == 'Upcoming')
                      Expanded(
                        child: button(
                          'Selesai',
                          true,
                          BookingComplete(
                            data: bookingData,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  StreamBuilder<DocumentSnapshot<Object?>> cardBooking(
    QueryDocumentSnapshot<Map<String, dynamic>> bookingData,
  ) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(bookingData['user_id'])
          .snapshots(),
      builder: (context, snapshot) {
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
                              snapshot.data!['name'],
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              // snapshot.data!['name'],
                              bookingData['payment_status'] == 'done'
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
                        IconButton.filled(
                          onPressed: null,
                          icon: Icon(Icons.chat_outlined),
                          // icon: SvgPicture.asset('assets/images/chat.svg'),
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
