// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freelance/components/button.dart';
import 'package:freelance/components/input.dart';
import 'package:freelance/model/user.dart';
import 'package:provider/provider.dart';

class CreateReview extends StatefulWidget {
  const CreateReview({
    super.key,
    required this.worker,
    required this.booking,
  });

  final DocumentReference worker;
  final DocumentReference booking;

  @override
  State<CreateReview> createState() => _CreateReviewState();
}

class _CreateReviewState extends State<CreateReview> {
  bool _loading = false;
  int starIndex = 0;
  TextEditingController review = TextEditingController();

  void saveReview(BuildContext context) async {
    try {
      final user = Provider.of<UserModel>(context, listen: false).user;
      setState(() => _loading = !_loading);
      await widget.worker.collection('reviews').add({
        'likes': 0,
        'rating': starIndex,
        'review': review.text,
        'timestamp': Timestamp.now(),
        'user_id': user!.uid,
      });
      await widget.booking.update({'reviewed': true});
      setState(() => _loading = !_loading);
    } catch (e) {
      setState(() => _loading = !_loading);
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 100,
      width: double.maxFinite,
      margin: EdgeInsets.symmetric(vertical: 20),
      // padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        // color: Colors.white,
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.grey[100]
            : Colors.grey[900],
        borderRadius: BorderRadiusDirectional.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ulasan',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.centerRight,
                  height: 16,
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => setState(() => starIndex = index),
                        child: Icon(
                          Icons.star,
                          color:
                              starIndex >= index ? Colors.yellow : Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Input(
            controller: review,
            hintText: 'Masukan kalimat...',
          ),
          SizedBox(height: 10),
          Button(
            onTap: () => saveReview(context),
            child: Center(
              child: Text(_loading ? 'Loading...' : 'Simpan'),
            ),
          ),
        ],
      ),
    );
  }
}
