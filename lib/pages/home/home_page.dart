// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freelance/components/event.dart';
import 'package:freelance/components/workers.dart';
import 'package:freelance/pages/home/bookmark_page.dart';
import 'package:freelance/pages/home/notification_page.dart';
import 'package:freelance/components/title.dart';
import 'package:freelance/model/user.dart';
import 'package:freelance/pages/home/offer_page.dart';
import 'package:freelance/pages/home/worker_list.dart';
import 'package:freelance/pages/home/popular_page.dart';
import 'package:freelance/pages/home/search_page.dart';
import 'package:freelance/pages/home/service_list.dart';
import 'package:freelance/pages/home/services_page.dart';

import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context).user;
    if (user == null) return Text('loading...');

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 15),
              _buildUserProfile(user),
              SizedBox(height: 15),
              _buildSearchField(),
              SizedBox(height: 15),
              _buildEventWidget(),
              SizedBox(height: 15),
              _buildServiceWidget(),
              SizedBox(height: 15),
              _buildPopularServices(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopularServices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: TitleMore(
            title: 'Popular',
            page: PopularPage(),
          ),
        ),
        SizedBox(height: 15),
        WorkerList()
      ],
    );
  }

  Widget _buildServiceWidget() {
    return Builder(builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            TitleMore(
              title: 'Services',
              page: ServicesList(),
            ),
            SizedBox(height: 20),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('services')
                  .limit(8)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('');
                }

                return GridView.builder(
                  itemCount: snapshot.data!.docs.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 20,
                  ),
                  itemBuilder: (context, index) {
                    final data = snapshot.data!.docs[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ServicesPage(service: data['title']),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 50,
                            width: 50,
                            // padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.grey[200]
                                  : Colors.grey[800],
                              backgroundBlendMode: BlendMode.multiply,
                            ),
                            child: Image.network(data['image_url']),
                          ),
                          SizedBox(height: 10),
                          Text(data['title'])
                        ],
                      ),
                    );
                  },
                );
              },
            )
          ],
        ),
      );
    });
  }

  Widget _buildSearchField() {
    FocusNode focusNode = FocusNode();
    return Builder(builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: TextFormField(
          onTap: () {
            focusNode.unfocus();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SearchPage()),
            );
          },
          focusNode: focusNode,
          readOnly: true,
          decoration: InputDecoration(
            fillColor: Theme.of(context).brightness == Brightness.light
                ? Colors.grey[200]
                : Colors.grey[900],
            filled: true,
            prefixIcon: Icon(Icons.search),
            suffixIcon: Icon(Icons.filter_list_rounded),
            hintText: 'Search',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildEventWidget() {
    return Builder(builder: (context) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: TitleMore(
              title: 'Special Offers',
              page: OfferPage(),
            ),
          ),
          SizedBox(height: 15),
          Event(),
        ],
      );
    });
  }

  Widget _buildUserProfile(User user) {
    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
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
                // child: Badge.count(
                //   count: 4,
                //   child: Icon(Icons.notifications_outlined),
                // ),
                child: Icon(Icons.notifications_outlined),
              ),
              SizedBox(width: 10),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BookmarkPage()),
                ),
                child: Icon(Icons.bookmark_border),
              ),
            ],
          ),
        );
      },
    );
  }
}
