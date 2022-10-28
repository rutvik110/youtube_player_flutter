import 'package:flutter/material.dart';

class CircularAdaptiveProgressIndicatorWithBg extends StatelessWidget {
  const CircularAdaptiveProgressIndicatorWithBg({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.onBackground,
        ),
        padding: const EdgeInsets.all(10 / 2),
        child: const CircularProgressIndicator.adaptive(),
      ),
    );
  }
}
