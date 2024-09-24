import 'dart:math';

import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomePage'),
      ),
      body: Center(
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: WidgetCache.getWidget('get_widhet'),
            ),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: WidgetCache.getWidget('get_widht'),
            ),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: WidgetCache.getWidget('get_widht'),
            ),
          ],
        ),
      ),
    );
  }
}

class WidgetCache {
  static final Map<String, Widget> _cache = {};

  static Widget getWidget(String key) {
    if (!_cache.containsKey(key)) {
      _cache[key] = Container(
        color: Colors.red,
        child: Text(
          Random.secure().nextInt(100).toString(),
          style: const TextStyle(color: Colors.black),
        ),
      );
    }
    return _cache[key]!;
  }
}
