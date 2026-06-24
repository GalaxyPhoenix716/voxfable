import 'dart:math';
import 'package:flutter/material.dart';
import 'package:voxfable/core/theme/colors.dart';
import 'package:voxfable/core/theme/paddings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repos/story_state.dart';
import '../../view_model/story_view_model.dart';

class StoryOverlay extends ConsumerStatefulWidget {
  final String text;
  final double rotationZ;
  final double fontSize;
  final double lineHeight;
  final double amplitude;

  const StoryOverlay({
    super.key,
    required this.text,
    this.rotationZ = 0.030,
    this.fontSize = 16,
    this.lineHeight = 27,
    this.amplitude = 9,
  });

  @override
  ConsumerState<StoryOverlay> createState() => _StoryOverlayState();
}

class _StoryOverlayState extends ConsumerState<StoryOverlay> {
  late final ScrollController _scrollController;
  int _lastActiveWordIndex = -1;
  double _lastWidth = 100.0;
  double _lastViewportHeight = 100.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  TextStyle _getNormalStyle() {
    return TextStyle(
      fontFamily: 'Poppins',
      fontSize: widget.fontSize,
      fontWeight: FontWeight.w500,
      color: VoxfableColors.deepViolet,
    );
  }

  TextStyle _getHighlightStyle(TextStyle normal) {
    return normal.copyWith(
      color: VoxfableColors.textHighlight,
      fontWeight: FontWeight.w800,
    );
  }

  List<TextRange> _getWordRanges(String text) {
    final List<TextRange> ranges = [];
    final regex = RegExp(r'\S+');
    for (final match in regex.allMatches(text)) {
      ranges.add(TextRange(start: match.start, end: match.end));
    }
    return ranges;
  }

  List<LineInfo> _getLines(String text, TextStyle style, double maxWidth) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    final List<LineInfo> lines = [];
    int offset = 0;
    while (offset < text.length) {
      final lineRange = textPainter.getLineBoundary(
        TextPosition(offset: offset),
      );
      if (lineRange.start == -1 || lineRange.end == -1) break;
      final lineText = text.substring(lineRange.start, lineRange.end);
      lines.add(
        LineInfo(
          text: lineText,
          startOffset: lineRange.start,
          endOffset: lineRange.end,
        ),
      );
      offset = lineRange.end;
      if (lineRange.start == lineRange.end) {
        offset++;
      }
    }
    return lines;
  }

  LineRenderData _buildLineRenderData(
    LineInfo line,
    TextRange? activeRange,
    TextStyle normalStyle,
    TextStyle highlightStyle,
  ) {
    final List<CharRenderInfo> chars = [];
    double totalWidth = 0.0;

    for (int i = 0; i < line.text.length; i++) {
      final globalIndex = line.startOffset + i;
      final isHighlighted =
          activeRange != null &&
          globalIndex >= activeRange.start &&
          globalIndex < activeRange.end;

      final charStyle = isHighlighted ? highlightStyle : normalStyle;

      final charPainter = TextPainter(
        text: TextSpan(text: line.text[i], style: charStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      chars.add(CharRenderInfo(painter: charPainter, width: charPainter.width));
      totalWidth += charPainter.width;
    }

    return LineRenderData(chars: chars, totalWidth: totalWidth);
  }

  int _findActiveLineIndex(List<LineInfo> lines, TextRange? activeRange) {
    if (activeRange == null) return -1;
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (activeRange.start >= line.startOffset &&
          activeRange.start < line.endOffset) {
        return i;
      }
    }
    return -1;
  }

  void _scrollToActiveLine(int activeLineIndex, double viewportHeight) {
    if (!_scrollController.hasClients) return;

    double targetScroll = 0.0;
    if (activeLineIndex != -1) {
      final targetOffset = activeLineIndex * widget.lineHeight;
      targetScroll =
          targetOffset - (viewportHeight / 2) + (widget.lineHeight / 2);
    }

    _scrollController.animateTo(
      targetScroll.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeWordIndex = ref.watch(
      storyViewModelProvider.select((s) => s.activeWordIndex),
    );
    final audioState = ref.watch(
      storyViewModelProvider.select((s) => s.audioState),
    );

    final isPlaying = audioState == AudioState.playing;
    final physics = isPlaying
        ? const NeverScrollableScrollPhysics()
        : const ClampingScrollPhysics();

    return LayoutBuilder(
      builder: (context, constraints) {
        _lastWidth = constraints.maxWidth;
        _lastViewportHeight = constraints.maxHeight;

        final normalStyle = _getNormalStyle();
        final highlightStyle = _getHighlightStyle(normalStyle);
        final wordRanges = _getWordRanges(widget.text);
        final activeRange =
            (activeWordIndex >= 0 && activeWordIndex < wordRanges.length)
            ? wordRanges[activeWordIndex]
            : null;

        final lines = _getLines(widget.text, normalStyle, _lastWidth);

        if (activeWordIndex != _lastActiveWordIndex) {
          _lastActiveWordIndex = activeWordIndex;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final activeLineIndex = _findActiveLineIndex(lines, activeRange);
            _scrollToActiveLine(activeLineIndex, _lastViewportHeight);
          });
        }

        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0008) // Perspective factor
            ..rotateY(-0.08) // Y-axis page crease perspective
            ..rotateZ(widget.rotationZ), // Z-axis rotation/tilt
          alignment: Alignment.centerLeft,
          child: Container(
            padding: VoxfablePaddings.overlayPadding,
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(
                context,
              ).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: physics,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(lines.length, (index) {
                    final lineData = _buildLineRenderData(
                      lines[index],
                      activeRange,
                      normalStyle,
                      highlightStyle,
                    );

                    return SizedBox(
                      height: widget.lineHeight,
                      width: _lastWidth,
                      child: CustomPaint(
                        painter: SinCurveLinePainter(
                          lineData: lineData,
                          amplitude: widget.amplitude,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class LineInfo {
  final String text;
  final int startOffset;
  final int endOffset;

  LineInfo({
    required this.text,
    required this.startOffset,
    required this.endOffset,
  });
}

class CharRenderInfo {
  final TextPainter painter;
  final double width;

  CharRenderInfo({required this.painter, required this.width});
}

class LineRenderData {
  final List<CharRenderInfo> chars;
  final double totalWidth;

  LineRenderData({required this.chars, required this.totalWidth});
}

class SinCurveLinePainter extends CustomPainter {
  final LineRenderData lineData;
  final double amplitude;

  SinCurveLinePainter({required this.lineData, required this.amplitude});

  @override
  void paint(Canvas canvas, Size size) {
    if (lineData.chars.isEmpty) return;

    double scale = 1.0;
    if (lineData.totalWidth > size.width && size.width > 0) {
      scale = size.width / lineData.totalWidth;
    }

    double currentX = 0.0;
    for (int i = 0; i < lineData.chars.length; i++) {
      final charInfo = lineData.chars[i];
      final double paintX = currentX * scale;

      final double normalizedX = paintX / (size.width > 0 ? size.width : 1.0);
      final double y = -amplitude * sin(normalizedX * pi);

      charInfo.painter.paint(canvas, Offset(paintX, y + 8.0));

      currentX += charInfo.width;
    }
  }

  @override
  bool shouldRepaint(covariant SinCurveLinePainter oldDelegate) {
    return oldDelegate.lineData != lineData ||
        oldDelegate.amplitude != amplitude;
  }
}
