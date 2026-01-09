part of 'widget.dart';

class Header extends StatelessWidget {
  const Header({
    super.key,
    required this.monthDate,
    this.margin,
    this.onPressed,
    this.dateStyle,
    this.todayStyle,
    this.child,
    this.title,
    this.showToday = true,
  });

  final DateTime monthDate;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onPressed;
  final TextStyle? dateStyle;
  final TextStyle? todayStyle;
  final bool showToday;

  /// The child to display in the header (for navigation arrows).
  final Widget? child;
  final Widget? title;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (title != null) title!,
        const Spacer(),
        if (child != null) child!,
        if (child != null && showToday == true) 4.horizontalSpace,
        if (showToday == true)
          InkWell(
            onTap: onPressed,
            borderRadius: const BorderRadius.all(
              Radius.circular(4),
            ).r,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
              ).r,
              child: Text(
                'H.nay',
                style: todayStyle ??
                    TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ),
      ],
    );
  }
}
