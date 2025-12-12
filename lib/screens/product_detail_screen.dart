import 'package:flutter/material.dart';
import '../services/cart_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final String storeId;
  final String productId;
  final String name;
  final double price;
  final double? discountPrice;
  final String? imageUrl;

  const ProductDetailScreen({
    super.key,
    required this.storeId,
    required this.productId,
    required this.name,
    required this.price,
    this.discountPrice,
    this.imageUrl,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _qty = 1;

  // Mock de personalización: dos preguntas
  final List<_Question> _questions = [
    _Question(
      id: 'q1',
      text: 'Tamaño',
      type: QuestionType.single,
      options: const [
        _Option(id: 's', label: 'S'),
        _Option(id: 'm', label: 'M'),
        _Option(id: 'l', label: 'L'),
      ],
    ),
    _Question(
      id: 'q2',
      text: 'Extras',
      type: QuestionType.multiple,
      options: const [
        _Option(id: 'e1', label: 'Queso extra'),
        _Option(id: 'e2', label: 'Salsa'),
        _Option(id: 'e3', label: 'Tocineta'),
      ],
    ),
  ];

  final Map<String, Set<String>> _answers = {};

  double get unitPrice =>
      (widget.discountPrice != null && widget.discountPrice! < widget.price)
      ? widget.discountPrice!
      : widget.price;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final hasDiscount =
        widget.discountPrice != null && widget.discountPrice! < widget.price;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen 40% altura
            Container(
              height: height * 0.4,
              width: double.infinity,
              color: Colors.grey.shade200,
              alignment: Alignment.center,
              child: widget.imageUrl == null
                  ? const Icon(Icons.image, size: 72, color: Colors.black26)
                  : Image.network(widget.imageUrl!, fit: BoxFit.cover),
            ),

            // Precios
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Text(
                    '4${unitPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (hasDiscount) ...[
                    Text(
                      '4${widget.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Título y descripción
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Descripción del producto. Texto de ejemplo para explicar ingredientes y detalles.',
                style: TextStyle(color: Colors.black87),
              ),
            ),
            const SizedBox(height: 16),

            // Preguntas de personalización
            ..._questions.map(
              (q) => _QuestionWidget(
                question: q,
                selected: _answers[q.id] ?? <String>{},
                onChanged: (newSet) => setState(() => _answers[q.id] = newSet),
              ),
            ),

            const SizedBox(height: 80), // espacio para la barra inferior
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
            _QtySelector(
              qty: _qty,
              onMinus: () => setState(() => _qty = _qty > 1 ? _qty - 1 : 1),
              onPlus: () => setState(() => _qty += 1),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  CartService.addProduct(
                    storeId: widget.storeId,
                    productId: widget.productId,
                    qty: _qty,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Producto agregado al carrito'),
                    ),
                  );
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Agregar  •  ${_qty} x \u0024${unitPrice.toStringAsFixed(2)}',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QtySelector extends StatelessWidget {
  final int qty;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  const _QtySelector({
    required this.qty,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QtyBtn(icon: Icons.remove, onTap: onMinus),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(
            '$qty',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        _QtyBtn(icon: Icons.add, onTap: onPlus),
      ],
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, size: 18),
        ),
      ),
    );
  }
}

enum QuestionType { single, multiple }

class _Question {
  final String id;
  final String text;
  final QuestionType type;
  final List<_Option> options;
  const _Question({
    required this.id,
    required this.text,
    required this.type,
    required this.options,
  });
}

class _Option {
  final String id;
  final String label;
  const _Option({required this.id, required this.label});
}

class _QuestionWidget extends StatelessWidget {
  final _Question question;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;
  const _QuestionWidget({
    required this.question,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.text,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: question.options.map((opt) {
              final isSelected = selected.contains(opt.id);
              return ChoiceChip(
                label: Text(opt.label),
                selected: isSelected,
                onSelected: (val) {
                  final current = Set<String>.from(selected);
                  if (question.type == QuestionType.single) {
                    current
                      ..clear()
                      ..add(opt.id);
                  } else {
                    if (val) {
                      current.add(opt.id);
                    } else {
                      current.remove(opt.id);
                    }
                  }
                  onChanged(current);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
