// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ngooli/components/button.dart';
import 'package:ngooli/components/input.dart';
import 'package:intl/intl.dart';

class MyService extends StatefulWidget {
  const MyService({super.key, required this.worker});

  final DocumentReference worker;

  @override
  State<MyService> createState() => _MyServiceState();
}

class _MyServiceState extends State<MyService> {
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  TextEditingController name = TextEditingController();
  TextEditingController price = TextEditingController();

  // bool _sheetOpen = false;

  void removeService(String id) async {
    widget.worker.collection('services').doc(id).delete();
  }

  void _createService() async {
    _key.currentState?.showBottomSheet((context) {
      return BottomSheet(
        onClosing: () {},
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Buat layanan baru',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 20),
                Input(
                  controller: name,
                  hintText: 'Nama',
                ),
                SizedBox(height: 10),
                Input(
                  controller: price,
                  hintText: 'Harga',
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Button(
                        onTap: () => Navigator.pop(context),
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.grey[200]
                            : Colors.grey[800],
                        child: Center(child: Text('Batal')),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Button(
                        onTap: () async {
                          await widget.worker.collection('services').add({
                            'name': name.text,
                            'price': int.parse(price.text),
                          });
                          Navigator.pop(context);
                          name.clear();
                          price.clear();
                        },
                        child: Center(child: Text('Simpan')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.simpleCurrency(
      locale: 'id_ID',
      decimalDigits: 0,
    );

    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text('My Service'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createService,
        child: Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: widget.worker.collection('services').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final data = snapshot.data!.docs[index];
              return ListTile(
                title: Text(data['name']),
                subtitle: Text(currency.format(data['price'])),
                trailing: GestureDetector(
                  onTap: () => removeService(data.id),
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
