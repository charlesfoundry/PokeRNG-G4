import 'package:flutter/material.dart';

class KeyboardDismissRegion extends StatefulWidget {
  const KeyboardDismissRegion({super.key, required this.child});

  final Widget child;

  @override
  State<KeyboardDismissRegion> createState() => _KeyboardDismissRegionState();
}

class _KeyboardDismissRegionState extends State<KeyboardDismissRegion> {
  static const _tapMovementTolerance = 18.0;

  Offset? _pointerDownPosition;
  bool _tapCandidate = false;

  void _resetPointerState() {
    _pointerDownPosition = null;
    _tapCandidate = false;
  }

  bool _isTapAt(Offset position) {
    final downPosition = _pointerDownPosition;
    return downPosition != null &&
        _tapCandidate &&
        (position - downPosition).distance <= _tapMovementTolerance;
  }

  bool _tapIsOutsideFocusedEditable(Offset position) {
    final focused = FocusManager.instance.primaryFocus;
    if (focused == null) {
      return false;
    }
    final context = focused.context;
    if (context == null) {
      return true;
    }
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.attached) {
      return true;
    }
    final topLeft = renderObject.localToGlobal(Offset.zero);
    final rect = topLeft & renderObject.size;
    return !rect.contains(position);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        _pointerDownPosition = event.position;
        _tapCandidate = true;
      },
      onPointerMove: (event) {
        if (!_isTapAt(event.position)) {
          _tapCandidate = false;
        }
      },
      onPointerCancel: (_) {
        _resetPointerState();
      },
      onPointerUp: (event) {
        final shouldDismiss =
            _isTapAt(event.position) &&
            _tapIsOutsideFocusedEditable(event.position);
        _resetPointerState();
        if (shouldDismiss) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: widget.child,
    );
  }
}
