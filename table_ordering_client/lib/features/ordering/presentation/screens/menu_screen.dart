import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_ordering_client/core/widgets/empty_state.dart';
import 'package:table_ordering_client/core/widgets/error_state.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/menu_item_entity.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/table_session_entity.dart';
import 'package:table_ordering_client/features/ordering/presentation/providers/ordering_providers.dart';
import 'package:table_ordering_client/features/ordering/presentation/screens/cart_screen.dart';
import 'package:table_ordering_client/features/ordering/presentation/screens/item_detail_screen.dart';
import 'package:table_ordering_client/features/ordering/presentation/widgets/menu_item_card.dart';
import 'package:table_ordering_client/features/ordering/presentation/widgets/responsive_scaffold_body.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({required this.session, super.key});

  final TableSessionEntity session;

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  RangeValues _priceRange = const RangeValues(0, 50);
  bool _didAutoExpandPriceRange = false;
  bool _onlyAvailable = false;
  final Map<String, int> _localQuantity = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(menuProvider.notifier)
          .loadMenu(widget.session.restaurant.id),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MenuItemEntity> _filteredItems(List<MenuItemEntity> items) {
    return items.where((item) {
      final matchesSearch = item.name.toLowerCase().contains(
        _searchController.text.trim().toLowerCase(),
      );
      final matchesCategory =
          _selectedCategory == null || item.category == _selectedCategory;
      final matchesPrice =
          item.price >= _priceRange.start && item.price <= _priceRange.end;
      final matchesAvailability = !_onlyAvailable || item.isAvailable;
      return matchesSearch &&
          matchesCategory &&
          matchesPrice &&
          matchesAvailability;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final menuState = ref.watch(menuProvider);
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE66A2C),

        title: Text(
          '${widget.session.restaurant.name} • Table ${widget.session.table.number}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            color: Colors.white,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CartScreen(session: widget.session),
              ),
            ),
            icon: Badge(
              label: Text('${cart.totalQuantity}'),
              child: const Icon(Icons.shopping_bag_rounded),
            ),
          ),
        ],
      ),
      body: ResponsiveScaffoldBody(
        child: menuState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ErrorState(
            message: '$error',
            onRetry: () => ref
                .read(menuProvider.notifier)
                .loadMenu(widget.session.restaurant.id),
          ),
          data: (items) {
            final maxItemPrice = items.fold<double>(
              0,
              (currentMax, item) =>
                  item.price > currentMax ? item.price : currentMax,
            );
            final sliderMax = maxItemPrice <= 0
                ? 50.0
                : (maxItemPrice * 1.2).ceilToDouble();

            if (!_didAutoExpandPriceRange && sliderMax > _priceRange.end) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                setState(() {
                  _priceRange = RangeValues(0, sliderMax);
                  _didAutoExpandPriceRange = true;
                });
              });
            }

            final effectivePriceRange = RangeValues(
              _priceRange.start.clamp(0, sliderMax).toDouble(),
              _priceRange.end.clamp(0, sliderMax).toDouble(),
            );

            final categories = items.map((e) => e.category).toSet().toList();
            final previousPriceRange = _priceRange;
            _priceRange = effectivePriceRange;
            final filtered = _filteredItems(items);
            _priceRange = previousPriceRange;

            return Column(
              children: [
                const SizedBox(height: 8),
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Rechercher un plat',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ChoiceChip(
                        label: const Text('Tout'),
                        selected: _selectedCategory == null,
                        onSelected: (_) =>
                            setState(() => _selectedCategory = null),
                      ),
                      const SizedBox(width: 8),
                      ...categories.map(
                        (cat) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: _selectedCategory == cat,
                            onSelected: (_) =>
                                setState(() => _selectedCategory = cat),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: RangeSlider(
                        values: effectivePriceRange,
                        min: 0,
                        max: sliderMax,
                        labels: RangeLabels(
                          '${effectivePriceRange.start.round()} G',
                          '${effectivePriceRange.end.round()} G',
                        ),
                        onChanged: (value) =>
                            setState(() => _priceRange = value),
                      ),
                    ),
                    FilterChip(
                      label: const Text('Disponibles'),
                      selected: _onlyAvailable,
                      onSelected: (value) =>
                          setState(() => _onlyAvailable = value),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: filtered.isEmpty
                      ? const EmptyState(
                          title: 'Aucun plat',
                          message:
                              'Aucun résultat avec ces filtres. Essayez de les ajuster.',
                        )
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            final qty = _localQuantity[item.id] ?? 0;

                            return MenuItemCard(
                              item: item,
                              quantity: qty,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ItemDetailScreen(item: item),
                                  ),
                                );
                              },
                              onAdd: () {
                                ref.read(cartProvider.notifier).add(item);
                                setState(
                                  () => _localQuantity[item.id] = qty + 1,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${item.name} ajouté au panier',
                                    ),
                                  ),
                                );
                              },
                              onMinus: () {
                                if (qty == 0) return;
                                final newQty = qty - 1;
                                ref
                                    .read(cartProvider.notifier)
                                    .updateQuantity(item.id, newQty);
                                setState(
                                  () => _localQuantity[item.id] = newQty,
                                );
                              },
                              onPlus: () {
                                ref.read(cartProvider.notifier).add(item);
                                setState(
                                  () => _localQuantity[item.id] = qty + 1,
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: cart.items.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CartScreen(session: widget.session),
                ),
              ),
              label: const Text('Voir panier'),
              icon: const Icon(Icons.shopping_cart_checkout_rounded),
            ),
    );
  }
}
