// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class Rating extends StatefulWidget {
  const Rating({super.key, this.onSelected});

  final void Function(int)? onSelected;

  @override
  State<Rating> createState() => _RatingState();
}

class _RatingState extends State<Rating> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        itemCount: 6,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() => selected = index);
              widget.onSelected!(index);
            },
            child: Container(
              margin: EdgeInsets.only(
                left: index == 0 ? 10 : 0,
                right: 10,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: index == selected ? Colors.blueAccent : null,
                  border: Border.all(color: Colors.blueAccent),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, size: 16),
                    SizedBox(width: 5),
                    Text(
                      index == 0 ? 'All' : '$index',
                      style: TextStyle(
                        color: index == selected ? Colors.white : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
