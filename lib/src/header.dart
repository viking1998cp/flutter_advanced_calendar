part of 'widget.dart';

class Header extends StatelessWidget {
  const Header({
    Key? key,
    required this.monthDate,
    this.margin,
    this.onPressed,
    this.dateStyle,
    this.todayStyle,
    this.child,
  }) : super(key: key);

  static final _dateFormatter = DateFormat().add_yMMMM();
  final DateTime monthDate;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onPressed;
  final TextStyle? dateStyle;
  final TextStyle? todayStyle;

  /// The child to display in the header (for navigation arrows).
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: margin ?? EdgeInsets.only(
        left: 16.w,
        right: 8.w,
        top: 4.h,
        bottom: 4.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _dateFormatter.format(monthDate),
            style: dateStyle ?? theme.textTheme.titleMedium,
          ),
          if (child != null) child!,
          const Spacer(),
          InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.all(
              Radius.circular(4.r),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 8.w,
                vertical: 4.h,
              ),
              child: Text(
                'Today',
                style: todayStyle ?? theme.textTheme.titleMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
