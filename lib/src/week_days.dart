part of 'widget.dart';

/// Week day names line.
class WeekDays extends StatelessWidget {
  const WeekDays({
    super.key,
    this.weekNames = const <String>['THỨ 2', 'THỨ 3', 'THỨ 4', 'THỨ 5', 'THỨ 6', 'THỨ 7', 'CN'],
    this.style,
    required this.keepLineSize,
  }) : assert(weekNames.length == 7, '`weekNames` must have length 7');

  /// Week day names.
  final List<String> weekNames;

  /// Text style.
  final TextStyle? style;

  final bool keepLineSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: List.generate(
        weekNames.length,
        (index) {
          final isSunday = index == 6;
          return Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              decoration: BoxDecoration(
                color: isSunday ? const Color(0xFFfef2f2) : const Color(0xffeff6ff),
                // borderRadius: const BorderRadius.vertical(
                //   top: Radius.circular(8),
                // ).r,
              ),
              child: Text(
                weekNames[index],
                style: style?.copyWith(
                      color: isSunday ? const Color(0xffef4444) : const Color(0xFF3b82f6), // Blue for other days
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                    ) ??
                    TextStyle(
                      color: isSunday ? const Color(0xffef4444) : const Color(0xFF3b82f6),
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }
}
