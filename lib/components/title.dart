import 'package:flutter/material.dart';

class TitleMore extends StatelessWidget {
  const TitleMore({
    super.key,
    required this.title,
    this.page,
  });

  final String title;
  final Widget? page;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => page!),
          ),
          child: Text(
            'See All',
            style: Theme.of(context)
                .textTheme
                .labelMedium!
                .copyWith(color: Colors.blueAccent),
          ),
        )
      ],
    );
  }
}
