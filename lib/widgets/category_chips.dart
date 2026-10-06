import 'package:flutter/material.dart';

class CategoryChips extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const CategoryChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static const categories = [
    ('', 'All'),
    ('nature', 'Nature'),
    ('animals', 'Animals'),
    ('travel', 'Travel'),
    ('food', 'Food'),
    ('people', 'People'),
    ('technology', 'Tech'),
    ('cars', 'Cars'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) =>
        const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];

          final isSelected = selected == category.$1;

          return ChoiceChip(
            label: Text(category.$2),
            selected: isSelected,
            onSelected: (_) {
              onSelected(category.$1);
            },
            showCheckmark: false,
          );
        },
      ),
    );
  }
}