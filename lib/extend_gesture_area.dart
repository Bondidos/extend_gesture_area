library extend_gesture_area;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class _ExtendGestureAreaValues extends InheritedWidget {
  const _ExtendGestureAreaValues({
    required this.globalStartingPoint,
    required this.viewSize,
    required this.extendedTapArea,
    required this.setGestureAreaValues,
    required super.child,
  });

  final Offset? globalStartingPoint;
  final Size? viewSize;
  final double? extendedTapArea;
  final void Function(
    Offset? newStartingPoint,
    Size? newViewSize,
    double? newTapPadding,
  ) setGestureAreaValues;

  static _ExtendGestureAreaValues? of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_ExtendGestureAreaValues>();

  @override
  bool updateShouldNotify(covariant _ExtendGestureAreaValues oldWidget) {
    return oldWidget.globalStartingPoint != globalStartingPoint ||
        oldWidget.viewSize != viewSize ||
        oldWidget.extendedTapArea != extendedTapArea;
  }
}

class ExtendGestureAreaDetector extends StatefulWidget {
  const ExtendGestureAreaDetector({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<ExtendGestureAreaDetector> createState() => _ExtendGestureAreaDetectorState();
}

class _ExtendGestureAreaDetectorState extends State<ExtendGestureAreaDetector> {
  Offset? _startingPoint;
  Size? _viewSize;
  double? _tapPadding;

  void setValues(
    Offset? newStartingPoint,
    Size? newViewSize,
    double? newTapPadding,
  ) {
    setState(() {
      _startingPoint = newStartingPoint ?? _startingPoint;
      _viewSize = newViewSize ?? _viewSize;
      _tapPadding = newTapPadding ?? _tapPadding;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _ExtendGestureAreaValues(
      globalStartingPoint: _startingPoint,
      viewSize: _viewSize,
      extendedTapArea: _tapPadding,
      setGestureAreaValues: setValues,
      child: _ExtendGestureAreaRenderObjectWidget(
        child: widget.child,
      ),
    );
  }
}

class _ExtendGestureAreaRenderObjectWidget extends SingleChildRenderObjectWidget {
  _ExtendGestureAreaRenderObjectWidget({
    required Widget super.child,
  });

  final _ExtendGestureAreaRenderBox _renderBox = _ExtendGestureAreaRenderBox();

  @override
  RenderObject createRenderObject(BuildContext context) => _renderBox;

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _ExtendGestureAreaRenderBox renderObject,
  ) {
    final customGestureAreaValues = _ExtendGestureAreaValues.of(context);

    renderObject
      ..extendedTapArea = customGestureAreaValues?.extendedTapArea
      ..viewSize = customGestureAreaValues?.viewSize
      ..globalStartingPoint = customGestureAreaValues?.globalStartingPoint;
  }
}

class _ExtendGestureAreaRenderBox extends RenderBox with RenderObjectWithChildMixin<RenderBox> {
  Offset? globalStartingPoint;
  Size? viewSize;
  double? extendedTapArea;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (globalStartingPoint != null && viewSize != null && extendedTapArea != null) {
      final hitArea = Rect.fromLTRB(
        globalStartingPoint!.dx - extendedTapArea!,
        globalStartingPoint!.dy - extendedTapArea!,
        globalStartingPoint!.dx + viewSize!.width + extendedTapArea!,
        globalStartingPoint!.dy + viewSize!.height + extendedTapArea!,
      );

      final globalTapPosition = localToGlobal(position);

      if (hitArea.contains(globalTapPosition)) {
        if (child != null) {
          final viewArea = Rect.fromLTRB(
            globalStartingPoint!.dx,
            globalStartingPoint!.dy,
            globalStartingPoint!.dx + viewSize!.width,
            globalStartingPoint!.dy + viewSize!.height,
          );

          if (viewArea.contains(globalTapPosition)) {
            return super.child!.hitTest(result, position: position);
          } else {
            final correctedHitPosition = globalToLocal(
              Offset(
                _dxPoint(globalTapPosition, viewArea),
                _dyPoint(globalTapPosition, viewArea),
              ),
            );
            return super.child!.hitTest(result, position: correctedHitPosition);
          }
        }
      }
    }
    return super.hitTest(result, position: position);
  }

  double _dxPoint(
    Offset globalTapPosition,
    Rect viewArea,
  ) {
    if (globalTapPosition.dx > viewArea.right) {
      return viewArea.right - 1;
    } else if (globalTapPosition.dx < viewArea.left) {
      return viewArea.left + 1;
    } else {
      return globalTapPosition.dx;
    }
  }

  double _dyPoint(
    Offset globalTapPosition,
    Rect viewArea,
  ) {
    if (globalTapPosition.dy > viewArea.bottom) {
      return viewArea.bottom - 1;
    } else if (globalTapPosition.dy < viewArea.top) {
      return viewArea.top + 1;
    } else {
      return globalTapPosition.dy;
    }
  }

  @override
  void performLayout() {
    if (child != null) {
      child!.layout(constraints.loosen(), parentUsesSize: true);
      size = Size(
        constraints.constrainWidth(child!.size.width),
        constraints.constrainHeight(child!.size.height),
      );
    } else {
      size = Size(
        constraints.constrainWidth(constraints.maxWidth),
        constraints.constrainHeight(constraints.minHeight),
      );
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      context.paintChild(child!, offset);
    }
  }
}

class ExtendGestureAreaConsumer extends StatefulWidget {
  const ExtendGestureAreaConsumer({
    required this.child,
    required this.gesturePadding,
    super.key,
  });

  final Widget child;
  final double gesturePadding;

  @override
  State<ExtendGestureAreaConsumer> createState() => _ExtendGestureAreaConsumerState();
}

class _ExtendGestureAreaConsumerState extends State<ExtendGestureAreaConsumer> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final startingOffset = renderBox.localToGlobal(Offset.zero);
        final size = renderBox.size;
        final ancestor = _ExtendGestureAreaValues.of(context);

        ancestor?.setGestureAreaValues(
          startingOffset,
          size,
          widget.gesturePadding,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
