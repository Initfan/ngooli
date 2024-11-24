// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, no_leading_underscores_for_local_identifiers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freelance/components/bookmark.dart';
import 'package:freelance/components/button.dart';
import 'package:freelance/components/review.dart';
import 'package:freelance/model/worker.dart';
import 'package:freelance/pages/booking/booking_service.dart';
import 'package:freelance/pages/inbox/inbox_detail_page.dart';
import 'package:freelance/utils/currency.dart';
import 'package:freelance/utils/route.dart';

class WorkerDetail extends StatelessWidget {
  const WorkerDetail({super.key, required this.worker});

  final QueryDocumentSnapshot worker;

  @override
  Widget build(BuildContext context) {
    final Worker _worker = Worker.fromJson(
      worker.data() as Map<String, dynamic>,
    );
    return Scaffold(
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 15,
        ),
        child: Row(
          children: [
            Expanded(
              child: Button(
                onTap: () => Navigator.push(
                  context,
                  materialRoute(BookingService(worker: worker)),
                ),
                child: Center(
                  child: Text("Pesan layanan"),
                ),
              ),
            ),
            SizedBox(width: 10),
            // IconButton.filledTonal(
            //   onPressed: () => Navigator.push(
            //     context,
            //     materialRoute(
            //       InboxDetailPage(
            //         name: worker['name'],
            //         data: worker,
            //         role: 'user',
            //       ),
            //     ),
            //   ),
            //   icon: Icon(Icons.chat_outlined),
            // )
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: MediaQuery.sizeOf(context).height * 0.25,
            floating: true,
            elevation: 20,
            leading: IconButton.filledTonal(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                worker['photo_url'],
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _workerProfile(_worker),
                  SizedBox(height: 10),
                  Divider(),
                  SizedBox(height: 10),
                  Text(
                    'Tentang',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 5),
                  Text(worker['about']!),
                  SizedBox(height: 15),
                  _buildMedia(),
                  SizedBox(height: 15),
                  _buildReview(_worker),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _workerProfile(Worker _worker) {
    return Builder(builder: (context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${worker['service']}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Spacer(),
              Bookmark(),
            ],
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Text(
                '${worker['name']}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(width: 20),
              Icon(
                Icons.star,
                color: Colors.yellow,
                size: 16,
              ),
              SizedBox(width: 5),
              Text(
                "${_worker.ratingTotal ?? 0} (${_worker.reviewTotal ?? 0} reviews)",
              ),
            ],
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Text(
                currency.format(worker['price_minimum']),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(width: 10),
              Icon(
                Icons.location_on,
                color: Colors.blueAccent,
                size: 16,
              ),
              SizedBox(width: 5),
              Text('Tangerang'),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildReview(Worker _worker) {
    return Builder(builder: (context) {
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.yellow,
                    size: 18,
                  ),
                  SizedBox(width: 5),
                  Text(
                    "${_worker.ratingTotal ?? 0} rating",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
              Text(
                "${_worker.reviewTotal ?? 0} reviews",
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
          SizedBox(height: 15),
          Review(worker: worker),
        ],
      );
    });
  }

  Widget _buildMedia() {
    return Builder(builder: (context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Foto', style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            itemCount: worker['documentation'].length,
            padding: EdgeInsets.all(0),
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              return Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: NetworkImage(worker['documentation'][index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ],
      );
    });
  }
}
