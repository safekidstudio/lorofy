import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/components/ui/button.dart';
import 'package:lorofy/components/ui/input.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/components/ui/toast.dart';
import 'package:lorofy/components/layout/app_header.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/focus/domain/models/focus_category.dart';
import 'package:lorofy/features/focus/presentation/providers/categories_provider.dart';
import 'package:reactive_forms/reactive_forms.dart';

class CreateCategorySheet extends ConsumerStatefulWidget {
  const CreateCategorySheet({super.key});

  @override
  ConsumerState<CreateCategorySheet> createState() =>
      _CreateCategorySheetState();
}

class _CreateCategorySheetState extends ConsumerState<CreateCategorySheet> {
  late FormGroup _form;
  String _selectedColorHex = '#4CD964'; // Default Green

  final List<String> _presetColors = [
    '#4CD964', // Green
    '#007AFF', // Blue
    '#5856D6', // Purple
    '#FF2D55', // Pink
    '#FF9500', // Orange
    '#5AC8FA', // Teal
  ];

  @override
  void initState() {
    super.initState();
    _form = FormGroup({
      'name': FormControl<String>(
        value: '',
        validators: [Validators.required],
      ),
    });
  }

  Color _getColorFromHex(String? hexString, Color defaultColor) {
    if (hexString == null || hexString.isEmpty) return defaultColor;
    try {
      final hex = hexString.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return defaultColor;
    }
  }

  void _onCreateCategory() {
    if (_form.invalid) return;

    final name = (_form.value['name'] as String?)?.trim() ?? '';
    if (name.isEmpty) return;

    final newCategory = FocusCategory(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      iconName: 'tag', // Simple default icon
      colorHex: _selectedColorHex,
      isSystem: false,
    );

    ref.read(focusCategoriesProvider.notifier).addCategory(newCategory);

    AppToast.show(
      context,
      message: 'Category "$name" created!',
      type: ToastType.success,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF6F6F6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ReactiveForm(
            formGroup: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppHeader(
                  leftActions: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: const SVG(
                      'assets/icons/cancel.svg',
                      width: 20,
                      height: 20,
                    ),
                  ),
                  title: 'New Category',
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppPadding.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Input Name
                      ReactiveFormConsumer(
                        builder: (context, form, child) {
                          final nameControl = form.control('name');
                          String? errorText;
                          if (nameControl.hasError(ValidationMessage.required) && nameControl.dirty) {
                            errorText = 'Category name cannot be empty';
                          }
                          return Input(
                            placeholder: 'Enter category name...',
                            formControlName: 'name',
                            errorMessage: errorText,
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Color Selector
                      const Text(
                        'Choose Color',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF232321),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: _presetColors.map((colorHex) {
                          final color = _getColorFromHex(
                            colorHex,
                            Colors.transparent,
                          );
                          final isSelected = _selectedColorHex == colorHex;

                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedColorHex = colorHex),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(
                                        color: const Color(0xFF232321),
                                        width: 3,
                                      )
                                    : Border.all(color: Colors.white, width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: isSelected
                                  ? const Align(
                                      alignment: Alignment.center,
                                      child: SVG(
                                        'assets/icons/check.svg',
                                        width: 16,
                                        height: 16,
                                        color: Colors.white,
                                      ),
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 32),

                      // Create Button
                      SizedBox(
                        height: 52,
                        child: ReactiveFormConsumer(
                          builder: (context, form, child) {
                            return Button.primary(
                              text: 'Create Category',
                              onPressed: form.valid ? _onCreateCategory : null,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
