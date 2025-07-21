class UserEntity {
  final String id;
  final String name;
  final String email;
  final String? address;
  final String? phone;
  final String? imageUrl;
  final String? token; // Add this field


  // Constructor
  UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.address,
    this.phone,
    this.imageUrl,
     this.token, // Add this

  });

  // copyWith method
  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? address,
    String? phone,
    String? imageUrl,
     String? token,

  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
      token: token ?? this.token,

    );
  }
}
