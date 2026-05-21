import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_ordering_client/core/constants/app_constants.dart';
import 'package:table_ordering_client/core/theme/app_theme.dart';
import 'package:table_ordering_client/core/widgets/empty_state.dart';
import 'package:table_ordering_client/core/widgets/error_state.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/restaurant_entity.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/table_entity.dart';
import 'package:table_ordering_client/features/ordering/domain/entities/table_session_entity.dart';
import 'package:table_ordering_client/features/ordering/presentation/providers/ordering_providers.dart';
import 'package:table_ordering_client/features/ordering/presentation/screens/menu_screen.dart';
import 'package:table_ordering_client/features/ordering/presentation/widgets/responsive_scaffold_body.dart';
import 'package:table_ordering_client/services/order_client_api_service.dart';
import 'package:table_ordering_client/services/order_client_providers.dart';

class TableEntryScreen extends ConsumerStatefulWidget {
  const TableEntryScreen({super.key});

  @override
  ConsumerState<TableEntryScreen> createState() => _TableEntryScreenState();
}

class _TableEntryScreenState extends ConsumerState<TableEntryScreen> {
  final TextEditingController _controller = TextEditingController(
    text: 'table-12',
  );
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _selectedTableId;
  bool _didAutoSelectFromQr = false;
  bool _didAutoOpenFromQr = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _validate() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(tableSessionProvider.notifier)
        .validateTable(_controller.text.trim());
  }

  void _openMenuFromTable(TableDto tableDto) {
    final session = TableSessionEntity(
      restaurant: RestaurantEntity(
        id: tableDto.restaurantId,
        name: 'Restaurant',
      ),
      table: TableEntity(
        id: tableDto.id,
        number: tableDto.number,
        restaurantId: tableDto.restaurantId,
        isActive: true,
      ),
    );

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => MenuScreen(session: session)));
  }

  TableDto? _matchTableFromQrToken(List<TableDto> tables, String rawToken) {
    final token = rawToken.trim();
    if (token.isEmpty) return null;

    final tokenLower = token.toLowerCase();
    final tokenNumber = int.tryParse(token);

    bool matches(TableDto table) {
      if (table.id == token) return true;
      if (tokenNumber != null && table.number == tokenNumber) return true;

      final qrCode = table.qrCode?.trim();
      if (qrCode == null || qrCode.isEmpty) return false;

      final qrCodeLower = qrCode.toLowerCase();
      return qrCodeLower == tokenLower ||
          qrCodeLower.contains(tokenLower) ||
          tokenLower.contains(qrCodeLower);
    }

    return tables.where(matches).firstOrNull;
  }

  Widget _buildRealBackendEntry(BuildContext context) {
    final restaurantId = ref.watch(restaurantIdProvider);
    final tableLinkToken = ref.watch(tableLinkTokenProvider);
    if (restaurantId.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 24),
          Text(
            'Configuration requise',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'RESTAURANT_ID est manquant. Lancez avec --dart-define=RESTAURANT_ID=votre_id.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      );
    }
    final tablesState = ref.watch(clientTablesProvider);

    return ListView(
      children: [
        const SizedBox(height: 24),
        Text('Bienvenue', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          'Choisissez une table pour le restaurant $restaurantId.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        tablesState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ErrorState(
            message: '$error',
            onRetry: () => ref.invalidate(clientTablesProvider),
          ),
          data: (tables) {
            if (tables.isEmpty) {
              return EmptyState(
                title: 'Aucune table trouvée',
                message:
                    'Le backend répond, mais aucune table n\'est associée à ce restaurant.',
                action: ElevatedButton.icon(
                  onPressed: () => ref.invalidate(clientTablesProvider),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Recharger'),
                ),
              );
            }

            if (!_didAutoSelectFromQr && tableLinkToken.isNotEmpty) {
              final linkedTable = _matchTableFromQrToken(
                tables,
                tableLinkToken,
              );
              if (linkedTable != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  setState(() {
                    _selectedTableId = linkedTable.id;
                    _didAutoSelectFromQr = true;
                  });
                });

                if (!_didAutoOpenFromQr) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    _didAutoOpenFromQr = true;
                    _openMenuFromTable(linkedTable);
                  });
                }
              }
            }

            final selectedTable = tables
                .where((table) => table.id == _selectedTableId)
                .firstOrNull;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedTableId,
                  decoration: const InputDecoration(
                    labelText: 'Table',
                    prefixIcon: Icon(Icons.table_restaurant_rounded),
                  ),
                  items: tables
                      .map(
                        (table) => DropdownMenuItem<String>(
                          value: table.id,
                          child: Text('Table ${table.number}'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTableId = value;
                    });
                  },
                ),
                if (selectedTable != null) ...[
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Restaurant',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            restaurantId,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Table #${selectedTable.number}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: selectedTable == null
                      ? null
                      : () => _openMenuFromTable(selectedTable),
                  child: const Text('Commencer la commande'),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!AppConstants.useMockData) {
      return Scaffold(
        body: DecoratedBox(
          decoration: AppTheme.warmBackground(),
          child: SafeArea(
            child: ResponsiveScaffoldBody(
              child: _buildRealBackendEntry(context),
            ),
          ),
        ),
      );
    }

    final tableSessionState = ref.watch(tableSessionProvider);

    return Scaffold(
      body: DecoratedBox(
        decoration: AppTheme.warmBackground(),
        child: SafeArea(
          child: ResponsiveScaffoldBody(
            child: tableSessionState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  ErrorState(message: '$error', onRetry: _validate),
              data: (session) {
                return ListView(
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'Bienvenue',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Scannez votre QR code de table puis lancez votre commande.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          labelText: 'Code table / QR',
                          hintText: 'Ex: table-12',
                          prefixIcon: Icon(Icons.qr_code_scanner_rounded),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Veuillez saisir un code table';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _validate,
                      icon: const Icon(Icons.verified_rounded),
                      label: const Text('Vérifier la table'),
                    ),
                    if (session != null) ...[
                      const SizedBox(height: 20),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Restaurant',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                session.restaurant.name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Table #${session.table.number}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                session.table.isActive
                                    ? 'Table active'
                                    : 'Table inactive',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: session.table.isActive
                            ? () {
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                        ) => MenuScreen(session: session),
                                    transitionsBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                          child,
                                        ) {
                                          return FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          );
                                        },
                                  ),
                                );
                              }
                            : null,
                        child: const Text('Commencer la commande'),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
