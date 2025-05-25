import 'package:flutter/material.dart';

class QueuePositionIndicator extends StatelessWidget {
  final int position;

  const QueuePositionIndicator({
    super.key,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    // Colors based on position
    Color color;
    String message;
    
    if (position == 1) {
      color = Colors.green;
      message = 'You\'re next!';
    } else if (position == 2) {
      color = const Color(0xFFFFA500);
      message = 'Almost there!';
    } else {
      color = Theme.of(context).colorScheme.primary;
      message = 'In queue';
    }
    
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.1),
            border: Border.all(
              color: color,
              width: 4,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  position.toString(),
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  'Position',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          message,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
