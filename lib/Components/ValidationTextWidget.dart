import 'package:flutter/material.dart';

/// ValidationTextWidget that represent style of each one of them and shows as list of condition that you want to the app user
class ValidationTextWidget extends StatelessWidget {
  final Color color;
  final String text;
  final int? value;

  ValidationTextWidget({
    required this.color,
    required this.text,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: [
        new Container(
          width: 16,
          height: 16,
          child: CircleAvatar(backgroundColor: color),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: Text(
            text.replaceFirst("-", value.toString()),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: color),
          ),
        )
      ],
    );
  }
}
