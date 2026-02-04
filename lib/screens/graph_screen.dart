/// Graph view screen for visualizing notes as nodes.
///
/// Features interactive node graph with zoom controls and pan gestures.
library;

import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../themes/theme_config.dart';
import '../utils/constants.dart';
import '../widgets/empty_state.dart';

/// Graph view showing notes as interconnected nodes.
class GraphScreen extends ConsumerStatefulWidget {
  /// Callback when a node is tapped.
  final void Function(String noteId) onNodeTap;

  /// Creates a [GraphScreen] widget.
  const GraphScreen({super.key, required this.onNodeTap});

  @override
  ConsumerState<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends ConsumerState<GraphScreen> {
  double _scale = 1.0;
  Offset _offset = Offset.zero;

  // Node positions (calculated once and cached)
  Map<String, Offset> _nodePositions = {};

  // Currently selected node
  String? _selectedNodeId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final notesState = ref.watch(notesProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, isDark),

            // Graph content
            Expanded(
              child: notesState.notes.isEmpty
                  ? EmptyState(
                      icon: CupertinoIcons.graph_circle,
                      title: 'No connections yet',
                      description:
                          'Create some notes to see them visualized here.',
                    )
                  : _buildGraphView(context, notesState.notes, isDark),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the header.
  Widget _buildHeader(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(ThemeConfig.spacingMd),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button (if navigated from somewhere)
          GestureDetector(
            onTap: () {
              // Could navigate back
            },
            child: Text(
              '< ${Strings.notes}',
              style: TextStyle(
                color: ThemeConfig.primaryAccent,
                fontSize: ThemeConfig.fontSizeBody,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Title
          Text(Strings.graphView, style: theme.textTheme.headlineMedium),

          // Search button
          GestureDetector(
            onTap: () {
              // Could open search
            },
            child: Text(
              Strings.search,
              style: TextStyle(
                color: ThemeConfig.primaryAccent,
                fontSize: ThemeConfig.fontSizeBody,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the interactive graph view.
  Widget _buildGraphView(BuildContext context, List<Note> notes, bool isDark) {
    // Calculate node positions if not done yet
    if (_nodePositions.isEmpty || _nodePositions.length != notes.length + 1) {
      _calculateNodePositions(context, notes);
    }

    return Stack(
      children: [
        // Gesture detector for pan and zoom
        GestureDetector(
          onScaleStart: (details) {
            // Store initial values
          },
          onScaleUpdate: (details) {
            setState(() {
              _scale = (_scale * details.scale).clamp(0.5, 2.5);
              _offset += details.focalPointDelta;
            });
          },
          child: SizedBox.expand(
            child: CustomPaint(
              painter: _GraphPainter(
                notes: notes,
                nodePositions: _nodePositions,
                scale: _scale,
                offset: _offset,
                isDark: isDark,
                selectedNodeId: _selectedNodeId,
              ),
              child: Stack(
                children: [
                  // Index node (center)
                  _buildNode(
                    context,
                    'index',
                    'Index',
                    _nodePositions['index'] ?? Offset.zero,
                    isCenter: true,
                    isDark: isDark,
                  ),

                  // Note nodes
                  ...notes.map((note) {
                    final position = _nodePositions[note.id] ?? Offset.zero;
                    return _buildNode(
                      context,
                      note.id,
                      note.title.isEmpty ? 'Untitled' : note.title,
                      position,
                      isDark: isDark,
                      category: note.category,
                    );
                  }),
                ],
              ),
            ),
          ),
        ),

        // Zoom controls
        Positioned(
          right: ThemeConfig.spacingMd,
          bottom: ThemeConfig.spacingMd,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildZoomButton(
                context,
                icon: CupertinoIcons.add,
                onTap: () {
                  setState(() {
                    _scale = (_scale * 1.2).clamp(0.5, 2.5);
                  });
                },
                isDark: isDark,
              ),
              const SizedBox(height: ThemeConfig.spacingSm),
              _buildZoomButton(
                context,
                icon: CupertinoIcons.minus,
                onTap: () {
                  setState(() {
                    _scale = (_scale / 1.2).clamp(0.5, 2.5);
                  });
                },
                isDark: isDark,
              ),
              const SizedBox(height: ThemeConfig.spacingSm),
              _buildZoomButton(
                context,
                icon: CupertinoIcons.arrow_up_left_arrow_down_right,
                onTap: () {
                  setState(() {
                    _scale = 1.0;
                    _offset = Offset.zero;
                  });
                },
                isDark: isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Calculates positions for all nodes in a radial layout.
  void _calculateNodePositions(BuildContext context, List<Note> notes) {
    final size = MediaQuery.of(context).size;
    final center = Offset(size.width / 2, size.height / 2 - 100);

    _nodePositions = {};
    _nodePositions['index'] = center;

    // Group notes by category
    final categories = <String?, List<Note>>{};
    for (final note in notes) {
      final category = note.category ?? 'Other';
      categories.putIfAbsent(category, () => []).add(note);
    }

    // Position nodes radially
    final categoryCount = categories.length;
    var categoryIndex = 0;

    categories.forEach((category, categoryNotes) {
      final categoryAngle =
          (2 * math.pi * categoryIndex) / categoryCount - math.pi / 2;
      final categoryRadius = 150.0;

      for (var i = 0; i < categoryNotes.length; i++) {
        final note = categoryNotes[i];
        final spreadAngle = (categoryNotes.length > 1)
            ? (math.pi / 4) *
                  (i - (categoryNotes.length - 1) / 2) /
                  categoryNotes.length
            : 0.0;
        final angle = categoryAngle + spreadAngle;
        final radius = categoryRadius + (i * 30);

        _nodePositions[note.id] = Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        );
      }
      categoryIndex++;
    });
  }

  /// Builds a node widget.
  Widget _buildNode(
    BuildContext context,
    String id,
    String label,
    Offset position, {
    bool isCenter = false,
    bool isDark = false,
    String? category,
  }) {
    final transformedPosition = Offset(
      position.dx * _scale + _offset.dx,
      position.dy * _scale + _offset.dy,
    );

    final size = isCenter ? 50.0 : 30.0;
    final isSelected = _selectedNodeId == id;

    return Positioned(
      left: transformedPosition.dx - size / 2,
      top: transformedPosition.dy - size / 2,
      child: GestureDetector(
        onTap: () {
          if (id != 'index') {
            setState(() {
              _selectedNodeId = id;
            });
            widget.onNodeTap(id);
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size * _scale,
              height: size * _scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ThemeConfig.primaryAccent,
                border: isSelected
                    ? Border.all(color: Colors.white, width: 2)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: ThemeConfig.primaryAccent.withAlpha(77),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            if (label.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark
                      ? ThemeConfig.darkSurface.withAlpha(204)
                      : ThemeConfig.lightSurface.withAlpha(204),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  label.length > 15 ? '${label.substring(0, 12)}...' : label,
                  style: TextStyle(
                    fontSize: 10 * _scale,
                    color: isDark
                        ? ThemeConfig.darkTextPrimary
                        : ThemeConfig.lightTextPrimary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Builds a zoom control button.
  Widget _buildZoomButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? ThemeConfig.darkSurface : ThemeConfig.lightSurface,
          boxShadow: isDark ? null : ThemeConfig.lightCardShadow,
        ),
        child: Icon(
          icon,
          color: isDark
              ? ThemeConfig.darkTextPrimary
              : ThemeConfig.lightTextPrimary,
          size: 20,
        ),
      ),
    );
  }
}

/// Custom painter for drawing graph connections.
class _GraphPainter extends CustomPainter {
  final List<Note> notes;
  final Map<String, Offset> nodePositions;
  final double scale;
  final Offset offset;
  final bool isDark;
  final String? selectedNodeId;

  _GraphPainter({
    required this.notes,
    required this.nodePositions,
    required this.scale,
    required this.offset,
    required this.isDark,
    this.selectedNodeId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ThemeConfig.primaryAccent.withAlpha(77)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final centerPos = nodePositions['index'];
    if (centerPos == null) return;

    final transformedCenter = Offset(
      centerPos.dx * scale + offset.dx,
      centerPos.dy * scale + offset.dy,
    );

    // Draw connections from center to all nodes
    for (final note in notes) {
      final nodePos = nodePositions[note.id];
      if (nodePos == null) continue;

      final transformedNode = Offset(
        nodePos.dx * scale + offset.dx,
        nodePos.dy * scale + offset.dy,
      );

      canvas.drawLine(transformedCenter, transformedNode, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GraphPainter oldDelegate) {
    return oldDelegate.scale != scale ||
        oldDelegate.offset != offset ||
        oldDelegate.notes.length != notes.length ||
        oldDelegate.selectedNodeId != selectedNodeId;
  }
}
