import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_ordering_client/core/theme/app_theme.dart';
import 'package:table_ordering_client/core/widgets/error_state.dart';
import 'package:table_ordering_client/features/ordering/presentation/providers/ordering_providers.dart';
import 'package:table_ordering_client/features/ordering/presentation/screens/menu_screen.dart';
import 'package:table_ordering_client/features/ordering/presentation/widgets/responsive_scaffold_body.dart';
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
  bool _didAutoValidateFromQr = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _validate() async {
    if (!_formKey.currentState!.validate()) return;
    final restaurantId = ref.read(restaurantIdProvider);
    await ref
        .read(tableSessionProvider.notifier)
        .validateTable(_controller.text.trim(), restaurantId: restaurantId);
  }

  Widget _buildRealBackendEntry(BuildContext context) {
    final restaurantId = ref.watch(restaurantIdProvider);
    final tableLinkToken = ref.watch(tableLinkTokenProvider);
    final tableSessionState = ref.watch(tableSessionProvider);

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
            'Le lien QR doit contenir restaurant_id (ou restaurantId).',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      );
    }

    if (tableLinkToken.isNotEmpty && !_didAutoValidateFromQr) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _didAutoValidateFromQr = true;
        _controller.text = tableLinkToken;
        ref
            .read(tableSessionProvider.notifier)
            .validateTable(tableLinkToken, restaurantId: restaurantId);
      });
    }

    return ListView(
      children: [
        const SizedBox(height: 24),
        Text('Bienvenue', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          'Scannez votre QR code de table pour le restaurant $restaurantId.',
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
        const SizedBox(height: 20),
        tableSessionState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) =>
              ErrorState(message: '$error', onRetry: _validate),
          data: (session) {
            if (session == null) {
              return const SizedBox.shrink();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                            MaterialPageRoute(
                              builder: (_) => MenuScreen(session: session),
                            ),
                          );
                        }
                      : null,
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
    return Scaffold(
      body: DecoratedBox(
        decoration: AppTheme.warmBackground(),
        child: SafeArea(
          child: ResponsiveScaffoldBody(child: _buildRealBackendEntry(context)),
        ),
      ),
    );
  }
}
