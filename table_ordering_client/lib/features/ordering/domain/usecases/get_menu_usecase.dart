import 'package:table_ordering_client/features/ordering/domain/entities/menu_item_entity.dart';
import 'package:table_ordering_client/features/ordering/domain/repositories/ordering_repository.dart';

class GetMenuUseCase {
  const GetMenuUseCase(this._repository);

  final OrderingRepository _repository;

  Future<List<MenuItemEntity>> call(String restaurantId) {
    return _repository.getMenu(restaurantId);
  }
}
