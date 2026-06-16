# Interface Client Flutter - Prise de Commande Restaurant

Application mobile/tablette (priorite mobile) permettant a un client de commander depuis sa table via QR code.

## Stack

- Flutter (null safety)
- Riverpod (gestion d etat)
- Dio + interceptors (API)
- Architecture feature-first

## Parcours client couvert

1. Entree via QR/code table
2. Consultation du menu avec recherche + filtres
3. Detail article + note speciale
4. Panier (quantites, suppression, note generale)
5. Confirmation commande
6. Suivi de statut en temps reel (fallback polling 5s)

## Architecture

```text
lib/
	core/
		constants/
		errors/
		network/
		theme/
		utils/
		widgets/
	features/
		table_entry/
			presentation/screens/
		ordering/
			data/
				datasources/
				models/
				repositories/
			domain/
				entities/
				repositories/
				usecases/
			presentation/
				providers/
				screens/
				widgets/
```

## Configuration backend

Mettre `useMockData` a `false` dans [lib/core/constants/app_constants.dart](lib/core/constants/app_constants.dart) puis ajuster `apiBaseUrl`.

Endpoints attendus cote NestJS:
- `GET /tables/validate?code=...`
- `GET /restaurants/:restaurantId/menu`
- `POST /orders`
- `GET /orders/:orderId`

## Lancement

```bash
flutter pub get
flutter run
```

## Tests

```bash
flutter test
```

## Extensions v2 proposees

- Paiement en ligne (Stripe/PayPal)
- Code promo et fidelite
- Multi-langue (i18n arb)
- Historique des commandes client
- Push notifications de progression
# Restaurant
