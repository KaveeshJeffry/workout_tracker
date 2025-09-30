import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floating;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floating,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: SafeArea(
        child: Container(
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.all(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: body,
          ),
        ),
      ),
      floatingActionButton: floating,
    );
  }
}
