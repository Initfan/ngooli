// ignore_for_file: prefer_const_constructors

// import 'dart:convert';
// import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freelance/utils/google_drive.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImage extends StatefulWidget {
  const ProfileImage({
    super.key,
    this.image,
    this.user,
    this.selectImage,
    this.editable = true,
  });

  final ImageProvider? image;
  final User? user;
  final bool editable;
  final void Function()? selectImage;

  @override
  State<ProfileImage> createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  bool _loadingUpload = false;
  ImagePicker picker = ImagePicker();
  String? _imageUrl;

  void selectImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      try {
        setState(() => _loadingUpload = !_loadingUpload);
        final imageLink = await uploadImageToGoogleDrive(image);
        final photoData = {
          "photo_url": imageLink,
        };

        final userColl = FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user!.uid);
        final user = await userColl.get();
        if (user.exists) {
          userColl.update(photoData);
        } else {
          userColl.set(photoData);
        }

        setState(
            () => (_imageUrl = imageLink, _loadingUpload = !_loadingUpload));
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Colors.grey[900],
            image: DecorationImage(
              image: _imageUrl != null
                  ? NetworkImage(_imageUrl!)
                  : widget.image ??
                      AssetImage('assets/images/user-default.png')
                          as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
          child: _loadingUpload
              ? Center(child: CircularProgressIndicator())
              : null,
        ),
        if (widget.editable)
          Positioned(
            bottom: 5,
            right: 5,
            child: GestureDetector(
              onTap: widget.selectImage ?? selectImage,
              child: Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.blueAccent,
                ),
                child: Icon(
                  Icons.edit_outlined,
                  size: 14,
                ),
              ),
            ),
          )
      ],
    );
  }
}
