import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupIconSetting extends StatelessWidget {
  const GroupIconSetting({super.key});

  _handleAddOrEdit([MapEntry<String, String>? item]) async {
    final value = await globalState.showCommonDialog<MapEntry<String, String>>(
      child: AddDialog(
        keyField: Field(
          label: appLocalizations.regExp,
          value: item?.key ?? "",
        ),
        valueField: Field(
          label: appLocalizations.icon,
          value: item?.value ?? "",
        ),
        title: appLocalizations.iconConfiguration,
      ),
    );
    if (value == null) {
      return;
    }
    final config = globalState.appController.config;
    final entries = List<MapEntry<String, String>>.from(
      config.proxiesStyle.iconMap.entries,
    );
    if (item != null) {
      final index = entries.indexWhere(
        (entry) => entry.key == item.key,
      );
      if (index != -1) {
        entries[index] = value;
      }
      entries[index] = value;
    } else {
      entries.add(value);
    }
    config.proxiesStyle = config.proxiesStyle.copyWith(
      iconMap: Map.fromEntries(entries),
    );
  }

  _handleDelete(MapEntry<String, String> item) async {
    final config = globalState.appController.config;
    config.proxiesStyle = config.proxiesStyle.copyWith(
      iconMap: Map.from(config.proxiesStyle.iconMap)..remove(item.key),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatLayout(
      floatingWidget: FloatWrapper(
        child: FloatingActionButton(
          onPressed: _handleAddOrEdit,
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
                leading: Container(
                  height: 36,
                  width: 36,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: CommonIcon(
                    src: item.value,
                    size: 24,
                  ),
                ),
                title: Text(item.key),
                subtitle: Text(
                  item.value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    _handleDelete(item);
                  },
                ),
                onTap: () {
                  _handleAddOrEdit(item);
                },
              );
            },
          );
        },
      ),
    );
  }
}
