import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_ordering_client/core/constants/app_constants.dart';
import 'package:table_ordering_client/features/ordering/data/repositories/ordering_repository_impl.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/cart_item_entity.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/menu_item_entity.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/order_entity.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/table_session_entity.dart';
import 'package:table_ordering_client/features/ordering/domain/repositories/ordering_repository.dart';
import 'package:table_ordering_client/features/ordering/domain/usecases/create_order_usecase.dart';
import 'package:table_ordering_client/features/ordering/domain/usecases/get_menu_usecase.dart';
import 'package:table_ordering_client/features/ordering/domain/usecases/validate_table_usecase.dart';
import 'package:table_ordering_client/features/ordering/domain/usecases/watch_order_status_usecase.dart';
import 'package:table_ordering_client/services/order_client_providers.dart';

final orderingRepositoryProvider = Provider<OrderingRepository>((ref) {
  final apiService = ref.watch(orderClientApiServiceProvider);
  return OrderingRepositoryImpl(apiService: apiService);
});

final validateTableUseCaseProvider = Provider<ValidateTableUseCase>((ref) {
  return ValidateTableUseCase(ref.watch(orderingRepositoryProvider));
});

final getMenuUseCaseProvider = Provider<GetMenuUseCase>((ref) {
  return GetMenuUseCase(ref.watch(orderingRepositoryProvider));
});

final createOrderUseCaseProvider = Provider<CreateOrderUseCase>((ref) {
  return CreateOrderUseCase(ref.watch(orderingRepositoryProvider));
});

final watchOrderStatusUseCaseProvider = Provider<WatchOrderStatusUseCase>((
  ref,
) {
  return WatchOrderStatusUseCase(ref.watch(orderingRepositoryProvider));
});

final tableSessionProvider =
    StateNotifierProvider<
      TableSessionNotifier,
      AsyncValue<TableSessionEntity?>
    >((ref) {
      return TableSessionNotifier(ref.watch(validateTableUseCaseProvider));
    });

class TableSessionNotifier
    extends StateNotifier<AsyncValue<TableSessionEntity?>> {
  TableSessionNotifier(this._validateTableUseCase)
    : super(const AsyncValue.data(null));

  final ValidateTableUseCase _validateTableUseCase;

  Future<void> validateTable(String code, {String? restaurantId}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _validateTableUseCase(code, restaurantId: restaurantId);
    });
  }
}

final menuProvider =
    StateNotifierProvider<MenuNotifier, AsyncValue<List<MenuItemEntity>>>((
      ref,
    ) {
      return MenuNotifier(ref.watch(getMenuUseCaseProvider));
    });

class MenuNotifier extends StateNotifier<AsyncValue<List<MenuItemEntity>>> {
  MenuNotifier(this._getMenuUseCase) : super(const AsyncValue.loading());

  final GetMenuUseCase _getMenuUseCase;

  Future<void> loadMenu(String restaurantId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _getMenuUseCase(restaurantId));
  }
}

class CartState {
  const CartState({this.items = const [], this.orderNote = ''});

  final List<CartItemEntity> items;
  final String orderNote;

  double get subTotal => items.fold(0, (sum, item) => sum + item.lineTotal);

  double get fees => items.isEmpty ? 0 : 1.5;

  double get total => subTotal + fees;

  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  CartState copyWith({List<CartItemEntity>? items, String? orderNote}) {
    return CartState(
      items: items ?? this.items,
      orderNote: orderNote ?? this.orderNote,
    );
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  void add(MenuItemEntity item, {int quantity = 1, String? note}) {
    final existingIndex = state.items.indexWhere(
      (it) => it.menuItem.id == item.id,
    );
    final updatedItems = [...state.items];

    if (existingIndex == -1) {
      updatedItems.add(
        CartItemEntity(menuItem: item, quantity: quantity, note: note),
      );
    } else {
      final existing = updatedItems[existingIndex];
      updatedItems[existingIndex] = existing.copyWith(
        quantity: existing.quantity + quantity,
        note: note ?? existing.note,
      );
    }

    state = state.copyWith(items: updatedItems);
  }

  void updateQuantity(String menuItemId, int quantity) {
    if (quantity <= 0) {
      remove(menuItemId);
      return;
    }

    final updatedItems = state.items
        .map(
          (item) => item.menuItem.id == menuItemId
              ? item.copyWith(quantity: quantity)
              : item,
        )
        .toList();

    state = state.copyWith(items: updatedItems);
  }

  void remove(String menuItemId) {
    state = state.copyWith(
      items: state.items
          .where((item) => item.menuItem.id != menuItemId)
          .toList(),
    );
  }

  void setOrderNote(String note) {
    state = state.copyWith(orderNote: note);
  }

  void clear() {
    state = const CartState();
  }
}

final createOrderProvider =
    StateNotifierProvider<CreateOrderNotifier, AsyncValue<OrderEntity?>>((ref) {
      return CreateOrderNotifier(
        createOrderUseCase: ref.watch(createOrderUseCaseProvider),
        cartNotifier: ref.watch(cartProvider.notifier),
      );
    });

class CreateOrderNotifier extends StateNotifier<AsyncValue<OrderEntity?>> {
  CreateOrderNotifier({
    required CreateOrderUseCase createOrderUseCase,
    required CartNotifier cartNotifier,
  }) : _createOrderUseCase = createOrderUseCase,
       _cartNotifier = cartNotifier,
       super(const AsyncValue.data(null));

  final CreateOrderUseCase _createOrderUseCase;
  final CartNotifier _cartNotifier;

  Future<OrderEntity?> create({
    required String tableId,
    required List<CartItemEntity> items,
    String? globalNote,
  }) async {
    state = const AsyncValue.loading();

    final result = await AsyncValue.guard(
      () => _createOrderUseCase(
        tableId: tableId,
        items: items,
        globalNote: globalNote,
      ),
    );

    state = result;

    return result.when(
      data: (order) {
        _cartNotifier.clear();
        return order;
      },
      error: (_, _) => null,
      loading: () => null,
    );
  }
}

final orderStatusStreamProvider = StreamProvider.family<OrderEntity, String>((
  ref,
  orderId,
) {
  final useCase = ref.watch(watchOrderStatusUseCaseProvider);
  return useCase(orderId);
});

final elapsedTimeProvider = StreamProvider.family<Duration, DateTime>((
  ref,
  createdAt,
) {
  return Stream.periodic(AppConstants.orderPollingInterval, (_) {
    return DateTime.now().difference(createdAt);
  }).startWith(DateTime.now().difference(createdAt));
});

extension<T> on Stream<T> {
  Stream<T> startWith(T value) async* {
    yield value;
    yield* this;
  }
}
