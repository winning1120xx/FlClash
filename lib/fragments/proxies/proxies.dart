import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/fragments/proxies/list.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers.dart';
import 'setting.dart';
import 'tab.dart';

class ProxiesFragment extends StatefulWidget {
  const ProxiesFragment({super.key});

  @override
  State<ProxiesFragment> createState() => _ProxiesFragmentState();
}

class _ProxiesFragmentState extends State<ProxiesFragment> {
  final GlobalKey<ProxiesTabFragmentState> _proxiesTabKey = GlobalKey();

  _initActions(ProxiesType proxiesType, bool hasProvider) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final commonScaffoldState =
          context.findAncestorStateOfType<CommonScaffoldState>();
      commonScaffoldState?.actions = [
        if (hasProvider) ...[
          IconButton(
            onPressed: () {
              showExtendPage(
                isScaffold: true,
                extendPageWidth: 360,
                context,
                body: const Providers(),
                title: appLocalizations.providers,
              );
            },
            icon: const Icon(
              Icons.poll_outlined,
            ),
          ),
          const SizedBox(
            width: 8,
          ),
        ],
        if (proxiesType == ProxiesType.tab) ...[
          IconButton(
            onPressed: () {
              _proxiesTabKey.currentState?.scrollToGroupSelected();
            },
            icon: const Icon(
              Icons.adjust_outlined,
            ),
          ),
          const SizedBox(
            width: 8,
          )
        ] else ...[
          IconButton(
            onPressed: () {
              showExtendPage(
                context,
                title: appLocalizations.iconConfiguration,
                body: Selector<Config, Map<String, String>>(
                  selector: (_, config) => config.proxiesStyle.iconMap,
                  shouldRebuild: (prev, next) {
                    return !stringAndStringMapEntryIterableEquality.equals(
                      prev.entries,
                      next.entries,
                    );
                  },
                  builder: (_, iconMap, __) {
                    final entries = iconMap.entries.toList();
                    return ListPage(
                      title: appLocalizations.iconConfiguration,
                      items: entries,
                      keyBuilder: (item) => Key(item.key),
                      titleBuilder: (item) => Text(item.key),
                      leadingBuilder: (item) => Container(
                        height: 48,
                        width: 48,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: context.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: CommonIcon(
                          src: item.value,
                          size: 32,
                        ),
                      ),
                      subtitleBuilder: (item) => Text(
                        item.value,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onChange: (entries) {
                        final config = globalState.appController.config;
                        config.proxiesStyle = config.proxiesStyle.copyWith(
                          iconMap: Map.fromEntries(entries),
                        );
                      },
                    );
                  },
                ),
              );
            },
            icon: const Icon(
              Icons.style_outlined,
            ),
          ),
          const SizedBox(
            width: 8,
          )
        ],
        IconButton(
          onPressed: () {
            showSheet(
              title: appLocalizations.proxiesSetting,
              context: context,
              builder: (context) {
                return const ProxiesSetting();
              },
            );
          },
          icon: const Icon(
            Icons.tune,
          ),
        )
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Selector<Config, ProxiesType>(
      selector: (_, config) => config.proxiesStyle.type,
      builder: (_, proxiesType, __) {
        return ProxiesActionsBuilder(
          builder: (state, child) {
            if (state.isCurrent) {
              _initActions(proxiesType, state.hasProvider);
            }
            return child!;
          },
          child: switch (proxiesType) {
            ProxiesType.tab => ProxiesTabFragment(
                key: _proxiesTabKey,
              ),
            ProxiesType.list => const ProxiesListFragment(),
          },
        );
      },
    );
  }
}
