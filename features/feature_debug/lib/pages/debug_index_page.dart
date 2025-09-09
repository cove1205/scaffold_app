import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../feature_debug_routes.dart';

class DebugIndexPage extends StatelessWidget {
  const DebugIndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Debug')),
      body: ListView.builder(
        itemCount: debugPages.first.children.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            color: Colors.white,
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(
                debugPages.first.children[index].title ??
                    debugPages.first.children[index].name,
              ),
              trailing: Icon(Icons.arrow_forward_ios_sharp),
              onTap: () {
                Get.toNamed('/debug${debugPages.first.children[index].name}');
              },
            ),
          );
        },
      ),
    );
  }
}
