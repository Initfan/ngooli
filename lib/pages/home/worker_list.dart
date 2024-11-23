// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:freelance/components/service.dart';
import 'package:freelance/components/workers.dart';

class WorkerList extends StatefulWidget {
  const WorkerList({super.key});

  @override
  State<WorkerList> createState() => _WorkerListState();
}

class _WorkerListState extends State<WorkerList> {
  String? service;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Service(
          selectedService: (value) => setState(() => service = value),
        ),
        SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Workers(service: service),
        ),
      ],
    );
  }
}
