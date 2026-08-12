import 'package:lorofy/features/focus/domain/models/focus_category.dart';
import 'package:lorofy/features/focus/domain/repositories/focus_repository.dart';
import 'package:lorofy/features/focus/data/repositories/focus_repository_impl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'categories_provider.g.dart';

@Riverpod(keepAlive: true)
class FocusCategories extends _$FocusCategories {
  @override
  Future<List<FocusCategory>> build() async {
    final FocusRepository repository = ref.watch(focusRepositoryProvider);
    return await repository.getCategories();
  }

  void addCategory(FocusCategory category) {
    state.whenData((currentList) {
      state = AsyncValue.data([...currentList, category]);
    });
  }

  void removeCategory(String id) {
    state.whenData((currentList) {
      state = AsyncValue.data(currentList.where((cat) => cat.id != id).toList());
    });
  }
}
