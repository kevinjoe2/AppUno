import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import 'payment_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final snapshot = CartService.snapshot();
    final hasItems = snapshot.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Carrito')),
      body: hasItems ? _buildList(snapshot) : _buildEmpty(),
      bottomNavigationBar: hasItems ? _buildSummaryBar() : null,
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.black26),
          SizedBox(height: 12),
          Text('Tu carrito está vacío.'),
        ],
      ),
    );
  }

  Widget _buildList(Map<String, Map<String, int>> snapshot) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: snapshot.length,
      itemBuilder: (context, index) {
        final storeId = snapshot.keys.elementAt(index);
        final products = snapshot[storeId]!;
        final storeName = _formatStoreName(storeId);
        final storeCount = CartService.countForStore(storeId);
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.store, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        storeName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text('$storeCount items'),
                    ),
                  ],
                ),
                const Divider(height: 16),
                ...products.entries.map(
                  (e) => _CartRow(
                    storeId: storeId,
                    productId: e.key,
                    quantity: e.value,
                    onChanged: () => setState(() {}),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ValueListenableBuilder<int>(
              valueListenable: CartService.itemCount,
              builder: (context, total, _) => Text('Total items: $total'),
            ),
          ),
          TextButton(
            onPressed: () {
              CartService.clear();
              setState(() {});
            },
            child: const Text('Vaciar'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const PaymentScreen()));
            },
            child: const Text('Pagar'),
          ),
        ],
      ),
    );
  }

  String _formatStoreName(String id) {
    return id
        .split('_')
        .map((p) => p.isEmpty ? p : p[0].toUpperCase() + p.substring(1))
        .join(' ');
  }
}

class _CartRow extends StatelessWidget {
  final String storeId;
  final String productId;
  final int quantity;
  final VoidCallback onChanged;
  const _CartRow({
    required this.storeId,
    required this.productId,
    required this.quantity,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFECECEC),
            child: Icon(Icons.image, color: Colors.black38),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Producto $productId',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                const Text(
                  'Precio: —',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          _QtyButton(
            icon: Icons.remove,
            onTap: () {
              CartService.removeProduct(
                storeId: storeId,
                productId: productId,
                qty: 1,
              );
              onChanged();
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('$quantity'),
          ),
          _QtyButton(
            icon: Icons.add,
            onTap: () {
              CartService.addProduct(
                storeId: storeId,
                productId: productId,
                qty: 1,
              );
              onChanged();
            },
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(6.0),
          child: Icon(Icons.add, size: 18),
        ),
      ),
    );
  }
}
