import 'package:table_ordering_client/features/ordering/domain/entities/table_session_entity.dart';
import 'package:table_ordering_client/features/ordering/domain/repositories/ordering_repository.dart';

class ValidateTableUseCase {
  const ValidateTableUseCase(this._repository);

  final OrderingRepository _repository;

  Future<TableSessionEntity> call(String tableCode, {String? restaurantId}) {
    return _repository.validateTable(tableCode, restaurantId: restaurantId);
  }
}
