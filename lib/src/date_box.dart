part of 'widget.dart';

/// Unit of calendar.
class DateBox extends StatelessWidget {
  const DateBox({
    Key? key,
    required this.child,
    this.color,
    this.width = 24.0,
    this.height = 24.0,
    this.borderRadius,
    this.onPressed,
    this.showDot = false,
    this.isSelected = false,
    this.isToday = false,
    this.hasEvent = false,
    this.eventIcons,
  }) : super(key: key);

  /// Child widget.
  final Widget child;

  /// Background color.
  final Color? color;

  /// Widget width.
  final double width;

  /// Widget height.
  final double height;

  /// Container border radius.
  final BorderRadius? borderRadius;

  /// Pressed callback function.
  final VoidCallback? onPressed;

  /// Show DateBox event in container.
  final bool showDot;

  /// DateBox is today.
  final bool isToday;

  /// DateBox selection.
  final bool isSelected;

  /// Show event in DateBox.
  final bool hasEvent;

  /// Event icons to display
  final List<Widget>? eventIcons;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return UnconstrainedBox(
      alignment: Alignment.center,
      child: InkResponse(
        onTap: onPressed,
        radius: 16.r,
        borderRadius: borderRadius ?? BorderRadius.circular(8.r),
        highlightShape: BoxShape.rectangle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF5F5F5) : Colors.white,
            borderRadius: borderRadius ?? BorderRadius.circular(12.r),
            border: isSelected
                ? Border.all(
                    color: Colors.green,
                    width: 2.w,
                  )
                : Border.all(
                    color: Colors.transparent,
                    width: 2.w,
                  ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4.r,
                      offset: Offset(0, 2.h),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              // Primary date (solar calendar)
              Center(child: child),
              // Event icons positioned at top-right
              if (eventIcons != null && eventIcons!.isNotEmpty)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: eventIcons!.take(2).toList(),
                  ),
                ),
              if (showDot && hasEvent && eventIcons == null)
                Positioned(
                  bottom: 2.h,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      height: 4.h,
                      width: 4.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? Colors.green
                            : theme.colorScheme.secondary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
