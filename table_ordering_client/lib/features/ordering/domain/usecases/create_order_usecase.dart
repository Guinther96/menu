import 'package:table_ordering_client/features/ordering/domain/entities/cart_item_entity.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/order_entity.dart';
import 'package:table_ordering_client/features/ordering/domain/repositories/ordering_repository.dart';

class CreateOrderUseCase {
  const CreateOrderUseCase(this._repository);

  final OrderingRepository _repository;

  Future<OrderEntity> call({
    required String tableId,
    required List<CartItemEntity> items,
    String? globalNote,
  }) {
    return _repository.createOrder(
      tableId: tableId,
      items: items,
      globalNote: globalNote,
    );
  }
}
