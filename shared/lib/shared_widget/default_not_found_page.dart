import 'package:flutter/material.dart';

class DefaultNotFoundPage extends StatelessWidget {
  const DefaultNotFoundPage({
    super.key,
    this.title = '页面未找到',
    this.message = '抱歉,页面未找到',
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            Text(message),
          ],
        ),
      ),
    );
  }
}
