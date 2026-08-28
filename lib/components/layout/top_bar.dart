import 'package:flutter/cupertino.dart';
import 'package:lorofy/components/ui/sound_clickable.dart';

class TopBar extends StatelessWidget {
  final VoidCallback? onBackPressed;

  const TopBar({super.key, this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: AppBackButton(onPressed: onBackPressed),
    );
  }
}
