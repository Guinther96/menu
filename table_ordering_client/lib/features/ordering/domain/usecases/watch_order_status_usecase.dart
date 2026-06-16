import 'package:table_ordering_client/features/ordering/domain/entities/order_entity.dart';
import 'package:table_ordering_client/features/ordering/domain/repositories/ordering_repository.dart';

class WatchOrderStatusUseCase {
  const WatchOrderStatusUseCase(this._repository);

  final OrderingRepository _repository;

  Stream<OrderEntity> call(String orderId) {
    return _repository.watchOrderStatus(orderId);
  }
}
