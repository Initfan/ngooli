import 'package:flutter/material.dart';

Route materialRoute(Widget targetWidget) {
  return MaterialPageRoute(builder: (_) => targetWidget);
}

Route route(Widget targetWidget) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => targetWidget,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.ease;
      final tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: curve),
      );
      final offsetAnimation = animation.drive(tween);
      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}
