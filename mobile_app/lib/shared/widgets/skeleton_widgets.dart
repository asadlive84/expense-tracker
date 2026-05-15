import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlight = Theme.of(context).colorScheme.surfaceContainerHigh;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          SkeletonBox(width: 44, height: 44, radius: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: double.infinity, height: 14),
                const SizedBox(height: 6),
                SkeletonBox(width: 120, height: 11),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SkeletonBox(width: 60, height: 14),
        ],
      ),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SkeletonBox(width: 40, height: 40, radius: 20),
                const SizedBox(width: 12),
                Expanded(child: SkeletonBox(width: double.infinity, height: 16)),
              ],
            ),
            const SizedBox(height: 12),
            SkeletonBox(width: 100, height: 24),
          ],
        ),
      ),
    );
  }
}

/// Use [shrinkWrap: true] when inside a Row/Column that doesn't constrain height.
/// Use [shrinkWrap: false] (default) when inside Expanded — renders as ListView.
Widget skeletonList({int count = 6, bool card = false, bool shrinkWrap = false}) {
  final children = List.generate(
    count,
    (_) => card ? const SkeletonCard() : const SkeletonListTile(),
  );
  if (shrinkWrap) {
    return Column(mainAxisSize: MainAxisSize.min, children: children);
  }
  return ListView(
    physics: const NeverScrollableScrollPhysics(),
    shrinkWrap: false,
    children: children,
  );
}
