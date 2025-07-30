import 'package:flutter/material.dart';

class ErrorEmptyState extends StatelessWidget {
  final String image;
  final String message;
  final String buttonText;
  final VoidCallback onRetry;

  const ErrorEmptyState({
    Key? key,
    required this.image,
    required this.message,
    required this.buttonText,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(image),  // Display the empty state image
          const SizedBox(height: 20),
          Text(
            message,
            textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onRetry,
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}
