import 'package:flutter/material.dart';
import 'package:flutter_advanced_calendar/src/calendar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'calendar_event.dart';
import 'controller.dart';
import 'datetime_util.dart';

part 'date_box.dart';
part 'handlebar.dart';
part 'header.dart';
part 'month_view.dart';
part 'month_view_bean.dart';
part 'week_days.dart';
part 'week_view.dart';

/// Advanced Calendar widget.
class AdvancedCalendar extends StatefulWidget {
  const AdvancedCalendar({
    super.key,
    this.controller,
    this.startWeekDay,
    this.events,
    this.eventMap,
    this.weekLineHeight = 32.0,
    this.preloadMonthViewAmount = 13,
    this.preloadWeekViewAmount = 21,
    this.weeksInMonthViewAmount = 6,
    this.todayStyle,
    this.headerStyle,
    this.onHorizontalDrag,
    this.innerDot = false,
    this.keepLineSize = false,
    this.calendarTextStyle,
    this.showNavigationArrows = false,
    this.disableScroll = false,
    this.showHandleBar = true,
    this.showToday = true,
    this.title = const SizedBox(),
    this.onTapDayInWeek,
    required this.getFirstAndLastWeek,
  }) : assert(
          keepLineSize && innerDot || innerDot && !keepLineSize || !innerDot && !keepLineSize,
          'keepLineSize should be used only when innerDot is true',
        );

  /// Calendar selection date controller.
  final AdvancedCalendarController? controller;

  /// Executes on horizontal calendar swipe. Allows to load additional dates.
  final Function(DateTime)? onHorizontalDrag;

  /// Height of week line.
  final double weekLineHeight;

  /// Amount of months in month view to preload.
  final int preloadMonthViewAmount;

  /// Amount of weeks in week view to preload.
  final int preloadWeekViewAmount;

  /// Weeks lines amount in month view.
  final int weeksInMonthViewAmount;

  /// List of points for the week and month (deprecated, use eventMap instead)
  final List<DateTime>? events;

  /// Map of dates to their calendar events (GĐCT, GĐHT)
  final Map<DateTime, CalendarModel>? eventMap;

  /// The first day of the week starts[0-6]
  final int? startWeekDay;

  /// Style of headers date
  final TextStyle? headerStyle;

  /// Style of Today button
  final TextStyle? todayStyle;

  /// Show DateBox event in container.
  final bool innerDot;

  /// Keeps consistent line size for dates
  /// Can't be used without innerDot
  final bool keepLineSize;

  /// Text style for dates in calendar
  final TextStyle? calendarTextStyle;

  /// Show navigation arrows.
  final bool showNavigationArrows;

  /// Disable scroll - only show week view (no month view expansion)
  final bool disableScroll;

  final bool showToday;

  /// Show or hide the handle bar
  final bool showHandleBar;

  final Widget title;

  final void Function(DateTime)? onTapDayInWeek;

  final void Function(DateTime, DateTime) getFirstAndLastWeek;

  @override
  _AdvancedCalendarState createState() => _AdvancedCalendarState();
}

class _AdvancedCalendarState extends State<AdvancedCalendar> with SingleTickerProviderStateMixin {
  late ValueNotifier<int> _monthViewCurrentPage;
  late AnimationController _animationController;
  late AdvancedCalendarController _controller;
  late double _animationValue;
  late List<ViewRange> _monthRangeList;
  late List<List<DateTime>> _weekRangeList;
  int currentPageWeek = 0;
  PageController? _monthPageController;
  PageController? _weekPageController;
  Offset? _captureOffset;
  DateTime? _todayDate;
  List<String>? _weekNames;
  DateTime firstWeek = DateTime.now();
  DateTime lastWeek = DateTime.now();
  final GlobalKey _datePickerKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isDropdownOpen = false;

  @override
  void initState() {
    super.initState();

    final monthPageIndex = widget.preloadMonthViewAmount ~/ 2;

    _monthViewCurrentPage = ValueNotifier(monthPageIndex);

    _monthPageController = PageController(
      initialPage: monthPageIndex,
    );

    final weekPageIndex = widget.preloadWeekViewAmount ~/ 2;
    _weekPageController = PageController(
      initialPage: weekPageIndex,
    );
    currentPageWeek = weekPageIndex;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 0,
    );

    _animationValue = _animationController.value;

    _controller = widget.controller ?? AdvancedCalendarController.today();
    _todayDate = _controller.value;

    _monthRangeList = List.generate(
      widget.preloadMonthViewAmount,
      (index) => ViewRange.generateDates(
        _todayDate!,
        _todayDate!.month + (index - _monthPageController!.initialPage),
        widget.weeksInMonthViewAmount,
        startWeekDay: widget.startWeekDay,
      ),
    );

    _weekRangeList = _controller.value.generateWeeks(
      widget.preloadWeekViewAmount,
      startWeekDay: widget.startWeekDay,
    );
    _controller.addListener(() {
      _weekRangeList = _controller.value.generateWeeks(
        widget.preloadWeekViewAmount,
        startWeekDay: widget.startWeekDay,
      );
      _weekPageController!.jumpToPage(widget.preloadWeekViewAmount ~/ 2);
    });
    if (widget.startWeekDay != null && widget.startWeekDay! < 7) {
      final time = _controller.value.subtract(
        Duration(days: _controller.value.weekday - widget.startWeekDay!),
      );
      final list = List<DateTime>.generate(
        8,
        (index) => time.add(Duration(days: index * 1)),
      ).toList();
      _weekNames = List<String>.generate(7, (index) {
        return DateFormat("EEEE").format(list[index]).split('').first;
      });
    }
    firstWeek = getFirstWeek();
    lastWeek = getLastWeek();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: DefaultTextStyle.merge(
        style: theme.textTheme.bodyMedium,
        child: widget.disableScroll
            ? _buildCalendarContent()
            : GestureDetector(
                onVerticalDragStart: widget.disableScroll
                    ? null
                    : (details) {
                        _captureOffset = details.globalPosition;
                      },
                onVerticalDragUpdate: widget.disableScroll
                    ? null
                    : (details) {
                        final moveOffset = details.globalPosition;
                        final diffY = moveOffset.dy - _captureOffset!.dy;

                        _animationController.value = _animationValue + diffY / (widget.weekLineHeight * 5);
                      },
                onVerticalDragEnd: widget.disableScroll ? null : (details) => _handleFinishDrag(),
                onVerticalDragCancel: widget.disableScroll ? null : _handleFinishDrag,
                child: _buildCalendarContent(),
              ),
      ),
    );
  }

  Widget _buildCalendarContent() {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ValueListenableBuilder<int>(
          valueListenable: _monthViewCurrentPage,
          builder: (_, value, __) {
            return Header(
              title: widget.title,
              monthDate: _monthRangeList[_monthViewCurrentPage.value].firstDay,
              onPressed: _handleTodayPressed,
              dateStyle: widget.headerStyle,
              todayStyle: widget.todayStyle,
              showToday: widget.showToday,
              child: widget.showNavigationArrows
                  ? Row(
                      children: [
                        InkWell(
                          onTap: _handlePrevPressed,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4).r,
                            child: Icon(
                              Icons.arrow_back_ios,
                              size: 14.w,
                            ),
                          ),
                        ),
                        InkWell(
                          key: _datePickerKey,
                          onTap: handleSelectWeekInCalendar,
                          child: Text(
                            "${DateFormat("dd 'thg' MM", "vi").format(firstWeek)} - ${DateFormat("dd 'thg' MM", "vi").format(lastWeek)}",
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: _handleNextPressed,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4).r,
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 14.w,
                            ),
                          ),
                        ),
                      ],
                    )
                  : null,
            );
          },
        ),
        12.verticalSpace,
        WeekDays(
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.hintColor,
          ),
          keepLineSize: widget.keepLineSize,
        ),
        4.verticalSpace,
        widget.disableScroll
            ? _buildWeekViewOnly()
            : AnimatedBuilder(
                animation: _animationController,
                builder: (_, __) {
                  final height = Tween<double>(
                    begin: widget.weekLineHeight,
                    end: widget.weekLineHeight * widget.weeksInMonthViewAmount,
                  ).transform(_animationController.value);
                  return SizedBox(
                    height: height,
                    child: ValueListenableBuilder<DateTime>(
                      valueListenable: _controller,
                      builder: (_, selectedDate, __) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            IgnorePointer(
                              ignoring: _animationController.value == 0.0,
                              child: Opacity(
                                opacity: Tween<double>(
                                  begin: 0,
                                  end: 1,
                                ).evaluate(_animationController),
                                child: PageView.builder(
                                  onPageChanged: (pageIndex) {
                                    if (widget.onHorizontalDrag != null) {
                                      widget.onHorizontalDrag!(
                                        _monthRangeList[pageIndex].firstDay,
                                      );
                                    }
                                    _monthViewCurrentPage.value = pageIndex;
                                  },
                                  controller: _monthPageController,
                                  physics: _animationController.value == 1.0
                                      ? const AlwaysScrollableScrollPhysics()
                                      : const NeverScrollableScrollPhysics(),
                                  itemCount: _monthRangeList.length,
                                  itemBuilder: (_, pageIndex) {
                                    return MonthView(
                                      innerDot: widget.innerDot,
                                      monthView: _monthRangeList[pageIndex],
                                      todayDate: _todayDate,
                                      selectedDate: selectedDate,
                                      weekLineHeight: widget.weekLineHeight,
                                      weeksAmount: widget.weeksInMonthViewAmount,
                                      onChanged: _handleDateChanged,
                                      events: widget.events,
                                      eventMap: widget.eventMap,
                                      keepLineSize: widget.keepLineSize,
                                      textStyle: widget.calendarTextStyle,
                                    );
                                  },
                                ),
                              ),
                            ),
                            ValueListenableBuilder<int>(
                              valueListenable: _monthViewCurrentPage,
                              builder: (_, pageIndex, __) {
                                final index = selectedDate.findWeekIndex(
                                  _monthRangeList[_monthViewCurrentPage.value].dates,
                                );
                                final offset = index / (widget.weeksInMonthViewAmount - 1) * 2 - 1.0;
                                return Align(
                                  alignment: Alignment(0.0, offset),
                                  child: IgnorePointer(
                                    ignoring: _animationController.value == 1.0,
                                    child: Opacity(
                                      opacity: Tween<double>(
                                        begin: 1.0,
                                        end: 0.0,
                                      ).evaluate(_animationController),
                                      child: SizedBox(
                                        height: widget.weekLineHeight,
                                        child: PageView.builder(
                                          onPageChanged: (indexPage) {
                                            final pageIndex = _monthRangeList.indexWhere(
                                              (index) => index.firstDay.month == _weekRangeList[indexPage].first.month,
                                            );

                                            if (widget.onHorizontalDrag != null) {
                                              widget.onHorizontalDrag!(
                                                _monthRangeList[pageIndex].firstDay,
                                              );
                                            }
                                            _monthViewCurrentPage.value = pageIndex;
                                          },
                                          controller: _weekPageController,
                                          itemCount: _weekRangeList.length,
                                          physics: _closeMonthScroll(),
                                          itemBuilder: (context, index) {
                                            return WeekView(
                                              innerDot: widget.innerDot,
                                              dates: _weekRangeList[index],
                                              selectedDate: selectedDate,
                                              lineHeight: widget.weekLineHeight,
                                              onChanged: _handleWeekDateChanged,
                                              events: widget.events,
                                              eventMap: widget.eventMap,
                                              keepLineSize: widget.keepLineSize,
                                              textStyle: widget.calendarTextStyle,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
        if (widget.showHandleBar && !widget.disableScroll)
          HandleBar(
            onPressed: () async {
              await _animationController.forward();
              _animationValue = 1.0;
            },
          ),
      ],
    );
  }

  Widget _buildWeekViewOnly() {
    return SizedBox(
      height: widget.weekLineHeight,
      child: ValueListenableBuilder<DateTime>(
        valueListenable: _controller,
        builder: (_, selectedDate, __) {
          return PageView.builder(
            onPageChanged: (indexPage) {
              final pageIndex = _monthRangeList.indexWhere(
                (index) => index.firstDay.month == _weekRangeList[indexPage].first.month,
              );
              if (widget.onHorizontalDrag != null) {
                widget.onHorizontalDrag!(
                  _monthRangeList[pageIndex].firstDay,
                );
              }
              if (currentPageWeek > indexPage || _monthViewCurrentPage.value > pageIndex) {
                final dateBack = DateTime(firstWeek.year, firstWeek.month, firstWeek.day - 1);
                firstWeek = getFirstWeek(date: dateBack);
                lastWeek = getLastWeek(date: dateBack);
              } else {
                final dateNext = DateTime(lastWeek.year, lastWeek.month, lastWeek.day + 1);
                firstWeek = getFirstWeek(date: dateNext);
                lastWeek = getLastWeek(date: dateNext);
              }
              _monthViewCurrentPage.value = pageIndex;
              currentPageWeek = indexPage;
              widget.getFirstAndLastWeek.call(
                firstWeek,
                lastWeek,
              );
              setState(() {});
            },
            controller: _weekPageController,
            itemCount: _weekRangeList.length,
            itemBuilder: (context, index) {
              return WeekView(
                innerDot: widget.innerDot,
                dates: _weekRangeList[index],
                selectedDate: selectedDate,
                lineHeight: widget.weekLineHeight,
                onChanged: _handleWeekDateChanged,
                events: widget.events,
                eventMap: widget.eventMap,
                keepLineSize: widget.keepLineSize,
                textStyle: widget.calendarTextStyle,
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _monthPageController!.dispose();
    _monthViewCurrentPage.dispose();

    if (widget.controller == null) {
      _controller.dispose();
    }

    super.dispose();
  }

  void _handleWeekDateChanged(DateTime date) {
    _handleDateChanged(date);

    _monthViewCurrentPage.value = _monthRangeList.lastIndexWhere((monthRange) => monthRange.dates.contains(date));
    if (widget.onTapDayInWeek != null) {
      widget.onTapDayInWeek?.call(date);
    }
  }

  void _handleDateChanged(DateTime date) {
    _controller.value = date;
  }

  void _handleFinishDrag() async {
    _captureOffset = null;

    if (_animationController.value > 0.5) {
      await _animationController.forward();
      _animationValue = 1.0;
    } else {
      await _animationController.reverse();
      _animationValue = 0.0;
    }
  }

  void _handleTodayPressed() {
    _controller.value = DateTime.now();
    firstWeek = getFirstWeek(date: DateTime.now().toZeroTime());
    lastWeek = getLastWeek(date: DateTime.now().toZeroTime());
    widget.getFirstAndLastWeek.call(
      firstWeek,
      lastWeek,
    );
    currentPageWeek = _weekPageController?.initialPage ?? 10;
    _weekRangeList = _controller.value.generateWeeks(
      widget.preloadWeekViewAmount,
      startWeekDay: widget.startWeekDay,
    );
    setState(() {});
  }

  void _handlePrevPressed() {
    final isMonthView = _animationController.value >= 0.5;

    if (isMonthView) {
      _monthPageController?.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _weekPageController?.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleNextPressed() {
    final isMonthView = _animationController.value >= 0.5;

    if (isMonthView) {
      _monthPageController!.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _weekPageController!.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  ScrollPhysics _closeMonthScroll() {
    if ((_monthViewCurrentPage.value == (widget.preloadMonthViewAmount ~/ 2) + 3 ||
        _monthViewCurrentPage.value == (widget.preloadMonthViewAmount ~/ 2) - 3)) {
      return const NeverScrollableScrollPhysics();
    } else {
      return const AlwaysScrollableScrollPhysics();
    }
  }

  static DateTime getFirstWeek({DateTime? date}) {
    final now = date ?? DateTime.now();
    final format = DateFormat("EEEE", "vi").format(now);
    int number = 0;
    switch (format) {
      case "Thứ Hai":
        number = 0;
        break;
      case "Thứ Ba":
        number = 1;
        break;
      case "Thứ Tư":
        number = 2;
        break;
      case "Thứ Năm":
        number = 3;
        break;
      case "Thứ Sáu":
        number = 4;
        break;
      case "Thứ Bảy":
        number = 5;
        break;
      default:
        number = 6;
        break;
    }
    return DateTime(now.year, now.month, now.day - number);
  }

  static DateTime getLastWeek({DateTime? date}) {
    final now = date ?? DateTime.now();
    final format = DateFormat("EEEE", "vi").format(now);
    int number = 0;
    switch (format) {
      case "Thứ Hai":
        number = 6;
        break;
      case "Thứ Ba":
        number = 5;
        break;
      case "Thứ Tư":
        number = 4;
        break;
      case "Thứ Năm":
        number = 3;
        break;
      case "Thứ Sáu":
        number = 2;
        break;
      case "Thứ Bảy":
        number = 1;
        break;
      default:
        number = 0;
        break;
    }
    return DateTime(now.year, now.month, now.day + number);
  }

  void handleSelectWeekInCalendar() {
    // if (widget.weekDates == null || widget.weekDates!.isEmpty) return;

    if (_isDropdownOpen) {
      _closeDropdown();
      return;
    }

    final RenderBox? renderBox = _datePickerKey.currentContext?.findRenderObject() as RenderBox?;
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
        child: ColoredBox(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned(
                left: leftPosition,
                top: offset.dy + size.height + 4.h,
                child: Material(
                  elevation: 8,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(12),
                  ).r,
                  color: Colors.white,
                  child: DatePickerDropdown(
                    initialDate: firstWeek,
                    startWeekDay: 1,
                    onDateSelected: (date) {
                      _controller.value = date;
                      firstWeek = getFirstWeek(date: date);
                      lastWeek = getLastWeek(date: date);
                      widget.getFirstAndLastWeek.call(
                        firstWeek,
                        lastWeek,
                      );
                      _closeDropdown();
                      currentPageWeek = _weekPageController?.initialPage ?? 10;
                      _weekRangeList = _controller.value.generateWeeks(
                        widget.preloadWeekViewAmount,
                        startWeekDay: widget.startWeekDay,
                      );
                      setState(() {});
                    },
                    onClose: _closeDropdown,
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

  void _closeDropdown() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      _isDropdownOpen = false;
    }
  }
}
