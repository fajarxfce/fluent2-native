import 'package:flutter/material.dart';

import '../theme/fluent_icon_type.dart';
import '../theme/fluent_theme.dart';
import 'button.dart';
import 'feedback.dart';
import 'typography.dart';

/// Returns true only after successful confirmation. While [onConfirm] is in
/// flight, duplicate submissions and all dismissal paths are blocked.
Future<bool> showFluentDialog({
  required BuildContext context,
  required String title,
  required WidgetBuilder builder,
  Future<void> Function()? onConfirm,
  String confirmText = 'OK',
  String cancelText = 'Cancel',
  String closeLabel = 'Close dialog',
  bool danger = false,
  bool dismissible = true,
  String Function(Object error)? errorMessage,
}) async =>
    await showDialog<bool>(
      context: context,
      barrierDismissible: dismissible,
      barrierColor: FluentTheme.tokensOf(context).colorBackgroundOverlay,
      builder: (context) => _FluentModal(
        title: title,
        builder: builder,
        onConfirm: onConfirm,
        confirmText: confirmText,
        cancelText: cancelText,
        closeLabel: closeLabel,
        danger: danger,
        dismissible: dismissible,
        errorMessage: errorMessage,
      ),
    ) ??
    false;

class _FluentModal extends StatefulWidget {
  const _FluentModal({
    required this.title,
    required this.builder,
    required this.onConfirm,
    required this.confirmText,
    required this.cancelText,
    required this.closeLabel,
    required this.danger,
    required this.dismissible,
    required this.errorMessage,
  });
  final String title, confirmText, cancelText, closeLabel;
  final WidgetBuilder builder;
  final Future<void> Function()? onConfirm;
  final bool danger, dismissible;
  final String Function(Object error)? errorMessage;
  @override
  State<_FluentModal> createState() => _FluentModalState();
}

class _FluentModalState extends State<_FluentModal> {
  bool _loading = false;
  String? _error;

  Future<void> _confirm() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.onConfirm?.call();
      if (mounted) {
        setState(() => _loading = false);
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error =
              widget.errorMessage?.call(error) ??
              'Something went wrong. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = FluentTheme.tokensOf(context);
    return PopScope(
      canPop: !_loading && widget.dismissible,
      child: Dialog(
        backgroundColor: t.colorNeutralBackground1,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(t.borderRadiusXLarge),
        ),
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 520,
            maxHeight: MediaQuery.sizeOf(context).height * 0.85,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: FluentTitle(widget.title, level: 5)),
                    FluentButton(
                      type: FluentButtonType.subtle,
                      semanticLabel: widget.closeLabel,
                      onPressed: _loading
                          ? null
                          : () => Navigator.of(context).pop(false),
                      child: const FluentIcon(FluentIconType.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(child: widget.builder(context)),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  FluentMessageBar(message: _error!, type: FluentStatus.error),
                ],
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FluentButton(
                      onPressed: _loading
                          ? null
                          : () => Navigator.of(context).pop(false),
                      child: FluentText(widget.cancelText),
                    ),
                    FluentButton(
                      type: FluentButtonType.primary,
                      onPressed: _confirm,
                      loading: _loading,
                      danger: widget.danger,
                      child: FluentText(widget.confirmText),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
