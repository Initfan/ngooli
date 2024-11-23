// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, must_be_immutable

import 'package:flutter/material.dart';

class Bookmark extends StatefulWidget {
  Bookmark({super.key, this.marked = false});

  bool marked;

  @override
  State<Bookmark> createState() => _BookmarkState();
}

class _BookmarkState extends State<Bookmark> {
  void _removeSheet(BuildContext context) {
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
              'Remove from Bookmark?',
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
            // CardWorker(),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => widget.marked = !widget.marked);
                        Navigator.pop(context);
                      },
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
    return GestureDetector(
      onTap: () {
        if (widget.marked) {
          _removeSheet(context);
        } else {
          setState(() => widget.marked = !widget.marked);
        }
      },
      child: widget.marked
          ? Icon(
              Icons.bookmark_added_rounded,
              color: Colors.blueAccent,
            )
          : Icon(Icons.bookmark_border),
    );
  }
}
