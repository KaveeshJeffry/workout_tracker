import 'package:flutter/material.dart';
import '../theme/tokens.dart';

class SectionCard extends StatelessWidget {
  final String? title;
  final Widget child;
  final Widget? trailing;

  const SectionCard({super.key, this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null || trailing != null) ...[
              Row(
                children: [
                  if (title != null)
                    Text(title!, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  if (trailing != null) trailing!,
                ],
              ),
              Gaps.md,
              const Divider(),
              Gaps.sm,
            ],
            child,
          ],
        ),
      ),
    );
  }
}
