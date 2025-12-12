# Flutter Application Technical Overview

This document describes the project structure, listing folders and files in a tree form and briefly explaining the purpose and contents of each. Use it as a guide to quickly locate code when adding features or making changes.

## Project Tree

```
flutter_application_1/
├─ pubspec.yaml
├─ README.md (optional)
├─ TECHNICAL_OVERVIEW.md  ← You are here
└─ lib/
   ├─ main.dart
   ├─ services/
   │  ├─ session.dart
   │  └─ cart_service.dart
   ├─ screens/
   │  ├─ welcome_screen.dart
   │  ├─ login_screen.dart
   │  ├─ register_screen.dart
   │  ├─ main_screen.dart
   │  ├─ category_stores_screen.dart
   │  ├─ store_detail_screen.dart
   │  ├─ product_detail_screen.dart
   │  ├─ cart_screen.dart
   │  └─ payment_screen.dart
   └─ widgets/
      └─ cart_icon_button.dart
```

## Files and Responsibilities

- pubspec.yaml
  - Flutter/Dart SDK constraints, app metadata and dependencies.
  - Includes shared_preferences for session storage.

- README.md (optional)
  - Project introduction, setup steps, and usage instructions (add as needed).

- TECHNICAL_OVERVIEW.md
  - This technical map of the repository.

- lib/main.dart
  - Root `MaterialApp` setup: theme, routes, and initial screen.
  - Registers routes: `/home`, `/login`, `/register`, `/main`.
  - Entry point `main()` runs `MyApp`.

### lib/services

- services/session.dart
  - Simple session persistence with `SharedPreferences`.
  - API: `setUserName(String)`, `getUserName()`, `clear()`.

- services/cart_service.dart
  - Cart state management (in-memory) with grouping per store.
  - Exposes `ValueNotifier<int> itemCount` for badge updates.
  - APIs:
    - `addProduct(storeId, productId, {qty})`, `removeProduct(storeId, productId, {qty})`.
    - `countForStore(storeId)`, `snapshot()` (deep copy), `clear()`.

### lib/screens

- screens/welcome_screen.dart
  - Landing screen with call-to-action to start (navigates to login).

- screens/login_screen.dart
  - Email/password form; basic field validation.
  - On success, saves a derived username to session and navigates to `/main`.

- screens/register_screen.dart
  - Name/email/password form; basic field validation.
  - On success, saves name to session and navigates to `/main`.

- screens/main_screen.dart
  - Home after auth: greets the user in the `AppBar` using `SessionService`.
  - Shows 6 shopping categories in a 2x3 grid.
  - AppBar actions: cart badge button and logout. Logout clears session and returns to Welcome.
  - On tapping a category, navigates to `CategoryStoresScreen` with the category label.

- screens/category_stores_screen.dart
  - Header: back button, category title, cart badge.
  - Search field for stores/products.
  - Horizontal filter chips (e.g., Mejor puntuación, Envío gratis...).
  - List of stores (mock): each item shows avatar, name, rating, and distance.
  - On tap: navigates to `StoreDetailScreen` passing `storeId` and `storeName`.

- screens/store_detail_screen.dart
  - Store detail view with cover (SliverAppBar), search action, and cart badge.
  - Info section: delivery time, shipping cost, rating. Promotions box.
  - Category selector (TabBar) displayed as a pinned `SliverPersistentHeader` (sticky).
  - Product content: vertical sections by category. Each section is a grid (2 per row).
  - Syncs active Tab with vertical scroll and supports tapping a tab to auto-scroll to its section.
  - Category names are non-sticky (only the TabBar is sticky).
  - On product tap: navigates to `ProductDetailScreen`.

- screens/product_detail_screen.dart
  - Product detail page with:
    - AppBar back button only.
    - Large product image (~40% height).
    - Pricing: current price and original (struck-through) if discounted.
    - Title and description.
    - Customization questions (single/multiple choice; mock data) using chips.
    - Bottom bar: quantity selector and “Add” button showing `qty x unit price`.
  - On add: pushes items to the grouped cart via `CartService` and shows a snackbar.

- screens/cart_screen.dart
  - Cart view grouped by store (using `CartService.snapshot()`):
    - For each store: store header with item count and list of product rows.
    - Per-row quantity controls (+/−) update the cart and totals.
    - Bottom bar: total items, “Vaciar” (clear), y botón “Pagar” que navega a PaymentScreen.

- screens/payment_screen.dart
  - Checkout page with:
    - AppBar with back and title 'Pago'.
    - Order summary (items, subtotal) computed from cart snapshot.
    - Payment method selection: Tarjeta, Transferencia, Efectivo.
      - Tarjeta: shows card form (name, number, MM/AA, CVV).
      - Transferencia: input for transfer number.
      - Efectivo: no form; pay on delivery.
    - Coupon section: apply code (demo: DESC10 → 10% off).
    - Cost breakdown: subtotal, shipping, discounts/savings, total.

### lib/widgets

- widgets/cart_icon_button.dart
  - Reusable AppBar button for the cart, showing a badge with the total item count.
  - Navigates to `CartScreen` when pressed.

## Navigation Overview

- WelcomeScreen → Login/Register → MainScreen (`/main`).
- MainScreen category tile → CategoryStoresScreen(category).
- CategoryStoresScreen store tap → StoreDetailScreen(storeId, storeName).
- StoreDetailScreen product tap → ProductDetailScreen(storeId, productId, name, price, discountPrice, imageUrl).
- Cart accessible from AppBars (except payment screens in the future).

## Notes and Future Improvements

- Persisting cart state across app restarts can be added via `SharedPreferences` (serialize `snapshot()`).
- Replace mock data (stores/products) with backend API integration.
- Enhance StoreDetail scrolling by updating tab selection using section offsets with tighter thresholds.
- Add visual elevation or divider to pinned TabBar for better separation.
- Extract product/store models to dedicated files if integrating real data.
