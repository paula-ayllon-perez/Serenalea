class User {
  final String uid;
  final int birthYear;
  final String email;
  final String firstName;
  final String gender;
  final String lastName;
  final String phone;
  final List<String> profiles;
  final String? photoUrl;

  User({
  required this.uid,
  required this.birthYear,
  required this.email,
  required this.firstName,
  required this.gender,
  required this.lastName,
  required this.phone,
  required this.profiles,
  this.photoUrl,
  });

  /// Factory to create a User from a Firestore document
  factory User.fromMap(Map<String, dynamic> map, String documentId) {
    return User(
      uid: documentId,
      birthYear: map['birthYear'] ?? 0,
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? '',
      gender: map['gender'] ?? '',
      lastName: map['lastName'] ?? '',
      phone: map['phone'] ?? '',
      profiles: List<String>.from(map['profiles'] ?? []),
      photoUrl: map['photoUrl'],
    );
  }

  /// Convert a User to a Firestore document
  Map<String, dynamic> toMap() {
    return {
      'birthYear': birthYear,
      'email': email,
      'firstName': firstName,
      'gender': gender,
      'lastName': lastName,
      'phone': phone,
      'profiles': profiles,
      'photoUrl': photoUrl,
    };
  }
}
