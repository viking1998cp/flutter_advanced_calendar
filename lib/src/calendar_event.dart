import 'package:flutter/material.dart';

/// Calendar event data model
class CalendarEvent {
  const CalendarEvent({
    required this.type,
    required this.quantity,
  });

  /// Event type: 'GĐCT' or 'GĐHT'
  final String type;

  /// Event quantity/number
  final int quantity;

  /// Get display text (e.g., "GĐCT 1", "GĐHT 2")
  String get displayText => '$type $quantity';

  /// Get color based on type
  Color get color {
    switch (type) {
      case 'GĐCT':
        return const Color(0xFF2196F3); // Blue
      case 'GĐHT':
        return const Color(0xFFFF9800); // Orange
      default:
        return Colors.grey;
    }
  }
}

