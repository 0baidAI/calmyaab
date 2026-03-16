class StudentModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String university;
  final String field;
  final List<String> paidServices;
  final DateTime createdAt;

  const StudentModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.university,
    required this.field,
    required this.paidServices,
    required this.createdAt,
  });

  factory StudentModel.fromMap(Map<String, dynamic> map, String uid) {
    return StudentModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      university: map['university'] ?? '',
      field: map['field'] ?? '',
      paidServices: List<String>.from(map['paid_services'] ?? []),
      createdAt: map['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'phone': phone,
    'university': university,
    'field': field,
    'paid_services': paidServices,
    'created_at': createdAt.millisecondsSinceEpoch,
  };

  bool hasPaid(String service) => paidServices.contains(service);
}
