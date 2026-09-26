import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/components/ui/button.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/components/ui/shimmer.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/profile/domain/models/country_model.dart';
import 'package:lorofy/features/profile/presentation/providers/country_provider.dart';

class CountrySelectSheet extends ConsumerStatefulWidget {
  final String currentCountryCode;
  final ValueChanged<CountryModel> onSelect;

  const CountrySelectSheet({
    super.key,
    required this.currentCountryCode,
    required this.onSelect,
  });

  @override
  ConsumerState<CountrySelectSheet> createState() => _CountrySelectSheetState();
}

class _CountrySelectSheetState extends ConsumerState<CountrySelectSheet> {
  String _searchQuery = '';
  late String _selectedCode;

  @override
  void initState() {
    super.initState();
    _selectedCode = widget.currentCountryCode;
  }

  void _safePop() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final countriesAsync = ref.watch(countriesProvider);

    return SafeArea(
      top: false,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: const BoxDecoration(
          color: Color(0xFFF6F6F6),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle Bar & Header
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity != null && details.primaryVelocity! > 250) {
                  _safePop();
                }
              },
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1D1D6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  _SheetHeader(onClose: _safePop),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Search Bar
            CupertinoSearchTextField(
              placeholder: 'Search country...',
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 15,
                color: AppColors.foreground,
              ),
              onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
            ),
            const SizedBox(height: 16),

            // Country Grid Area (Safe Scroll without accidental route pop)
            Expanded(
              child: countriesAsync.when(
                loading: () => const _GridSkeleton(),
                error: (err, stack) => Center(
                  child: Text(
                    'Could not load countries',
                    style: AppTextStyles.body.copyWith(color: AppColors.mutedForeground),
                  ),
                ),
                data: (countries) {
                  final filtered = countries.where((c) {
                    return c.name.toLowerCase().contains(_searchQuery) ||
                        c.code.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        'No countries found',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    );
                  }

                  return CupertinoScrollbar(
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final country = filtered[index];
                        return _CountryGridCard(
                          country: country,
                          isSelected: country.code == _selectedCode,
                          onTap: () => setState(() => _selectedCode = country.code),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Choose Action Button
            Button.primary(
              text: 'Choose',
              onPressed: () {
                final countries = countriesAsync.asData?.value ?? [];
                final chosen = countries.firstWhere(
                  (c) => c.code == _selectedCode,
                  orElse: () => CountryModel(
                    code: _selectedCode,
                    name: _selectedCode,
                  ),
                );
                widget.onSelect(chosen);
                _safePop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header Widget ─────────────────────────────────────────────────────────────

class _SheetHeader extends StatelessWidget {
  final VoidCallback onClose;

  const _SheetHeader({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Where are you from?',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.foreground,
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              onPressed: onClose,
              child: const SVG(
                'assets/icons/x.svg',
                width: 22,
                height: 22,
                color: AppColors.mutedForeground,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Choose your country or region',
          style: AppTextStyles.body.copyWith(
            color: AppColors.mutedForeground,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

// ── Grid Card Item Widget ──────────────────────────────────────────────────────

class _CountryGridCard extends StatelessWidget {
  final CountryModel country;
  final bool isSelected;
  final VoidCallback onTap;

  const _CountryGridCard({
    required this.country,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.foreground : CupertinoColors.transparent,
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: country.flagUrl != null
                          ? Image.network(
                              country.flagUrl!,
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Text(
                                country.flagEmoji,
                                style: const TextStyle(fontSize: 30),
                              ),
                            )
                          : Text(
                              country.flagEmoji,
                              style: const TextStyle(fontSize: 30),
                            ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      country.name,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.foreground,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            if (isSelected)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const SVG(
                    'assets/icons/check.svg',
                    width: 10,
                    height: 10,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Loading Skeleton Widget ───────────────────────────────────────────────────

class _GridSkeleton extends StatelessWidget {
  const _GridSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.85,
      children: List.generate(
        9,
        (index) => Container(
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const ShimmerPlaceholder.circular(size: 44),
              const SizedBox(height: 10),
              ShimmerPlaceholder.rectangular(
                width: 50,
                height: 12,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
