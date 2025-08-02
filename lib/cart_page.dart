import 'package:chitti/data/semester.dart';
import 'package:chitti/injector.dart';
import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    final cartItems =
        List<Subject>.from(
              Injector.semesterRepository.semester?.courses.values.fold(
                    List<Subject>.empty(),
                    (prev, t) => [...prev ?? [], ...t],
                  ) ??
                  [],
            )
            .where(
              (subject) => Injector.cartRepository.items.any(
                (cartItem) => cartItem.item == subject.courseId,
              ),
            )
            .toList()
            .map(
              (e) => (
                e,
                Injector.cartRepository.items
                    .firstWhere((cartItem) => cartItem.item == e.courseId)
                    .type,
              ),
            )
            .toList();
    return Scaffold(
      appBar: AppBar(title: Text('Cart')),
      body: Center(
        child:
            cartItems.isEmpty
                ? Text('Your cart is empty!')
                : ListView.separated(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartItems[index].$1;
                    final subscriptionType = cartItems[index].$2;
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(cartItem.icon),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  cartItem.courseId,
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(cartItem.title),
                                Text(
                                  cartItem.description,
                                  maxLines: 2,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Handle remove action
                                    Injector.cartRepository.removeItem(
                                      cartItem.courseId,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${cartItem.title} removed from cart',
                                        ),
                                      ),
                                    );
                                    setState(() {});
                                  },
                                  child: Text('Remove'),
                                  style: TextButton.styleFrom(
                                    foregroundColor:
                                        Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(64),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                    horizontal: 12,
                                  ),
                                  child: Text(
                                    subscriptionType
                                        .toString()
                                        .split('.')
                                        .last
                                        .toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '₹52',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder:
                      (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Divider(),
                      ),
                ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceTint.withValues(alpha: 0.2),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16,
              ),
              child: Row(
                children: [
                  Text("Have a coupon?"),
                  Spacer(),
                  TextButton(
                    onPressed: () {
                      // Handle coupon code logic
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Coupon code feature not implemented'),
                        ),
                      );
                    },
                    child: Text(
                      "Apply",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          BottomAppBar(
            height: 86,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total', style: TextStyle(fontSize: 14)),
                    Text(
                      '₹${Injector.cartRepository.totalPrice}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                FloatingActionButton.extended(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  onPressed: () {
                    // Handle checkout action
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Checkout not implemented')),
                    );
                  },
                  label: Text('Checkout'),
                  icon: Icon(Icons.payment),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
