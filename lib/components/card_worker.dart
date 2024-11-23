// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freelance/components/bookmark.dart';
import 'package:freelance/model/worker.dart';
import 'package:freelance/utils/currency.dart';

class CardWorker extends StatelessWidget {
  const CardWorker({
    super.key,
    this.onTapBookmark,
    required this.data,
  });

  final DocumentSnapshot data;
  final void Function(QueryDocumentSnapshot worker)? onTapBookmark;

  @override
  Widget build(BuildContext context) {
    final Worker _data = Worker.fromJson(data.data() as Map<String, dynamic>);

    return Container(
      width: double.maxFinite,
      height: 150,
      // margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.symmetric(vertical: 15),
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(15),
      //   color: Theme.of(context).brightness == Brightness.dark
      //       ? Colors.grey[900]
      //       : Colors.grey[100],
      // ),
      child: Row(
        children: [
          Container(
            width: MediaQuery.sizeOf(context).width * 0.3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(
                image: NetworkImage(data['photo_url']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _data.name!,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      _data.service!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      currency.format(_data.priceMinimum),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.yellow,
                        ),
                        SizedBox(width: 3),
                        Text(
                          "${_data.ratingTotal ?? 0}",
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        SizedBox(width: 10),
                        Text(
                          '${_data.reviewTotal ?? 0} Reviews',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ),
                Bookmark(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
