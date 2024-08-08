import 'package:flutter/material.dart';

class FullScreenView extends StatefulWidget {
  const FullScreenView({super.key});

  @override
  State<FullScreenView> createState() => _FullScreenViewState();
}

class _FullScreenViewState extends State<FullScreenView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FullScreenView'),
      ),
      body: const Center(
        child: Text('FullScreenView'),
      ),
    );
  }
}
