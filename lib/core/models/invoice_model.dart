class InvoiceItem {

  final String productId;
  final int quantity;
  final double unitCost;
  final String description;
  final double federalTax;
  final double provinceTax;
  final double totalAmount;

  InvoiceItem({
    required this.productId,
    required this.quantity,
    required this.unitCost,
    required this.description,
    required this.federalTax,
    required this.provinceTax,
    required this.totalAmount,
  });

  // ------------------------
  // TO FIRESTORE MAP
  // ------------------------

  Map<String, dynamic> toMap() {
    return {
      "productId": productId,
      "quantity": quantity,
      "unitCost": unitCost,
      "description": description,
      "federalTax": federalTax,
      "provinceTax": provinceTax,
      "totalAmount": totalAmount,
    };
  }

  // ------------------------
  // FROM FIRESTORE MAP
  // ------------------------

  factory InvoiceItem.fromMap(Map<String, dynamic> map) {

    return InvoiceItem(
      productId: map['productId'] ?? "",
      quantity: map['quantity'] ?? 0,
      unitCost: (map['unitCost'] ?? 0).toDouble(),
      description: map['description'] ?? "",
      federalTax: (map['federalTax'] ?? 0).toDouble(),
      provinceTax: (map['provinceTax'] ?? 0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
    );
  }
}
