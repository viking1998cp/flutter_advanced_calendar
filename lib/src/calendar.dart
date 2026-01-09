import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DatePickerDropdown extends StatefulWidget {
  const DatePickerDropdown({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
    required this.onClose,
    this.startWeekDay,
  });

  final DateTime initialDate;
  final Function(DateTime) onDateSelected;
  final VoidCallback onClose;
  final int? startWeekDay;

  @override
  State<DatePickerDropdown> createState() => _DatePickerDropdownState();
}

class _DatePickerDropdownState extends State<DatePickerDropdown> {
  late DateTime _selectedDate;
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _currentMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  String _getMonthName(DateTime date) {
    final months = [
      'Tháng Một',
      'Tháng Hai',
      'Tháng Ba',
      'Tháng Tư',
      'Tháng Năm',
      'Tháng Sáu',
      'Tháng Bảy',
      'Tháng Tám',
      'Tháng Chín',
      'Tháng Mười',
      'Tháng Mười Một',
      'Tháng Mười Hai',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  List<DateTime> _getCalendarDays() {
    final firstDayOfMonth = _currentMonth;
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);

    int firstDayOfWeek;
    if (widget.startWeekDay != null) {
      int weekday = firstDayOfMonth.weekday;
      if (widget.startWeekDay == 1) {
        firstDayOfWeek = weekday == 7 ? 0 : weekday - 1;
      } else {
        firstDayOfWeek = (weekday - widget.startWeekDay!) % 7;
        if (firstDayOfWeek < 0) firstDayOfWeek += 7;
      }
    } else {
      firstDayOfWeek = firstDayOfMonth.weekday % 7;
    }

    final daysInMonth = lastDayOfMonth.day;
    final days = <DateTime>[];

    final previousMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 0);
    final daysToAddFromPreviousMonth = firstDayOfWeek;
    for (int i = daysToAddFromPreviousMonth - 1; i >= 0; i--) {
      days.add(DateTime(_currentMonth.year, _currentMonth.month - 1, previousMonth.day - i));
    }

    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(_currentMonth.year, _currentMonth.month, i));
    }

    final remainingDays = 42 - days.length;
    for (int i = 1; i <= remainingDays; i++) {
      days.add(DateTime(_currentMonth.year, _currentMonth.month + 1, i));
    }

    return days;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final calendarDays = _getCalendarDays();

    List<String> weekDays;
    if (widget.startWeekDay != null && widget.startWeekDay == 1) {
      weekDays = ['Th 2', 'Th 3', 'Th 4', 'Th 5', 'Th 6', 'Th 7', 'CN'];
    } else if (widget.startWeekDay != null && widget.startWeekDay! < 7) {
      final baseDays = ['CN', 'Th 2', 'Th 3', 'Th 4', 'Th 5', 'Th 6', 'Th 7'];
      weekDays = List.generate(7, (index) => baseDays[(widget.startWeekDay! + index) % 7]);
    } else {
      weekDays = ['CN', 'Th 2', 'Th 3', 'Th 4', 'Th 5', 'Th 6', 'Th 7'];
    }

    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12).r,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: _previousMonth,
                      child: Padding(
                        padding: EdgeInsets.all(8.w),
                        child: Icon(Icons.chevron_left, size: 20.sp),
                      ),
                    ),
                    Text(
                      _getMonthName(_currentMonth),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                    InkWell(
                      onTap: _nextMonth,
                      child: Padding(
                        padding: EdgeInsets.all(8.w),
                        child: Icon(Icons.chevron_right, size: 20.sp),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: weekDays.map((day) {
                    return Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 12.h),
                GridView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    // Make cells a bit flatter to reduce overall height
                    childAspectRatio: 1.4,
                  ),
                  itemCount: calendarDays.length,
                  itemBuilder: (context, index) {
                    final date = calendarDays[index];
                    final isCurrentMonth = date.month == _currentMonth.month;
                    final isSelected = date.year == _selectedDate.year && date.month == _selectedDate.month && date.day == _selectedDate.day;
                    final isToday = date.year == DateTime.now().year && date.month == DateTime.now().month && date.day == DateTime.now().day;

                    return InkWell(
                      onTap: () {
                        if (isCurrentMonth) {
                          setState(() {
                            _selectedDate = date;
                          });
                          widget.onDateSelected(_selectedDate);
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Color(0xff1F3368)
                              : isToday
                                  ? Color(0xff1F3368).withOpacity(0.1)
                                  : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                              color: isSelected
                                  ? Colors.white
                                  : isCurrentMonth
                                      ? Color(0xff111827)
                                      : Color(0xffe5e7eb),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
