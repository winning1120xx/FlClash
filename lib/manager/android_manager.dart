import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class AndroidManager extends StatefulWidget {
  final Widget child;

  const AndroidManager({
    super.key,
    required this.child,
  });

  @override
  State<AndroidManager> createState() => _AndroidContainerState();
}

class _AndroidContainerState extends State<AndroidManager> {
  @override
  void initState() {
    super.initState();
  }

  Widget _excludeContainer(Widget child) {
    return Selector<Config, bool>(
      selector: (_, config) => config.appSetting.hidden,
      builder: (_, hidden, child) {
        app?.updateExcludeFromRecents(hidden);
        return child!;
      },
      child: child,
    );
  }

  Widget _systemUiContainer(Widget child) {
    return AnnotatedRegion(
      value: SystemUiMode.edgeToEdge,
      child: AnnotatedRegion(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              Theme.of(context).brightness == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _systemUiContainer(
      _excludeContainer(widget.child),
    );
  }
}
