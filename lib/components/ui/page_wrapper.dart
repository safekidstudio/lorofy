import 'package:flutter/cupertino.dart';

class PageWrapper extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final bool resizeToAvoidBottomInset;
  final EdgeInsetsGeometry padding;

  const PageWrapper({
    super.key,
    required this.child,
    this.backgroundColor = const Color(0xFFF5F5F7),
    this.resizeToAvoidBottomInset = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      child: SafeArea(
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
