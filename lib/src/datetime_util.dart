extension DateTimeUtil on DateTime {
  /// Generate a new DateTime instance with a zero time.
  DateTime toZeroTime() => DateTime(year, month, day).toLocal();

  int findWeekIndex(List<DateTime> dates) {
    return dates.indexWhere(isAtSameMomentAs) ~/ 7;
  }

  /// Calculates first week date (Sunday) from this date.
  DateTime firstDayOfWeek({int? startWeekDay}) {
    final localDate = DateTime(year, month, day).toLocal();
    if (startWeekDay != null && startWeekDay < 7) {
      return localDate.subtract(Duration(days: localDate.weekday - startWeekDay));
    }
    return localDate.subtract(Duration(days: localDate.weekday % 7));
  }

  /// Generates 7 dates according to this date.
  /// (Supposed that this date is result of [firstDayOfWeek])
  List<DateTime> weekDates() {
    return List.generate(
      7,
      (index) => add(Duration(days: index)),
      growable: false,
    );
  }

  /// Generates list of list with [DateTime]
  /// according to [date] and [weeksAmount].
  /// gives the beginning of the day of the week [startWeekDay]
  List<List<DateTime>> generateWeeks(int weeksAmount, {int? startWeekDay}) {
    final firstViewDate = firstDayOfWeek(startWeekDay: startWeekDay).subtract(
      Duration(
        days: (weeksAmount ~/ 2) * 7,
      ),
    );

    return List.generate(
      weeksAmount,
      (weekIndex) {
        final firstDateOfNextWeek = firstViewDate.add(
          Duration(
            days: weekIndex * 7,
          ),
        );

        return firstDateOfNextWeek.weekDates();
      },
      growable: false,
    );
  }

  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
