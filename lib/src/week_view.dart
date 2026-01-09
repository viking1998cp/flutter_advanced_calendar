part of 'widget.dart';

class WeekView extends StatelessWidget {
  WeekView({
    super.key,
    required this.dates,
    required this.selectedDate,
    required this.lineHeight,
    this.highlightMonth,
    this.onChanged,
    this.events,
    this.eventMap,
    required this.innerDot,
    required this.keepLineSize,
    this.textStyle,
  });

  final DateTime todayDate = DateTime.now().toZeroTime();
  final List<DateTime> dates;
  final double lineHeight;
  final int? highlightMonth;
  final DateTime selectedDate;
  final ValueChanged<DateTime>? onChanged;
  final List<DateTime>? events;
  final Map<DateTime, CalendarModel>? eventMap;
  final bool innerDot;
  final bool keepLineSize;
  final TextStyle? textStyle;

  // Helper function to generate event icons based on date
  List<Widget> _getEventIcons(DateTime date, bool isSelected) {
    final icons = <Widget>[];
    final dayOfMonth = date.day;

    // Example: Add different icons for different dates (based on image)
    if (dayOfMonth == 11) {
      // Red bookmark icon (top-right)
      icons.add(
        Container(
          width: 10.w,
          height: 10.h,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
      );
    } else if (dayOfMonth == 13) {
      // Blue star (top-right)
      icons.add(
        Container(
          width: 8.w,
          height: 8.h,
          decoration: const BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
        ),
      );
    }

    return icons;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: lineHeight,
      child: Row(
        children: List<Widget>.generate(
          7,
          (dayIndex) {
            final date = dates[dayIndex];
            final isToday = date.isAtSameMomentAs(todayDate);
            final isSelected = date.isAtSameMomentAs(selectedDate);

            final hasEvent = events != null && events!.any((element) => element.isSameDate(date));

            // Get calendar events for this date
            final dateEvents = eventMap != null ? eventMap![date.toZeroTime()] ?? const CalendarModel() : const CalendarModel();

            final eventIcons = _getEventIcons(date, isSelected);

            if (keepLineSize) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: dayIndex == 0 ? 0 : 2.w,
                    right: dayIndex == 7 ? 0 : 2.w,
                  ),
                  child: InkWell(
                    onTap: onChanged != null ? () => onChanged!(date) : null,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(8),
                    ).r,
                    child: Container(
                      constraints: BoxConstraints(
                        minHeight: 80.h,
                        maxHeight: double.infinity,
                      ),
                      padding: const EdgeInsets.all(
                        8,
                      ).r,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(8),
                        ).r,
                        border: isToday
                            ? Border.all(
                                color: const Color(0xff22c55e),
                                width: 1.w,
                              )
                            : Border.all(
                                color: const Color(0xffe5e7eb),
                                width: 1.w,
                              ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${date.day}',
                            style: textStyle?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.sp,
                                ) ??
                                TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.sp,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          8.verticalSpace,
                          Spacer(),
                          if (dateEvents.overdue?.count != null && dateEvents.overdue?.count != 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 1,
                              ).r,
                              decoration: BoxDecoration(
                                color: dateEvents.overdue?.bgColor != null && (dateEvents.overdue?.count != null && dateEvents.overdue?.count != 0)
                                    ? Color(
                                        int.parse(
                                          "ff${dateEvents.overdue?.bgColor?.replaceAll("#", "")}",
                                          radix: 16,
                                        ),
                                      )
                                    : Colors.transparent,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(6),
                                ).r,
                              ),
                              child: Text(
                                dateEvents.overdue?.count != null && dateEvents.overdue?.count != 0 ? "${dateEvents.overdue?.count}" : "",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          if ((dateEvents.overdue?.count != null && dateEvents.overdue?.count != 0) &&
                              (dateEvents.returned?.count != null && dateEvents.returned?.count != 0))
                            2.verticalSpace,
                          if (dateEvents.returned?.count != null && dateEvents.returned?.count != 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 1,
                              ).r,
                              decoration: BoxDecoration(
                                color: dateEvents.returned?.bgColor != null && (dateEvents.returned?.count != null && dateEvents.returned?.count != 0)
                                    ? Color(
                                        int.parse(
                                          "ff${dateEvents.returned?.bgColor?.replaceAll("#", "")}",
                                          radix: 16,
                                        ),
                                      )
                                    : Colors.transparent,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(6),
                                ).r,
                              ),
                              child: Text(
                                dateEvents.returned?.count?.toString() ?? "",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          if ((dateEvents.returned?.count != null && dateEvents.returned?.count != 0) &&
                              (dateEvents.done?.count != null && dateEvents.done?.count != 0))
                            2.verticalSpace,
                          if (dateEvents.done?.count != null && dateEvents.done?.count != 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 1,
                              ).r,
                              decoration: BoxDecoration(
                                color: dateEvents.done?.bgColor != null && (dateEvents.done?.count != null && dateEvents.done?.count != 0)
                                    ? Color(
                                        int.parse(
                                          "ff${dateEvents.done?.bgColor?.replaceAll("#", "")}",
                                          radix: 16,
                                        ),
                                      )
                                    : Colors.transparent,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(6),
                                ).r,
                              ),
                              child: Text(
                                dateEvents.done?.count?.toString() ?? "",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
            return Expanded(
              child: DateBox(
                width: innerDot ? 32.w : 40.w,
                height: innerDot ? 32.h : 48.h,
                showDot: innerDot,
                onPressed: onChanged != null ? () => onChanged!(date) : null,
                isSelected: isSelected,
                isToday: isToday,
                hasEvent: hasEvent,
                eventIcons: eventIcons.isNotEmpty ? eventIcons : null,
                child: Text(
                  '${date.day}',
                  maxLines: 1,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            );
          },
          growable: false,
        ),
      ),
    );
  }
}
