// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  Button({
    super.key,
    required this.onTap,
    required this.child,
    this.margin,
    this.padding,
    this.height,
    this.color,
  });

  final void Function() onTap;
  final Widget child;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final double? height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        padding: padding,
        height: height ?? 40,
        width: double.maxFinite,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: color ?? Colors.blueAccent,
        ),
        child: child,
      ),
    );
  }
}
