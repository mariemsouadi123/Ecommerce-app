import 'package:ecommerce_app/features/auth/domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? address;
  final String? phone;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.address,
    this.phone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'],
      name: json['name'],
      email: json['email'],
      address: json['address'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'address': address,
      'phone': phone,
    };
  }
  UserEntity toEntity() {
  return UserEntity(
    id: id,
    name: name,
    email: email,
    address: address,
    phone: phone,
  );
}
}