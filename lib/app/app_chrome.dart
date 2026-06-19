import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const controlRadius = 12.0;
const controlBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(controlRadius)),
  borderSide: BorderSide(color: Color(0xffd1d1d6)),
);

List<TextInputFormatter>? platformDigitOnlyInputFormatters() {
  if (kIsWeb) {
    return <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly];
  }
  return switch (defaultTargetPlatform) {
    TargetPlatform.iOS || TargetPlatform.android => <TextInputFormatter>[
      FilteringTextInputFormatter.digitsOnly,
    ],
    TargetPlatform.macOS ||
    TargetPlatform.windows ||
    TargetPlatform.linux ||
    TargetPlatform.fuchsia => null,
  };
}

class ResponsiveFormGrid extends StatelessWidget {
  const ResponsiveFormGrid({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 260 ? 2 : 1;
        final spacing = columns == 1 ? 0.0 : 6.0;
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: 8,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}

class Surface extends StatefulWidget {
  const Surface({required this.child, super.key});

  final Widget child;

  @override
  State<Surface> createState() => _SurfaceState();
}

class _SurfaceState extends State<Surface> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: _hovered ? const Color(0xfffbfdfe) : Colors.white,
          border: Border.all(
            color: _hovered ? colorScheme.primary : colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(controlRadius),
          boxShadow: [
            if (_hovered)
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}
