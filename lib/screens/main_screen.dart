import 'package:flutter/material.dart';
import '../services/session.dart';
import 'welcome_screen.dart';
import 'category_stores_screen.dart';
import '../widgets/cart_icon_button.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String?>(
          future: SessionService.getUserName(),
          builder: (context, snap) {
            final name = (snap.data ?? '').trim();
            final display = name.isNotEmpty ? name : 'Usuario';
            return Text('Hola, $display');
          },
        ),
        actions: [
          const CartIconButton(),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await SessionService.clear();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: const [
            _CategoryTile(
              label: 'Comida',
              icon: Icons.restaurant_menu,
              color: Colors.redAccent,
            ),
            _CategoryTile(
              label: 'Farmacia',
              icon: Icons.local_pharmacy,
              color: Colors.green,
            ),
            _CategoryTile(
              label: 'Bebidas',
              icon: Icons.local_drink,
              color: Colors.amber,
            ),
            _CategoryTile(
              label: 'Hogar',
              icon: Icons.home_filled,
              color: Colors.teal,
            ),
            _CategoryTile(
              label: 'Tecnología',
              icon: Icons.devices_other,
              color: Colors.indigo,
            ),
            _CategoryTile(
              label: 'Ropa',
              icon: Icons.checkroom,
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _CategoryTile({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CategoryStoresScreen(category: label),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
