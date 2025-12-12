import 'package:flutter/material.dart';
import '../services/cart_service.dart';

enum PaymentMethod { cash, transfer, card }

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod _method = PaymentMethod.cash;
  final _cardNameCtrl = TextEditingController();
  final _cardNumberCtrl = TextEditingController();
  final _cardExpiryCtrl = TextEditingController();
  final _cardCvvCtrl = TextEditingController();
  final _transferNumberCtrl = TextEditingController();
  final _couponCtrl = TextEditingController();

  bool _couponApplied = false;

  @override
  void dispose() {
    _cardNameCtrl.dispose();
    _cardNumberCtrl.dispose();
    _cardExpiryCtrl.dispose();
    _cardCvvCtrl.dispose();
    _transferNumberCtrl.dispose();
    _couponCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totals = _computeTotals();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Pago'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen del pedido',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _OrderSummary(
              totalItems: totals.totalItems,
              subtotal: totals.subtotal,
            ),
            const SizedBox(height: 16),

            Text(
              'Método de pago',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildPaymentMethod(),
            const SizedBox(height: 12),
            _buildConditionalPaymentForm(),
            const SizedBox(height: 16),

            Text(
              'Cupón de descuento',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _couponCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Ingresa tu cupón',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _couponApplied =
                          _couponCtrl.text.trim().toUpperCase() == 'DESC10';
                    });
                  },
                  child: const Text('Aplicar'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              'Resumen de costos',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _CostBreakdown(
              subtotal: totals.subtotal,
              shipping: totals.shipping,
              discount: _couponApplied ? totals.subtotal * 0.10 : 0.0,
              savings: 0.0,
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pedido confirmado')),
                  );
                },
                child: Text(
                  'Confirmar pedido • \$${_finalTotal(totals).toStringAsFixed(2)}',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Column(
      children: [
        RadioListTile<PaymentMethod>(
          value: PaymentMethod.card,
          groupValue: _method,
          onChanged: (v) => setState(() => _method = v!),
          title: const Text('Tarjeta'),
        ),
        RadioListTile<PaymentMethod>(
          value: PaymentMethod.transfer,
          groupValue: _method,
          onChanged: (v) => setState(() => _method = v!),
          title: const Text('Transferencia'),
        ),
        RadioListTile<PaymentMethod>(
          value: PaymentMethod.cash,
          groupValue: _method,
          onChanged: (v) => setState(() => _method = v!),
          title: const Text('Efectivo'),
        ),
      ],
    );
  }

  Widget _buildConditionalPaymentForm() {
    switch (_method) {
      case PaymentMethod.card:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _cardNameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre en la tarjeta',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _cardNumberCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Número de tarjeta',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cardExpiryCtrl,
                    decoration: const InputDecoration(
                      labelText: 'MM/AA',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _cardCvvCtrl,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'CVV',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      case PaymentMethod.transfer:
        return TextField(
          controller: _transferNumberCtrl,
          decoration: const InputDecoration(
            labelText: 'Número de transferencia',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          keyboardType: TextInputType.number,
        );
      case PaymentMethod.cash:
        return const Text('Pagarás en efectivo al recibir el pedido.');
    }
  }

  double _finalTotal(_Totals t) {
    final discount = _couponApplied ? t.subtotal * 0.10 : 0.0;
    return (t.subtotal + t.shipping - discount).clamp(0.0, double.infinity);
  }

  _Totals _computeTotals() {
    final snap = CartService.snapshot();
    int totalItems = 0;
    for (final m in snap.values) {
      for (final q in m.values) {
        totalItems += q;
      }
    }
    final subtotal = totalItems * 10.0;
    final shipping = totalItems > 0 ? 2.5 : 0.0;
    return _Totals(
      totalItems: totalItems,
      subtotal: subtotal,
      shipping: shipping,
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final int totalItems;
  final double subtotal;
  const _OrderSummary({required this.totalItems, required this.subtotal});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long),
          const SizedBox(width: 8),
          Expanded(child: Text('Items: $totalItems')),
          Text('\$${subtotal.toStringAsFixed(2)}'),
        ],
      ),
    );
  }
}

class _CostBreakdown extends StatelessWidget {
  final double subtotal;
  final double shipping;
  final double discount;
  final double savings;
  const _CostBreakdown({
    required this.subtotal,
    required this.shipping,
    required this.discount,
    required this.savings,
  });

  @override
  Widget build(BuildContext context) {
    final total = (subtotal + shipping - discount - savings).clamp(
      0.0,
      double.infinity,
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          _row('Subtotal', subtotal),
          _row('Envío', shipping),
          _row('Descuento', -discount),
          _row('Ahorro', -savings),
          const Divider(height: 16),
          _row('Total', total, isBold: true),
        ],
      ),
    );
  }

  Widget _row(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          Text(
            (value >= 0 ? '' : '-') + '\$' + value.abs().toStringAsFixed(2),
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _Totals {
  final int totalItems;
  final double subtotal;
  final double shipping;
  _Totals({
    required this.totalItems,
    required this.subtotal,
    required this.shipping,
  });
}
