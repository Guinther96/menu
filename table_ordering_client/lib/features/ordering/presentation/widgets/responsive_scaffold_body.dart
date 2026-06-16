import 'package:flutter/material.dart';

class ResponsiveScaffoldBody extends StatelessWidget {
  const ResponsiveScaffoldBody({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 700;

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isTablet ? 760 : 560),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
