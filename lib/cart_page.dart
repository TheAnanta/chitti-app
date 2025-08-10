import 'package:chitti/data/semester.dart';
import 'package:chitti/injector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String? couponCode = Injector.cartRepository.coupon?.code;
  Coupon? coupon = Injector.cartRepository.coupon;
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  @override
  Widget build(BuildContext context) {
    print("Cart items: ${Injector.cartRepository.items}");
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
      appBar: AppBar(
        title: Text('Cart'),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
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

                                    Injector.cartRepository.persist(context);
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
                                '₹${Injector.cartRepository.getPrice(cartItem.courseId, subscriptionType)}',
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
                  Text(
                    couponCode == null
                        ? "Have a coupon?"
                        : "Coupon code: $couponCode (-₹${coupon?.discount ?? 0})",
                    style:
                        couponCode == null
                            ? null
                            : TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                  ),
                  Spacer(),
                  TextButton(
                    onPressed:
                        cartItems.isEmpty
                            ? null
                            : () {
                              if (couponCode != null) {
                                couponCode = null;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Coupon code removed'),
                                  ),
                                );
                                setState(() {});
                                return;
                              } else {
                                // Show dialog to enter coupon code
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('Enter Coupon Code'),
                                      content: TextField(
                                        onChanged: (value) {
                                          couponCode = value;
                                        },
                                        decoration: InputDecoration(
                                          hintText: 'Enter your coupon code',
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            if (couponCode != null &&
                                                couponCode!.isNotEmpty) {
                                              coupon = await Injector
                                                  .cartRepository
                                                  .applyCoupon(
                                                    couponCode!,
                                                    context,
                                                  );
                                              print(coupon);
                                              if (coupon == null ||
                                                  (coupon?.minAmount ?? 0) >
                                                      Injector
                                                          .cartRepository
                                                          .totalPrice) {
                                                couponCode = null;
                                                coupon = null;
                                                Injector.cartRepository.coupon =
                                                    null;
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Invalid coupon code or minimum amount not met.',
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Coupon applied: ${coupon?.code}',
                                                    ),
                                                  ),
                                                );
                                                couponCode = coupon?.code;
                                              }
                                              setState(() {});
                                            }
                                            Navigator.pop(context);
                                          },
                                          child: Text('Apply'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                    child: Text(
                      couponCode == null ? "Apply" : "Remove",
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
                ValueListenableBuilder<bool>(
                  valueListenable: isLoading,
                  builder: (BuildContext context, value, Widget? child) {
                    return FloatingActionButton.extended(
                      backgroundColor:
                          cartItems.isEmpty
                              ? Theme.of(context).disabledColor
                              : Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      onPressed:
                          cartItems.isEmpty
                              ? null
                              : value
                              ? null
                              : () async {
                                if (Injector.cartRepository.cartId == null) {
                                  await Injector.cartRepository.fetchCartId(
                                    context,
                                  );
                                }
                                await Injector.cartRepository.persist(context);
                                // Handle checkout action
                                await Injector.cartRepository.checkout(
                                  context,
                                  coupon: coupon,
                                  onLoading: (p0) {
                                    isLoading.value = p0;
                                  },
                                );
                              },

                      label:
                          value
                              ? CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.onPrimary,
                              )
                              : Text('Checkout'),
                      icon: Icon(Icons.payment),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Coupon {
  final String couponId;
  final String code;
  final double discount;
  final DateTime expiryDate;
  final DateTime validFrom;
  final double minAmount;
  Coupon({
    required this.couponId,
    required this.code,
    required this.discount,
    required this.expiryDate,
    required this.validFrom,
    required this.minAmount,
  });
}
