part of 'widget.dart';

class HandleBar extends StatelessWidget {
  const HandleBar({
    Key? key,
    this.decoration,
    this.margin,
    this.onPressed,
  }) : super(key: key);

  final BoxDecoration? decoration;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.translucent,
      child: Container(
        margin: margin ?? EdgeInsets.only(
          top: 8.h,
        ),
        alignment: Alignment.center,
        child: FractionallySizedBox(
          widthFactor: 0.1,
          child: Container(
            height: 4.h,
            decoration: decoration ??
                BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2.r),
                ),
          ),
        ),
      ),
    );
  }
}
