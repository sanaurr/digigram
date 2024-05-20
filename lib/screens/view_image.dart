import 'package:flutter/material.dart';

class ViewImage extends StatelessWidget {
  const ViewImage({super.key, required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: InteractiveViewer(
        child: Center(
          child: Image.network(url),
        ),
      ),
    );
  }
}

extension ImageViewer on BuildContext {
  void viewImage(String url) {
    Navigator.of(this).push(MaterialPageRoute(builder: (context) {
      return ViewImage(url: url);
    }));
  }
}
