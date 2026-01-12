part of 'widget.dart';

class WeekView extends StatelessWidget {
  WeekView({
    Key? key,
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
  }) : super(key: key);

  final DateTime todayDate = DateTime.now().toZeroTime();
  final List<DateTime> dates;
  final double lineHeight;
  final int? highlightMonth;
  final DateTime selectedDate;
  final ValueChanged<DateTime>? onChanged;
  final List<DateTime>? events;
  final Map<DateTime, List<CalendarEvent>>? eventMap;
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
          decoration: BoxDecoration(
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
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: lineHeight,
        maxHeight: keepLineSize ? double.infinity : lineHeight,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List<Widget>.generate(
          7,
          (dayIndex) {
            final date = dates[dayIndex];
            final isToday = date.isAtSameMomentAs(todayDate);
            final isSelected = date.isAtSameMomentAs(selectedDate);

            final hasEvent = events != null &&
                events!.any((element) => element.isSameDate(date));

            // Get calendar events for this date
            final dateEvents = eventMap != null
                ? eventMap!.entries
                    .where((entry) {
                      final entryDate = entry.key.toZeroTime();
                      final currentDate = date.toZeroTime();
                      return entryDate.isAtSameMomentAs(currentDate);
                    })
                    .expand((entry) => entry.value)
                    .toList()
                : <CalendarEvent>[];

            final eventIcons = _getEventIcons(date, isSelected);

            if (keepLineSize) {
              return Expanded(
                child: SizedBox(
                  // padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: InkResponse(
                    onTap: onChanged != null ? () => onChanged!(date) : null,
                    child: Container(
                      alignment: Alignment.topCenter,
                      constraints: BoxConstraints(
                        minHeight: 80.h,
                        maxHeight: double.infinity,
                      ),
                      padding: EdgeInsets.symmetric(
                        // vertical: 4.h,
                        horizontal: 2.w,
                      ),
                      decoration: BoxDecoration(
                        color: isToday ? const Color(0xFFF5F5F5) : Colors.white,
                        // borderRadius: BorderRadius.circular(6.r),
                        border: isSelected
                            ? Border.all(
                                color: Colors.green,
                                width: 0.5.w,
                              )
                            : Border.all(
                                color: Colors.grey[200]!,
                                width: 0.8.w,
                              ),
                        // boxShadow: isSelected
                        //     ? [
                        //         BoxShadow(
                        //           color: Colors.black.withOpacity(0.05),
                        //           blurRadius: 4.r,
                        //           offset: Offset(0, 2.h),
                        //         ),
                        //       ]
                        //     : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Date number
                          Flexible(
                            child: Container(
                              alignment: Alignment.center,
                              child: Text(
                                '${date.day}',
                                style: textStyle?.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.sp,
                                    ) ??
                                    TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.sp,
                                    ),
                              ),
                            ),
                          ),
                          // Event buttons or placeholder
                          if (dateEvents.isNotEmpty) ...[
                            // SizedBox(height: 2.h),
                            Flexible(
                              fit: FlexFit.loose,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: dateEvents
                                    .take(4)
                                    .map((event) => Padding(
                                          padding: EdgeInsets.only(bottom: 2.h),
                                          child: Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.symmetric(
                                              vertical: 2.h,
                                              horizontal: 3.w,
                                            ),
                                            decoration: BoxDecoration(
                                              color: event.color,
                                              borderRadius:
                                                  BorderRadius.circular(6.r),
                                            ),
                                            child: Text(
                                              event.displayText,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 6.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                          ] else ...[
                            // SizedBox(height: 2.h),
                            // Placeholder icon for empty days - small empty icon
                            Flexible(
                              child: Center(
                                child: Icon(
                                  Icons.note_add,
                                  size: 12.sp,
                                  color: Colors.grey.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ],
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
