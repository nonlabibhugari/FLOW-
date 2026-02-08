class Product {
  int? id;
  String name;
  int quantity;
  String supplier;
  String imagePath;
  String status;

  Product({
    this.id,
    required this.name,
    required this.quantity,
    required this.supplier,
    required this.imagePath,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'supplier': supplier,
      'imagePath': imagePath,
      'status': status,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      quantity: map['quantity'],
      supplier: map['supplier'],
      imagePath: map['imagePath'],
      status: map['status'],
    );
  }
}
