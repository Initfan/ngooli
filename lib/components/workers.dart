// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freelance/components/card_worker.dart';
import 'package:freelance/pages/home/worker_detail.dart';
import 'package:freelance/utils/route.dart';

class Workers extends StatefulWidget {
  const Workers({super.key, this.onTapBookmark, this.service});

  final void Function(QueryDocumentSnapshot worker)? onTapBookmark;
  final String? service;

  @override
  State<Workers> createState() => _WorkersState();
}

class _WorkersState extends State<Workers> {
  @override
  Widget build(BuildContext context) {
    print(widget.service);
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('worker')
          .where('profile_completed', isEqualTo: true)
          .where(
            'service_category',
            isEqualTo: widget.service == 'All' ? null : widget.service,
          )
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox();
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: snapshot.data!.docs.length,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final data = snapshot.data!.docs[index];
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                materialRoute(WorkerDetail(worker: data)),
              ),
              child: CardWorker(
                data: data,
                onTapBookmark: (worker) => widget.onTapBookmark,
              ),
            );
          },
        );
      },
    );
  }
}
