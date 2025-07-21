import 'package:ecommerce_app/features/auth/domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? address;
  final String? phone;
  final String? imageUrl;
  final String? token;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.address,
    this.phone,
    this.imageUrl,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      address: json['address']?.toString(),
      phone: json['phone']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      token: json['token']?.toString(),
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      address: address,
      phone: phone,
      imageUrl: imageUrl,
      token: token,
    );
  }
}