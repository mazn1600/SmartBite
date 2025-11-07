import 'dart:async';
import 'package:flutter/material.dart';

class AppRefreshWrapper extends StatefulWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? indicatorColor;
  final Color? backgroundColor;
  final bool enabled;

  const AppRefreshWrapper({
    super.key,
    required this.onRefresh,
    required this.child,
    this.padding,
    this.indicatorColor,
    this.backgroundColor,
    this.enabled = true,
  });

  @override
  State<AppRefreshWrapper> createState() => _AppRefreshWrapperState();
}

class _AppRefreshWrapperState extends State<AppRefreshWrapper> {
  bool _isRefreshing = false;
  DateTime _lastRefreshAt = DateTime.fromMillisecondsSinceEpoch(0);

  Future<void> _guardedRefresh() async {
    if (!mounted || !widget.enabled) return;
    // Debounce refreshes within 800ms
    final now = DateTime.now();
    if (now.difference(_lastRefreshAt).inMilliseconds < 800) return;

    if (_isRefreshing) return;
    _isRefreshing = true;
    _lastRefreshAt = now;
    try {
      await widget.onRefresh();
    } catch (_) {
      // Swallow errors; UI should surface via SnackBar if needed
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  // Only allow pull-to-refresh when primary scrollable is at top and depth==0
  bool _notificationPredicate(ScrollNotification notification) {
    if (!widget.enabled) return false;
    final metrics = notification.metrics;
    // Only root scrollables
    if (notification.depth != 0) return false;
    // Only when at top
    if (metrics.extentBefore > 0) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.padding != null
        ? Padding(padding: widget.padding!, child: widget.child)
        : widget.child;

    return RefreshIndicator(
      color: widget.indicatorColor,
      backgroundColor: widget.backgroundColor,
      onRefresh: _guardedRefresh,
      notificationPredicate: _notificationPredicate,
      child: child,
    );
  }
}
