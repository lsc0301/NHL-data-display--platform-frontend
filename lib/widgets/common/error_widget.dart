import 'package:flutter/material.dart';

class ErrorDisplayWidget extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;

  const ErrorDisplayWidget({
    super.key,
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    String errorMessage;
    IconData errorIcon;

    if (error.toString().contains('permission') ||
        error.toString().contains('PERMISSION_DENIED')) {
      errorMessage = 'Permission denied. Please check your Firestore rules.';
      errorIcon = Icons.lock_outline;
    } else if (error.toString().contains('network') ||
        error.toString().contains('UNAVAILABLE')) {
      errorMessage = 'Network error. Please check your connection.';
      errorIcon = Icons.wifi_off;
    } else {
      errorMessage = 'An error occurred: ${error.toString()}';
      errorIcon = Icons.error_outline;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(errorIcon, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

