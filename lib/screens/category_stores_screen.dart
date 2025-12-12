import 'package:flutter/material.dart';
import '../widgets/cart_icon_button.dart';
import 'store_detail_screen.dart';

class CategoryStoresScreen extends StatefulWidget {
  final String category;
  const CategoryStoresScreen({super.key, required this.category});

  @override
  State<CategoryStoresScreen> createState() => _CategoryStoresScreenState();
}

class _CategoryStoresScreenState extends State<CategoryStoresScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final List<String> _filters = const [
    'Mejor puntuación',
    'Envío gratis',
    'Abierto ahora',
    'Entrega rápida',
  ];
  final Set<String> _selected = {};

  // Mock de locales comerciales
  final List<_Store> _stores = [
    _Store('Super Burgers', 4.7, 1.2),
    _Store('Farmacia Salud', 4.5, 0.8),
    _Store('Bebidas La Esquina', 4.3, 2.1),
    _Store('Abarrotes Hogar', 4.0, 3.4),
    _Store('TecnoTienda', 4.8, 1.0),
    _Store('Moda Urbana', 4.1, 2.7),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.category),
        actions: const [CartIconButton()],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Buscar locales o productos',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) {
                final f = _filters[i];
                final selected = _selected.contains(f);
                return FilterChip(
                  label: Text(f),
                  selected: selected,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _selected.add(f);
                      } else {
                        _selected.remove(f);
                      }
                    });
                  },
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: _filters.length,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: _filteredStores.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final store = _filteredStores[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.15),
                    child: const Icon(Icons.store, color: Colors.black87),
                  ),
                  title: Text(store.name),
                  subtitle: Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(store.rating.toStringAsFixed(1)),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.place,
                        size: 16,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(width: 4),
                      Text('${store.distanceKm.toStringAsFixed(1)} km'),
                    ],
                  ),
                  onTap: () {
                    final storeId = store.name.toLowerCase().replaceAll(
                      ' ',
                      '_',
                    );
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => StoreDetailScreen(
                          storeId: storeId,
                          storeName: store.name,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<_Store> get _filteredStores {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _stores;
    return _stores.where((s) => s.name.toLowerCase().contains(q)).toList();
  }
}

class _Store {
  final String name;
  final double rating;
  final double distanceKm;
  _Store(this.name, this.rating, this.distanceKm);
}
