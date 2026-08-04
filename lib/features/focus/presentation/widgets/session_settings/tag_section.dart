import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:lorofy/components/ui/shimmer.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/focus/data/models/focus_category.dart';
import 'package:lorofy/features/focus/presentation/providers/pomodoro_settings.dart';
import 'create_category_sheet.dart';

class TagSection extends ConsumerWidget {
  final AsyncValue<List<FocusCategory>> categoriesAsync;
  const TagSection({super.key, required this.categoriesAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(pomodoroSettingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tag',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF232321),
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.push(
                  context,
                  ModalSheetRoute(
                    builder: (context) => const Sheet(
                      decoration: MaterialSheetDecoration(
                        size: SheetSize.fit,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                        color: Color(0xFFF6F6F6),
                      ),
                      child: CreateCategorySheet(),
                    ),
                  ),
                );
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFE5E5EA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.add,
                  size: 16,
                  color: Color(0xFF232321),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        categoriesAsync.when(
          data: (categories) {
            if (categories.isEmpty) return const SizedBox.shrink();

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.8,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = settings.selectedCategory?.id == category.id;

                return GestureDetector(
                  onTap: () {
                    ref.read(pomodoroSettingsProvider.notifier).updateSettings(
                          settings.copyWith(selectedCategory: category),
                        );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF071B12) : CupertinoColors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            category.name,
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? CupertinoColors.white : const Color(0xFF232321),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            CupertinoIcons.checkmark,
                            size: 16,
                            color: CupertinoColors.white,
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.8,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return const ShimmerPlaceholder.rectangular(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              );
            },
          ),
          error: (err, stack) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}
