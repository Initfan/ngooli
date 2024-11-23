// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freelance/model/user.dart';
import 'package:freelance/pages/home/notification_page.dart';
import 'package:freelance/utils/currency.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeWorkerPage extends StatelessWidget {
  const HomeWorkerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context).user;
    if (user == null) return Text('loading...');

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserProfile(user),
              _balanceCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _balanceCard() => Builder(
        builder: (context) {
          return Container(
            margin: EdgeInsets.symmetric(vertical: 15),
            padding: EdgeInsets.all(15),
            width: double.maxFinite,
            height: MediaQuery.sizeOf(context).height * 0.2,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[900]
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "+${currency.format(500)} hari ini",
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge!
                          .copyWith(color: Colors.grey),
                    ),
                    Spacer(),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: null,
                          child: Icon(
                            Icons.add_card,
                          ),
                        ),
                        SizedBox(width: 15),
                        GestureDetector(
                          onTap: null,
                          child: SvgPicture.asset(
                            "assets/svg/withdraw.svg",
                            color: Theme.of(context).iconTheme.color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  currency.format(500),
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Text('.. Rating'),
                    SizedBox(width: 10),
                    Text('.. Direkomendasikan'),
                  ],
                )
              ],
            ),
          );
        },
      );

  Widget _buildUserProfile(User user) {
    return Builder(
      builder: (context) {
        return Row(
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                image: DecorationImage(
                  image: user.photoURL != null
                      ? NetworkImage(user.photoURL!)
                      : AssetImage('assets/images/user-default.png')
                          as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat datang',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall!
                      .copyWith(color: Colors.grey),
                ),
                Text(
                  user.displayName ?? 'user',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            Spacer(),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NotificationPage()),
              ),
              child: Badge.count(
                count: 4,
                child: Icon(Icons.notifications_outlined),
              ),
              // child: Icon(Icons.notifications_outlined),
            ),
          ],
        );
      },
    );
  }
}
