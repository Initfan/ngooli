// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freelance/components/rating.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Review extends StatefulWidget {
  Review({
    super.key,
    required this.worker,
  });

  DocumentSnapshot worker;

  @override
  State<Review> createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  int rating = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Rating(onSelected: (index) => setState(() => rating = index)),
        _buildReview(),
      ],
    );
  }

  Widget _buildReview() {
    return StreamBuilder(
        stream: widget.worker.reference
            .collection('reviews')
            .where('rating', isEqualTo: rating == 0 ? null : rating)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox();
          }
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final data = snapshot.data!.docs[index];
              return ReviewItem(data: data);
            },
          );
        });
  }
}

class ReviewItem extends StatefulWidget {
  const ReviewItem({super.key, required this.data});

  final QueryDocumentSnapshot data;

  @override
  State<ReviewItem> createState() => _ReviewItemState();
}

class _ReviewItemState extends State<ReviewItem> {
  bool liked = false;
  int likes = 0;
  List likedBy = [];

  void likingReview() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    setState(() => liked = !liked);
    if (liked) {
      widget.data.reference.update({
        'likes': widget.data['likes'] + 1,
        'liked_by': [userId],
      });
      setState(() => likes += 1);
    } else {
      widget.data.reference.update({
        'likes': widget.data['likes'] - 1,
        'liked_by': likedBy.where((x) => x != userId),
      });
      setState(() => likes -= 1);
    }
  }

  @override
  void initState() {
    super.initState();
    likes = widget.data['likes'];

    if (likes > 0) {
      likedBy = widget.data['liked_by'];
      final userLiked = likedBy.contains(
        FirebaseAuth.instance.currentUser!.uid,
      );
      if (userLiked) setState(() => liked = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    Timestamp time = widget.data['timestamp'];
    DateTime date = time.toDate();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildUser(widget.data),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.blueAccent,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.blueAccent,
                    ),
                    SizedBox(width: 5),
                    Text(
                      "${widget.data['rating']}",
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(widget.data['review']),
          SizedBox(height: 10),
          Row(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: likingReview,
                    child: Icon(
                      liked ? Icons.favorite : Icons.favorite_border,
                      color: liked ? Colors.red : null,
                    ),
                  ),
                  SizedBox(width: 5),
                  Text(likes.toString())
                ],
              ),
              SizedBox(width: 10),
              Text(
                DateFormat('MMM dd, yyyy').format(date),
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(color: Colors.grey),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUser(QueryDocumentSnapshot _data) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(_data['user_id'])
          .snapshots(),
      builder: (context, snapshot) {
        return Skeletonizer(
          enabled: !snapshot.hasData,
          child: Row(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.grey,
                  image: DecorationImage(
                    image: NetworkImage(snapshot.data?['photo_url']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 10),
              Text(snapshot.data?['name']),
            ],
          ),
        );
      },
    );
  }
}
