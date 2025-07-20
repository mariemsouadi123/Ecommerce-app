
class UserEntity  {
  final String id;
  final String name;
  final String email;
  final String? address;
  final String? phone;
  final String? imageUrl;
  UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.address,
    this.phone,
    this.imageUrl,

  });
}