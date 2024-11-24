// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Service extends StatefulWidget {
  const Service({
    super.key,
    this.selectedService,
  });

  final void Function(String)? selectedService;

  @override
  State<Service> createState() => _ServiceState();
}

class _ServiceState extends State<Service> {
  int selected = 0;

  void onSelected(String service, int index) {
    setState(() => selected = index);
    widget.selectedService!(service);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('services').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return SizedBox();
            }

            return Skeletonizer(
              enabled: !snapshot.hasData,
              child: ListView.builder(
                itemCount: snapshot.data!.docs.length + 1,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildButton('All', index);
                  }
                  final data = snapshot.data!.docs[index - 1];
                  return _buildButton(data['title'], index);
                },
              ),
            );
          }),
    );
  }

  GestureDetector _buildButton(String title, int index) {
    return GestureDetector(
      onTap: () => onSelected(title, index),
      child: Container(
        margin: EdgeInsets.only(
          left: index == 0 ? 10 : 0,
          right: 10,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: index == selected ? Colors.blueAccent : null,
            border: Border.all(
              color: Colors.blueAccent,
              // width: 2,
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: index == selected ? Colors.white : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
