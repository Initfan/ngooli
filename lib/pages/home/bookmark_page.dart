// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ngooli/components/card_worker.dart';
import 'package:ngooli/components/service.dart';
import 'package:ngooli/components/workers.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  int selected = 0;

  void _removeSheet(BuildContext context, QueryDocumentSnapshot worker) {
    showModalBottomSheet(
      context: context,
      // backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        minWidth: double.maxFinite,
        maxHeight: MediaQuery.sizeOf(context).height * 0.4,
      ),
      builder: (context) {
        return Column(
          children: [
            SizedBox(height: 20),
            Text(
              'Remove from Bookmark',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                height: 3,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 15),
            CardWorker(data: worker),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: null,
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: null,
                      child: Text('Yes, Remove'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back),
        ),
        title: Text('My Bookmark'),
      ),
      body: Stack(
        children: [
          // Main content of the page
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 15),
                Service(),
                SizedBox(height: 15),
                Workers(
                  onTapBookmark: (worker) => _removeSheet(context, worker),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
