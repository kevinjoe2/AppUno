import 'package:flutter/material.dart';
import '../widgets/cart_icon_button.dart';
import '../services/cart_service.dart';
import 'product_detail_screen.dart';

class StoreDetailScreen extends StatefulWidget {
  final String storeId;
  final String storeName;
  const StoreDetailScreen({
    super.key,
    required this.storeId,
    required this.storeName,
  });

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final List<String> _categories = const [
    'Promos',
    'Combos',
    'Bebidas',
    'Snacks',
    'Postres',
  ];

  // Mock de productos por categoría
  late final Map<String, List<_Product>> _productsByCat = {
    'Promos': [
      _Product(
        id: 'p1',
        name: 'Promo Dúo',
        price: 18.0,
        discountPrice: 14.5,
        imageUrl: null,
      ),
      _Product(
        id: 'p2',
        name: 'Pack Ahorro',
        price: 25.0,
        discountPrice: 19.9,
        imageUrl: null,
      ),
    ],
    'Combos': [
      _Product(id: 'c1', name: 'Combo Familiar', price: 22.0, imageUrl: null),
      _Product(id: 'c2', name: 'Combo Individual', price: 12.0, imageUrl: null),
      _Product(
        id: 'c3',
        name: 'Combo Plus',
        price: 16.0,
        discountPrice: 13.0,
        imageUrl: null,
      ),
    ],
    'Bebidas': [
      _Product(id: 'b1', name: 'Cola 500ml', price: 1.8, imageUrl: null),
      _Product(id: 'b2', name: 'Agua 600ml', price: 1.2, imageUrl: null),
      _Product(
        id: 'b3',
        name: 'Jugo Naranja',
        price: 2.0,
        discountPrice: 1.6,
        imageUrl: null,
      ),
    ],
    'Snacks': [
      _Product(id: 's1', name: 'Papas Clásicas', price: 1.5, imageUrl: null),
      _Product(id: 's2', name: 'Nachos', price: 2.2, imageUrl: null),
    ],
    'Postres': [
      _Product(id: 'd1', name: 'Brownie', price: 2.5, imageUrl: null),
      _Product(id: 'd2', name: 'Helado', price: 1.9, imageUrl: null),
    ],
  };

  // Keys por categoría para poder hacer scroll programático desde el TabBar
  late final Map<String, GlobalKey> _sectionKeys = {
    for (final c in _categories) c: GlobalKey(),
  };
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coverHeight =
        MediaQuery.of(context).size.height * 0.30; // ~30% pantalla

    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification ||
              notification is UserScrollNotification) {
            _updateCurrentCategoryByScroll();
          }
          return false;
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: coverHeight,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(widget.storeName),
              actions: [
                IconButton(
                  tooltip: 'Buscar producto',
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                ),
                const CartIconButton(),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Portada (placeholder con degradado)
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green, Colors.yellow, Colors.red],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    Container(color: Colors.black.withOpacity(0.15)),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre + logo
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white,
                          child: const Icon(Icons.store, color: Colors.black87),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.storeName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Info delivery/envío/reputación
                    Row(
                      children: [
                        Expanded(
                          child: _InfoBox(
                            icon: Icons.timer_outlined,
                            label: 'Entrega',
                            value: '25-35 min',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _InfoBox(
                            icon: Icons.local_shipping_outlined,
                            label: 'Envío',
                            value: '1.50',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _InfoBox(
                            icon: Icons.star_rate_rounded,
                            label: 'Rating',
                            value: '4.6',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Promociones
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.local_offer, color: Colors.orange),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Promociones: 2x1 en bebidas - 10% en combos seleccionados',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tabs de categorías se muestran en un header sticky debajo
                  ],
                ),
              ),
            ),
            // Header sticky con TabBar de categorías
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyHeaderDelegate(
                minExtent: 48,
                maxExtent: 48,
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: Theme.of(context).colorScheme.primary,
                    unselectedLabelColor: Colors.black87,
                    onTap: (index) {
                      final cat = _categories[index];
                      final key = _sectionKeys[cat];
                      final ctx = key?.currentContext;
                      if (ctx != null) {
                        Scrollable.ensureVisible(
                          ctx,
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                          alignment: 0.05,
                        );
                      }
                    },
                    tabs: _categories.map((c) => Tab(text: c)).toList(),
                  ),
                ),
              ),
            ),
            // Secciones verticales por categoría con Grid no desplazable
            ..._buildCategorySlivers(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCategorySlivers() {
    final List<Widget> slivers = [];
    for (final cat in _categories) {
      final items = _productsByCat[cat] ?? const <_Product>[];
      slivers.add(
        SliverPersistentHeader(
          pinned: false,
          delegate: _StickyHeaderDelegate(
            minExtent: 36,
            maxExtent: 44,
            child: Container(
              key: _sectionKeys[cat],
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.centerLeft,
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Text(
                cat,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      );
      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            delegate: SliverChildBuilderDelegate((context, i) {
              final p = items[i];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(
                        storeId: widget.storeId,
                        productId: p.id,
                        name: p.name,
                        price: p.price,
                        discountPrice: p.discountPrice,
                        imageUrl: p.imageUrl,
                      ),
                    ),
                  );
                },
                child: _ProductCard(
                  product: p,
                  onAdd: () => CartService.addProduct(
                    storeId: widget.storeId,
                    productId: p.id,
                    qty: 1,
                  ),
                ),
              );
            }, childCount: items.length),
          ),
        ),
      );
    }
    return slivers;
  }

  void _updateCurrentCategoryByScroll() {
    // Determina qué sección está más cerca de la parte superior visible
    // Ajuste para compensar SliverAppBar y paddings
    const double topOffset = 140.0;
    int bestIndex = _currentIndex;
    double bestDelta = double.infinity;

    for (var i = 0; i < _categories.length; i++) {
      final key = _sectionKeys[_categories[i]];
      final ctx = key?.currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null) continue;
      final dy = box.localToGlobal(Offset.zero).dy;
      final delta = (dy - topOffset).abs();
      if (dy >= 0 && delta < bestDelta) {
        bestDelta = delta;
        bestIndex = i;
      }
    }

    if (bestIndex != _currentIndex) {
      _currentIndex = bestIndex;
      if (mounted && _tabController.index != bestIndex) {
        _tabController.animateTo(bestIndex);
      }
    }
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  final double minExtent;
  @override
  final double maxExtent;
  final Widget child;

  _StickyHeaderDelegate({
    required this.minExtent,
    required this.maxExtent,
    required this.child,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) {
    return minExtent != oldDelegate.minExtent ||
        maxExtent != oldDelegate.maxExtent ||
        child != oldDelegate.child;
  }
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoBox({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final _Product product;
  final VoidCallback onAdd;
  const _ProductCard({required this.product, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final hasDiscount =
        product.discountPrice != null && product.discountPrice! < product.price;
    final discountPct = hasDiscount
        ? (100 - (product.discountPrice! / product.price) * 100).round()
        : 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.image,
                    size: 48,
                    color: Colors.black26,
                  ),
                ),
                if (hasDiscount)
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '-$discountPct%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onAdd,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.add, size: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (hasDiscount) ...[
                      Text(
                        ' 24${product.discountPrice!.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        ' 24${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.black54,
                        ),
                      ),
                    ] else ...[
                      Text(
                        ' 24${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Product {
  final String id;
  final String name;
  final double price;
  final double? discountPrice;
  final String? imageUrl;
  const _Product({
    required this.id,
    required this.name,
    required this.price,
    this.discountPrice,
    this.imageUrl,
  });
}
