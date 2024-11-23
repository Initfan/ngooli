// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freelance/components/button.dart';
import 'package:freelance/pages/worker/booking_worker.dart';
import 'package:freelance/utils/google_drive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class BookingComplete extends StatefulWidget {
  const BookingComplete({super.key, required this.data});

  final QueryDocumentSnapshot data;

  @override
  State<BookingComplete> createState() => _BookingCompleteState();
}

class _BookingCompleteState extends State<BookingComplete> {
  bool _loading = false;
  bool _limitImage = false;
  List<XFile>? imageList;
  ImagePicker picker = ImagePicker();
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

  void selectImage() async {
    final images = await picker.pickMultiImage(limit: 4);
    if (images.length >= 5) {
      return setState(() => _limitImage = !_limitImage);
    }
    setState(() => (imageList = images, _limitImage = false));
  }

  void completeBooking() async {
    try {
      setState(() => _loading = !_loading);
      final DocumentReference worker = widget.data['worker'];

      final getWorker = await worker.get();
      final workerData = getWorker.data() as Map<String, dynamic>;

      await worker.update({
        'balance': workerData.containsKey('balance')
            ? workerData['balance'] + widget.data['price']
            : widget.data['price'],
      });

      await FirebaseFirestore.instance
          .collection('booking')
          .doc(widget.data.id)
          .update({
        'status': 'Completed',
      });

      List<String> uploadedImage = [];
      if (imageList != null) {
        for (var image in imageList!) {
          final fileUploaded = await uploadImageToGoogleDrive(image);
          uploadedImage.add(fileUploaded!);
        }
      }

      await worker.collection('documentation').add({
        'user_id': widget.data['user_id'],
        'media': uploadedImage,
      });

      setState(() => _loading = !_loading);

      Navigator.pushReplacement(
        key.currentState!.context,
        MaterialPageRoute(builder: (_) => BookingWorker()),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.simpleCurrency(
      locale: 'id_ID',
      decimalDigits: 0,
    );

    return Scaffold(
      key: key,
      appBar: AppBar(
        title: Text('Selesaikan pesanan'),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(15),
        child: Button(
          onTap: completeBooking,
          child: Center(
            child: Text(_loading ? 'Loading...' : 'Selesai'),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            bookerInfo(widget.data, context),
            ListView.builder(
              shrinkWrap: true,
              itemCount: widget.data['service'].length,
              itemBuilder: (context, index) {
                final service = widget.data['service'][index];
                return ListTile(
                  contentPadding: EdgeInsets.all(0),
                  title: Text(service['name']),
                  subtitle: Text(
                    "${currency.format(service['price'])} x ${service['quantity']}",
                  ),
                  trailing: Text(
                    currency.format(service['price'] * service['quantity']),
                  ),
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dokumentasi',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  onPressed: _loading ? null : selectImage,
                  icon: Icon(Icons.add),
                ),
              ],
            ),
            SizedBox(height: 10),
            if (_limitImage)
              Text(
                'Tidak boleh lebih dari 4 gambar',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge!
                    .copyWith(color: Colors.redAccent),
              ),
            if (imageList != null)
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: imageList?.length,
                itemBuilder: (context, index) {
                  return Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: FileImage(
                          File(imageList![index].path),
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                  // return Image.file(File(imageList![index].path));
                },
              ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  StreamBuilder bookerInfo(DocumentSnapshot data, BuildContext context) {
    final currency = NumberFormat.simpleCurrency(
      locale: 'id_ID',
      decimalDigits: 0,
    );

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(data['user_id'])
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
                    child: Column(
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
                          data['payment_status'] == 'done'
                              ? 'Terbayar'
                              : 'Belum dibayar',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          'Total ${currency.format(data['price'])}',
                          style: Theme.of(context).textTheme.bodyLarge,
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
}
