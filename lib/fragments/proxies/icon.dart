import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupIconSetting extends StatelessWidget {
  const GroupIconSetting({super.key});

  _handleAdd() async {
    final value = await globalState.showCommonDialog<MapEntry<String, String>>(
      child: AddDialog(
        defaultKey: "",
        defaultValue: "",
        title: "图标配置",
      ),
    );
    print(value);
  }

  @override
  Widget build(BuildContext context) {
    return FloatLayout(
      floatingWidget: FloatWrapper(
        child: FloatingActionButton(
          onPressed: _handleAdd,
          child: const Icon(Icons.add),
        ),
      ),
      child: Selector<Config, Map<String, String>>(
        selector: (_, config) => config.proxiesStyle.iconMap,
        shouldRebuild: (prev, next) =>
            !stringAndStringMapEquality.equals(prev, next),
        builder: (_, iconMap, __) {
          final entries = iconMap.entries.toList();
          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (_, index) {
              final item = entries[index];
              return ListItem(
                title: Text(item.key),
                subtitle: Column(
                  children: [
                    Text(item.value),
                  ],
                ),
                onTap: () {},
              );
            },
          );
        },
      ),
    );
  }
}
