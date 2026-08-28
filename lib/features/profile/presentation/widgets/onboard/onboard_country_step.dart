import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/components/ui/shimmer.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/profile/presentation/providers/country_provider.dart';

class OnboardCountryStep extends ConsumerWidget {
  final bool isDisabled;
  final String selectedCountryCode;
  final ValueChanged<String> onCountryChanged;

  const OnboardCountryStep({
    super.key,
    required this.isDisabled,
    required this.selectedCountryCode,
    required this.onCountryChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countriesAsync = ref.watch(countriesProvider);

    return Column(
      children: [
        const SizedBox(height: 20),
        Text('Where are you from?', style: AppTextStyles.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Choose the country you are currently living in',
          style: AppTextStyles.body.copyWith(
            color: AppColors.secondary,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        countriesAsync.when(
          loading: () => const _OnboardCountrySkeleton(),
          error: (e, _) => Center(
            child: Text(
              'Could not load countries',
              style: AppTextStyles.body.copyWith(color: AppColors.secondary),
            ),
          ),
          data: (countries) {
            // Auto-select first country if current selection not in list
            if (countries.isNotEmpty &&
                !countries.any((c) => c.code == selectedCountryCode)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                onCountryChanged(countries.first.code);
              });
            }
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
              children: countries.map((country) {
                final isSelected = country.code == selectedCountryCode;

                return GestureDetector(
                  onTap: isDisabled ? null : () => onCountryChanged(country.code),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF232321)
                            : CupertinoColors.transparent,
                        width: 2.0,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x05000000),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: country.flagUrl != null
                                    ? Image.network(
                                        country.flagUrl!,
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Center(
                                            child: Text(
                                              country.flagEmoji,
                                              style: const TextStyle(fontSize: 32),
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, error, stack) =>
                                            Center(
                                              child: Text(
                                                country.flagEmoji,
                                                style: const TextStyle(fontSize: 32),
                                              ),
                                            ),
                                      )
                                    : Center(
                                        child: Text(
                                          country.flagEmoji,
                                          style: const TextStyle(fontSize: 32),
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                country.name,
                                style: const TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF232321),
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Color(0xFF071B12),
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
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _OnboardCountrySkeleton extends StatelessWidget {
  const _OnboardCountrySkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.85,
      children: List.generate(
        6,
        (index) => Container(
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x05000000),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const ShimmerPlaceholder.circular(size: 48),
              const SizedBox(height: 12),
              ShimmerPlaceholder.rectangular(
                width: 60,
                height: 14,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
