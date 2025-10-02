import 'package:flutter/material.dart';
import '../theme/tokens.dart';

class SectionCard extends StatelessWidget {
  final String? title;
  final Widget child;
  final Widget? trailing;

  /// Extra controls (optional)
  final EdgeInsetsGeometry padding;
  final bool showDivider;

  const SectionCard({
    super.key,
    this.title,
    required this.child,
    this.trailing,
    this.padding = const EdgeInsets.all(16),
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final hasHeader = title != null || trailing != null;

    return Card(
      clipBehavior: Clip.antiAlias, // ensures ink & corners are clean
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasHeader) ...[
              Row(
                children: [
                  if (title != null)
                    Expanded(
                      child: Text(
                        title!,
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (trailing != null) ...[
                    Gaps.xs,
                    trailing!,
                  ],
                ],
              ),
              Gaps.md,
              if (showDivider) ...[
                Divider(
                  height: 1,
                  thickness: 1,
                  // Pops nicely on true-black; adjust opacity if too strong
                  color: cs.outlineVariant.withOpacity(0.6),
                ),
                Gaps.sm,
              ] else
                Gaps.sm,
            ],
            child,
          ],
        ),
      ),
    );
  }
}
