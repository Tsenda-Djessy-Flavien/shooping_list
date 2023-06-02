import 'package:shopping_list/domain/models/category_model.dart';

class GroceryModel {
  const GroceryModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.category,
  });

  final String id, name;
  final int quantity;
  final CategoryModel category;
}
