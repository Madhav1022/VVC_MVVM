import 'package:flutter/material.dart';

class LineItem extends StatelessWidget {
  final String line;

  const LineItem({
    super.key,
    required this.line
  });

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<String>(
      data: line,
      dragAnchorStrategy: childDragAnchorStrategy,
      feedback: Material(
        elevation: 4,
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8
          ),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            line,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ),
      child: Chip(
        label: Text(line),
        backgroundColor: Colors.grey.shade100,
        side: BorderSide(color: Colors.grey.shade300),
        labelStyle: TextStyle(color: Colors.grey.shade800),
      ),
    );
  }
}