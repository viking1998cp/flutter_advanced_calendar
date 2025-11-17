part of 'widget.dart';

/// Week day names line.
class WeekDays extends StatelessWidget {
  const WeekDays({
    Key? key,
    this.weekNames = const <String>['S', 'M', 'T', 'W', 'T', 'F', 'S'],
    this.style,
    required this.keepLineSize,
  })  : assert(weekNames.length == 7, '`weekNames` must have length 7'),
        super(key: key);

  /// Week day names.
  final List<String> weekNames;

  /// Text style.
  final TextStyle? style;

  final bool keepLineSize;

  @override
  Widget build(BuildContext context) {
    // Vietnamese day names
    final vietnameseDays = ['HAI', 'BA', 'TƯ', 'NĂM', 'SÁU', 'BẢY', 'CN'];
    
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(weekNames.length, (index) {
        final isSunday = index == 6; // CN is Sunday
        return Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 2.h),
            decoration: BoxDecoration(
              color: isSunday ? const Color(0xFFFFE5E5) : Colors.blue[50],
              // borderRadius: BorderRadius.circular(4.r),
            ),
            child: Center(
              child: Text(
                vietnameseDays[index],
                style: style?.copyWith(
                  color: isSunday 
                      ? Colors.red 
                      : const Color(0xFF2196F3), // Blue for other days
                  fontWeight: FontWeight.w500,
                  fontSize: 13.sp,
                ) ?? TextStyle(
                  color: isSunday 
                      ? Colors.red 
                      : const Color(0xFF2196F3),
                  fontWeight: FontWeight.w500,
                  fontSize: 13.sp,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
