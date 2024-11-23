// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously, prefer_const_constructors_in_immutables

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freelance/components/button.dart';
import 'package:freelance/components/input.dart';
import 'package:freelance/components/profile_image.dart';
import 'package:freelance/utils/google_drive.dart';
import 'package:image_picker/image_picker.dart';

class ProfileWorkerUpdate extends StatefulWidget {
  ProfileWorkerUpdate({super.key, required this.worker});

  final QueryDocumentSnapshot worker;

  @override
  State<ProfileWorkerUpdate> createState() => _ProfileWorkerUpdateState();
}

class _ProfileWorkerUpdateState extends State<ProfileWorkerUpdate> {
  final name = TextEditingController();
  final desc = TextEditingController();
  final price = TextEditingController();
  final serv = TextEditingController();

  bool loadingUpload = false;
  List<XFile>? imageList;
  ImagePicker picker = ImagePicker();
  int limitImage = 4;

  @override
  void initState() {
    super.initState();
    final data = widget.worker.data() as Map;
    setState(() {
      name.text = widget.worker['name'];
      desc.text = data.containsKey('about') ? widget.worker['about'] : '';
      price.text = data.containsKey('price_minimum')
          ? widget.worker['price_minimum'].toString()
          : '';
      serv.text = data.containsKey('service') ? widget.worker['service'] : '';
    });
  }

  Future selectImage(BuildContext context) async {
    final images = await picker.pickMultiImage(limit: 4);
    if (images.length > limitImage) {
      return ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tidak boleh upload lebih dari 4 gambar'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
    setState(() => imageList = images);
  }

  Future<bool> updateWorkerProfile() async {
    try {
      setState(() => loadingUpload = !loadingUpload);
      await widget.worker.reference.update({
        'name': name.text,
        'about': desc.text,
        'price_minimum': int.parse(price.text),
        'service': serv.text,
        'profile_completed': true,
      });

      List<String> uploadedImage = [];
      if (imageList != null) {
        for (var image in imageList!) {
          final fileUploaded = await uploadImageToGoogleDrive(image);
          uploadedImage.add(fileUploaded!);
        }
      }

      await widget.worker.reference.update({
        'documentation': uploadedImage,
      });
      setState(() => loadingUpload = !loadingUpload);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Profile'),
      ),
      persistentFooterButtons: [
        Button(
          onTap: updateWorkerProfile,
          child: Center(
            child: Text(loadingUpload ? 'Loading...' : 'Simpan'),
          ),
        )
      ],
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.worker['profile_completed'])
              Container(
                padding: EdgeInsets.all(5),
                width: double.maxFinite,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.redAccent,
                ),
                child: Center(
                  child: Text('Lengkapi profile untuk dapat menerima pesanan'),
                ),
              ),
            SizedBox(height: 15),
            Center(
              child: ProfileImage(
                image: NetworkImage(widget.worker['photo_url']),
              ),
            ),
            SizedBox(height: 15),
            Text('Nama'),
            SizedBox(height: 5),
            Input(
              controller: name,
            ),
            SizedBox(height: 15),
            Text('Deskripsi jasa'),
            SizedBox(height: 5),
            Input(controller: desc),
            SizedBox(height: 15),
            Text('Harga minimum jasa'),
            SizedBox(height: 5),
            Input(
              controller: price,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 15),
            Text('Nama layanan'),
            SizedBox(height: 5),
            Input(controller: serv),
            _buildDocumentation(context),
            SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentation(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Dokumentasi jasa',
            ),
            IconButton(
              onPressed: () => loadingUpload ? null : selectImage(context),
              icon: Icon(Icons.add),
            ),
          ],
        ),
        if (imageList != null || widget.worker['documentation'] != null)
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount:
                imageList?.length ?? widget.worker['documentation'].length,
            itemBuilder: (context, index) {
              return Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: imageList != null
                        ? FileImage(File(imageList![index].path))
                        : NetworkImage(widget.worker['documentation'][index])
                            as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              );
              // return Image.file(File(imageList![index].path));
            },
          ),
      ],
    );
  }
}
