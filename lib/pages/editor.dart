import 'package:fl_clash/common/app_localizations.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/widgets/scaffold.dart';
import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/yaml.dart';
import 'package:re_highlight/styles/atom-one-light.dart';

typedef EditingValueChangeBuilder = Widget Function(CodeLineEditingValue value);

class EditorPage extends StatefulWidget {
  final String title;
  final String content;
  final Function(BuildContext context, String text)? onSave;
  final Future<bool> Function(BuildContext context, String text)? onPop;

  const EditorPage({
    super.key,
    required this.title,
    required this.content,
    this.onSave,
    this.onPop,
  });

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  late CodeLineEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CodeLineEditingController.fromText(widget.content);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _wrapController(EditingValueChangeBuilder builder) {
    return ValueListenableBuilder(
      valueListenable: _controller,
      builder: (_, value, ___) {
        return builder(value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (widget.onPop != null) {
          final res = await widget.onPop!(context, _controller.text);
          if (res && context.mounted) {
            Navigator.of(context).pop();
          }
          return;
        }
        Navigator.of(context).pop();
      },
      child: CommonScaffold(
        actions: [
          _wrapController(
            (value) => IconButton(
              onPressed: _controller.canUndo ? _controller.undo : null,
              icon: const Icon(Icons.undo),
            ),
          ),
          _wrapController(
            (value) => IconButton(
              onPressed: _controller.canRedo ? _controller.redo : null,
              icon: const Icon(Icons.redo),
            ),
          ),
          if (widget.onSave != null)
            _wrapController(
              (value) => IconButton(
                onPressed: _controller.text == widget.content
                    ? null
                    : () {
                        widget.onSave!(context, _controller.text);
                      },
                icon: const Icon(Icons.save_sharp),
              ),
            ),
        ],
        body: CodeEditor(
          scrollbarBuilder: (context, child, details) {
            return Scrollbar(
              controller: details.controller,
              thickness: 8,
              radius: const Radius.circular(2),
              interactive: true,
              child: child,
            );
          },
          toolbarController: ContextMenuControllerImpl(),
          indicatorBuilder: (
            context,
            editingController,
            chunkController,
            notifier,
          ) {
            return Row(
              children: [
                DefaultCodeLineNumber(
                  controller: editingController,
                  notifier: notifier,
                ),
                DefaultCodeChunkIndicator(
                  width: 20,
                  controller: chunkController,
                  notifier: notifier,
                )
              ],
            );
          },
          controller: _controller,
          style: CodeEditorStyle(
            fontSize: 14,
            codeTheme: CodeHighlightTheme(
              languages: {
                'yaml': CodeHighlightThemeMode(
                  mode: langYaml,
                )
              },
              theme: atomOneLightTheme,
            ),
          ),
        ),
        title: widget.title,
      ),
    );
  }
}

class TextSelectionToolbarItemData {
  const TextSelectionToolbarItemData({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;
}

class ContextMenuControllerImpl implements SelectionToolbarController {
  OverlayEntry? _overlayEntry;
  bool _isFirstRender = true;

  _removeOverLayEntry() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isFirstRender = true;
  }

  @override
  void hide(BuildContext context) {
    _removeOverLayEntry();
  }

  @override
  void show({
    required context,
    required controller,
    required anchors,
    renderRect,
    required layerLink,
    required ValueNotifier<bool> visibility,
  }) {
    _removeOverLayEntry();
    final isNotEmpty = controller.selectedText.isNotEmpty;
    List<TextSelectionToolbarItemData> menus = [
      if (isNotEmpty) ...[
        TextSelectionToolbarItemData(
          label: appLocalizations.cut,
          onPressed: controller.cut,
        ),
        TextSelectionToolbarItemData(
          label: appLocalizations.copy,
          onPressed: controller.copy,
        ),
      ],
      TextSelectionToolbarItemData(
        label: appLocalizations.paste,
        onPressed: controller.paste,
      )
    ];
    _overlayEntry ??= OverlayEntry(
      builder: (context) => CodeEditorTapRegion(
        child: ValueListenableBuilder(
          valueListenable: controller,
          builder: (_, __, child) {
            if (_isFirstRender) {
              _isFirstRender = false;
            } else if (controller.selectedText.isEmpty) {
              _removeOverLayEntry();
            }
            return child!;
          },
          child: TextSelectionToolbar(
            anchorAbove: anchors.primaryAnchor,
            anchorBelow: anchors.secondaryAnchor ?? Offset.zero,
            children: menus.asMap().entries.map(
              (MapEntry<int, TextSelectionToolbarItemData> entry) {
                return TextSelectionToolbarTextButton(
                  padding: TextSelectionToolbarTextButton.getPadding(
                    entry.key,
                    menus.length,
                  ),
                  alignment: AlignmentDirectional.centerStart,
                  onPressed: () {
                    entry.value.onPressed();
                  },
                  child: Text(entry.value.label),
                );
              },
            ).toList(),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }
}
