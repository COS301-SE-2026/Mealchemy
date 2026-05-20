class User{
  final int userId;
  final String email;
  final String displayName;
  final String role;

  const User({
    required this.userId,
    required this.email,
    required this.displayName,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json){
    return User(
      userId: json['userId'] as int,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      role: json['role'] as String,
    );
  }
}