import 'package:fl_clash/common/common.dart';
import 'package:flutter/material.dart';

class CommonPopupRoute<T> extends PopupRoute<T> {
  final WidgetBuilder builder;
  ValueNotifier<Offset> offsetNotifier;

  CommonPopupRoute({
    required this.barrierLabel,
    required this.builder,
    required this.offsetNotifier,
  });

  @override
  String? barrierLabel;

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(
      context,
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final align = Alignment.topRight;
    final animationValue = CurvedAnimation(
      parent: animation,
      curve: Curves.easeIn,
    ).value;
    final double animateOffsetY = 20;
    return ValueListenableBuilder(
      valueListenable: offsetNotifier,
      builder: (_, value, child) {
        return Align(
          alignment: align,
          child: CustomSingleChildLayout(
            delegate: OverflowAwareLayoutDelegate(
              animateOffsetY: animateOffsetY,
              offset: value.translate(
                60,
                -animateOffsetY + 20,
              ),
            ),
            child: child,
          ),
        );
      },
      child: AnimatedBuilder(
        animation: animation,
        builder: (_, Widget? child) {
          return Opacity(
            opacity: 0.1 + 0.9 * animationValue,
            child: Transform.scale(
              alignment: align,
              scale: 0.8 + 0.2 * animationValue,
              child: Transform.translate(
                offset: Offset(0, animateOffsetY) * animationValue,
                child: child!,
              ),
            ),
          );
        },
        child: builder(
          context,
        ),
      ),
    );
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 150);
}

class CommonPopupBox extends StatefulWidget {
  final Widget target;
  final Widget popup;

  const CommonPopupBox({
    super.key,
    required this.target,
    required this.popup,
  });

  @override
  State<CommonPopupBox> createState() => _CommonPopupBoxState();
}

class _CommonPopupBoxState extends State<CommonPopupBox> {
  final _targetKey = GlobalKey();
  final _targetOffsetValueNotifier = ValueNotifier(Offset.zero);

  _handleTargetOffset() {
    final renderBox =
        _targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return;
    }
    _targetOffsetValueNotifier.value = renderBox.localToGlobal(Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (details) {
        _handleTargetOffset();
        Navigator.of(context).push(
          CommonPopupRoute(
            barrierLabel: other.id,
            builder: (BuildContext context) {
              return Listener(
                onPointerDown: (_) {
                  Navigator.of(context).pop();
                },
                child: widget.popup,
              );
            },
            offsetNotifier: _targetOffsetValueNotifier,
          ),
        );
      },
      key: _targetKey,
      child: LayoutBuilder(
        builder: (_, __) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) {
              _handleTargetOffset();
            },
          );
          return widget.target;
        },
      ),
    );
  }
}

class OverflowAwareLayoutDelegate extends SingleChildLayoutDelegate {
  final Offset offset;

  final double animateOffsetY;

  OverflowAwareLayoutDelegate({
    required this.offset,
    required this.animateOffsetY,
  });

  @override
  Size getSize(BoxConstraints constraints) {
    return Size(constraints.maxWidth, constraints.maxHeight);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final saveOffset = Offset(
      16,
      16,
    );
    double x = (offset.dx - childSize.width).clamp(
      0,
      size.width - saveOffset.dx - childSize.width,
    );
    double y = (offset.dy).clamp(
      0,
      size.height - saveOffset.dy - animateOffsetY - childSize.height,
    );
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(covariant OverflowAwareLayoutDelegate oldDelegate) {
    return oldDelegate.offset != offset;
  }
}
