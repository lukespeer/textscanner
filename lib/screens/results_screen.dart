import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';

class ResultsScreen extends StatefulWidget {
  final img.Image image;
  final RecognizedText recognizedText;
  const ResultsScreen({super.key, required this.image, required this.recognizedText});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  Future<void> _copyBlock(TextBlock block, int index) async {
    await Clipboard.setData(ClipboardData(text: block.text));
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Copied result ${index + 1}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final blocks = widget.recognizedText.blocks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              sliver: SliverToBoxAdapter(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _SelectableTextImage(
                    memoryImage: Image.memory(img.encodeJpg(widget.image), fit: BoxFit.fill),
                    image: widget.image,
                    blocks: blocks,
                    onBlockTap: _copyBlock,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              sliver: SliverToBoxAdapter(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        'Detected text',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '${blocks.length} ${blocks.length == 1 ? 'result' : 'results'}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (blocks.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: _EmptyResultsCard(theme: theme),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.builder(
                  itemCount: blocks.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ResultCard(
                        index: index,
                        block: blocks[index],
                        theme: theme,
                      ),
                    );
                  },
                ),
              )
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final int index;
  final TextBlock block;
  final ThemeData theme;

  const _ResultCard({
    required this.index,
    required this.block,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Result ${index + 1}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SelectableText(
              block.text,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
            )
          ],
        ),
      ),
    );
  }
}

class _SelectableTextImage extends StatelessWidget {
  final Image memoryImage;
  final img.Image image;
  final List<TextBlock> blocks;
  final Future<void> Function(TextBlock block, int index) onBlockTap;

  const _SelectableTextImage({
    required this.memoryImage,
    required this.image,
    required this.blocks,
    required this.onBlockTap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: image.width / image.height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final imageSize = Size(constraints.maxWidth, constraints.maxHeight);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) {
              final imagePoint = Offset(
                details.localPosition.dx * image.width / imageSize.width,
                details.localPosition.dy * image.height / imageSize.height,
              );
              final matches = <int>[];

              for (var index = 0; index < blocks.length; index++) {
                if (blocks[index].boundingBox.contains(imagePoint)) {
                  matches.add(index);
                }
              }

              if (matches.isEmpty) return;
              final index = matches.reduce(
                (first, next) => _area(blocks[first].boundingBox) <=
                        _area(blocks[next].boundingBox)
                    ? first
                    : next,
              );
              onBlockTap(blocks[index], index);
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                memoryImage,
              ]
            ),
          );
        },
      ),
    );
  }

  double _area(Rect rect) => rect.width * rect.height;
}

class BoundsPainter extends CustomPainter {
  final List<TextBlock> blocks;
  final Size imageSize;

  BoundsPainter({required this.blocks, required this.imageSize});

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;

    final paint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (var block in blocks) {
      final rect = Rect.fromLTRB(
        block.boundingBox.left * scaleX,
        block.boundingBox.top * scaleY,
        block.boundingBox.right * scaleX,
        block.boundingBox.bottom * scaleY,
      );
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EmptyResultsCard extends StatelessWidget {
  final ThemeData theme;

  const _EmptyResultsCard({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 40,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'No text found',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try scanning an image with clearer text.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}