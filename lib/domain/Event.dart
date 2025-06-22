import 'package:flutter/material.dart';

class Event {
  final String title;
  final String description;
  final TimeOfDay? time;

  Event({
    required this.title,
    required this.description,
    this.time,
  });
}
