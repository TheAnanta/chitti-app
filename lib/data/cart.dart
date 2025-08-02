enum SubscriptionType { free, mid, sem }

class CartItem {
  final String item;
  final SubscriptionType type;

  CartItem({required this.item, required this.type});
}

class CartRepository {
  List<CartItem> items;

  CartRepository() : items = [];

  void addItem(String item, SubscriptionType type) {
    items.add(CartItem(item: item, type: type));
  }

  void removeItem(String item) {
    items.removeWhere((cartItem) => cartItem.item == item);
  }

  double get totalPrice {
    // Assuming each item has a fixed price of $10 for simplicity
    return items.fold(0.0, (total, cartItem) {
      switch (cartItem.type) {
        case SubscriptionType.free:
          return total + 0.0;
        case SubscriptionType.mid:
          return total + 52;
        case SubscriptionType.sem:
          return total + 102;
      }
    });
  }
}
