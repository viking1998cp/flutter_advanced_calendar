part of 'widget.dart';

class Header extends StatefulWidget {
  const Header({
    Key? key,
    required this.monthDate,
    this.margin,
    this.onPressed,
    this.dateStyle,
    this.todayStyle,
    this.child,
    this.weekDates,
    this.onWeekChanged,
    this.onDateSelected,
    this.startWeekDay,
  }) : super(key: key);

  final DateTime monthDate;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onPressed;
  final TextStyle? dateStyle;
  final TextStyle? todayStyle;
  final Widget? child;
  final List<DateTime>? weekDates;
  final Function(DateTime)? onWeekChanged;
  final Function(DateTime)? onDateSelected;
  final int? startWeekDay;

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  final GlobalKey _datePickerKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isDropdownOpen = false;

  @override
  void dispose() {
    _closeDropdown();
    super.dispose();
  }

  String _formatWeekRange(List<DateTime>? weekDates) {
    if (weekDates == null || weekDates.isEmpty) {
      return '';
    }
    final firstDate = weekDates.first;
    final lastDate = weekDates.last;

    if (firstDate.month == lastDate.month) {
      return '${firstDate.day} thg ${firstDate.month} - ${lastDate.day} thg ${lastDate.month}';
    } else {
      return '${firstDate.day} thg ${firstDate.month} - ${lastDate.day} thg ${lastDate.month}';
    }
  }

  void _closeDropdown() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      _isDropdownOpen = false;
    }
  }

  void _showDatePicker() {
    if (widget.weekDates == null || widget.weekDates!.isEmpty) return;

    if (_isDropdownOpen) {
      _closeDropdown();
      return;
    }

    final RenderBox? renderBox =
        _datePickerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    final screenWidth = MediaQuery.of(context).size.width;
    final dropdownWidth = 300.w;
    double leftPosition = offset.dx;

    if (leftPosition + dropdownWidth > screenWidth) {
      leftPosition = screenWidth - dropdownWidth - 16.w;
    }
    if (leftPosition < 0) {
      leftPosition = 16.w;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _closeDropdown,
        child: Container(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned(
                left: leftPosition,
                top: offset.dy + size.height + 4.h,
                child: GestureDetector(
                  onTap: () {},
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(12.r),
                    child: _DatePickerDropdown(
                      initialDate: widget.weekDates!.first,
                      startWeekDay: widget.startWeekDay,
                      onDateSelected: (date) {
                        if (widget.onDateSelected != null) {
                          widget.onDateSelected!(date);
                        }
                        _closeDropdown();
                      },
                      onClose: _closeDropdown,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _isDropdownOpen = true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: widget.margin ??
          EdgeInsets.only(
            top: 4.h,
            bottom: 4.h,
          ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 20.sp,
                color: theme.textTheme.titleMedium?.color,
              ),
              SizedBox(width: 4.w),
              Text(
                'Lịch của tôi',
                style: widget.dateStyle ??
                    theme.textTheme.titleMedium?.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          if (widget.child != null) widget.child!,
          const Spacer(),
          if (widget.weekDates != null && widget.weekDates!.isNotEmpty)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    if (widget.onWeekChanged != null &&
                        widget.weekDates!.isNotEmpty) {
                      final prevWeek = widget.weekDates!.first
                          .subtract(const Duration(days: 7));
                      widget.onWeekChanged!(prevWeek);
                    }
                  },
                  borderRadius: BorderRadius.circular(4.r),
                  child: Padding(
                    padding: EdgeInsets.only(right: 2.w, left: 2.w),
                    child: Icon(
                      Icons.chevron_left,
                      size: 20.sp,
                      color: theme.textTheme.titleMedium?.color,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _showDatePicker,
                  child: Container(
                    key: _datePickerKey,
                    decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8.r)),
                    padding: EdgeInsets.only(
                        right: 4.w, left: 4.w, top: 2.h, bottom: 2.h),
                    child: Text(
                      _formatWeekRange(widget.weekDates),
                      style: widget.todayStyle ??
                          widget.dateStyle ??
                          theme.textTheme.titleMedium?.copyWith(
                            fontSize: 12.sp,
                          ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    if (widget.onWeekChanged != null &&
                        widget.weekDates!.isNotEmpty) {
                      final nextWeek =
                          widget.weekDates!.first.add(const Duration(days: 7));
                      widget.onWeekChanged!(nextWeek);
                    }
                  },
                  borderRadius: BorderRadius.circular(4.r),
                  child: Padding(
                    padding: EdgeInsets.only(right: 2.w),
                    child: Icon(
                      Icons.chevron_right,
                      size: 20.sp,
                      color: theme.textTheme.titleMedium?.color,
                    ),
                  ),
                ),
              ],
            )
        ],
      ),
    );
  }
}

class _DatePickerDropdown extends StatefulWidget {
  const _DatePickerDropdown({
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
  State<_DatePickerDropdown> createState() => _DatePickerDropdownState();
}

class _DatePickerDropdownState extends State<_DatePickerDropdown> {
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
    final lastDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0);

    int firstDayOfWeek;
    if (widget.startWeekDay != null && widget.startWeekDay! < 7) {
      firstDayOfWeek = (firstDayOfMonth.weekday - widget.startWeekDay!) % 7;
      if (firstDayOfWeek < 0) firstDayOfWeek += 7;
    } else {
      firstDayOfWeek = firstDayOfMonth.weekday % 7;
    }

    final daysInMonth = lastDayOfMonth.day;
    final days = <DateTime>[];

    final previousMonth =
        DateTime(_currentMonth.year, _currentMonth.month - 1, 0);
    for (int i = firstDayOfWeek - 1; i >= 0; i--) {
      days.add(DateTime(
          _currentMonth.year, _currentMonth.month - 1, previousMonth.day - i));
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
    if (widget.startWeekDay != null && widget.startWeekDay! < 7) {
      final baseDays = ['CN', 'Th 2', 'Th 3', 'Th 4', 'Th 5', 'Th 6', 'Th 7'];
      weekDays = List.generate(
          7, (index) => baseDays[(widget.startWeekDay! + index) % 7]);
    } else {
      weekDays = ['CN', 'Th 2', 'Th 3', 'Th 4', 'Th 5', 'Th 6', 'Th 7'];
    }

    return Container(
      width: 300.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
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
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                SizedBox(height: 16.h),
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
                SizedBox(height: 8.h),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: calendarDays.length,
                  itemBuilder: (context, index) {
                    final date = calendarDays[index];
                    final isCurrentMonth = date.month == _currentMonth.month;
                    final isSelected = date.year == _selectedDate.year &&
                        date.month == _selectedDate.month &&
                        date.day == _selectedDate.day;
                    final isToday = date.year == DateTime.now().year &&
                        date.month == DateTime.now().month &&
                        date.day == DateTime.now().day;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedDate = date;
                        });
                        widget.onDateSelected(_selectedDate);
                      },
                      child: Container(
                        margin: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blueGrey
                              : isToday
                                  ? Colors.blueGrey.withOpacity(0.1)
                                  : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${date.day}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : isCurrentMonth
                                      ? theme.textTheme.bodyMedium?.color
                                      : theme.textTheme.bodyMedium?.color
                                          ?.withOpacity(0.3),
                              fontWeight: isSelected || isToday
                                  ? FontWeight.bold
                                  : FontWeight.normal,
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
