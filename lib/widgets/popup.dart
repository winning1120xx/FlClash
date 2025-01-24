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
    return ValueListenableBuilder(
      valueListenable: offsetNotifier,
      builder: (_, value, child) {
        return Align(
          alignment: align,
          child: CustomSingleChildLayout(
            delegate: OverflowAwareLayoutDelegate(
              offset: value.translate(20, -20),
            ),
            child: child!,
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
                offset: Offset(0, 20) * animationValue,
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
  Offset pointerOffset = Offset.zero;
  final _targetOffsetValueNotifier = ValueNotifier(Offset.zero);

  _handleTargetOffset() {
    final renderBox =
        _targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return;
    }
    _targetOffsetValueNotifier.value =
        renderBox.localToGlobal(Offset.zero) + pointerOffset;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (details) {
        pointerOffset = details.localPosition;
        _handleTargetOffset();
        Navigator.of(context).push(
          CommonPopupRoute(
            barrierLabel: other.id,
            builder: (BuildContext context) {
              return widget.popup;
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

  OverflowAwareLayoutDelegate({required this.offset});

  @override
  Size getSize(BoxConstraints constraints) {
    return Size(constraints.maxWidth, constraints.maxHeight);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double x = (offset.dx - childSize.width).clamp(
      0,
      size.width - childSize.width,
    );
    double y = (offset.dy).clamp(
      0,
      size.height - childSize.height - 40,
    );
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(covariant OverflowAwareLayoutDelegate oldDelegate) {
    return oldDelegate.offset != offset;
  }
}

void main() => runApp(const PopupMenuApp());

class PopupMenuApp extends StatelessWidget {
  const PopupMenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PopupMenuExample(),
    );
  }
}

class PopupMenuExample extends StatefulWidget {
  const PopupMenuExample({super.key});

  @override
  State<PopupMenuExample> createState() => _PopupMenuExampleState();
}

class _PopupMenuExampleState extends State<PopupMenuExample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PopupMenuButton')),
      body: Center(
        child: CommonPopupBox(
          target: FilledButton(
            onPressed: () {},
            child: Text("点击我"),
          ),
          popup: Card(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Text("编辑"),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Text("更新"),
                  ),
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Text("删除"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
