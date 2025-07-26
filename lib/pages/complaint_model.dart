
class Complaint {
  late String id;
  late String userId;
  late String category;
  late String complaintText;
  late String assignedTo;
  late DateTime timestamp;
  late String status;
  String userName = ''; // Added userName property

  Complaint({
    required this.id,
    required this.userId,
    required this.category,
    required this.complaintText,
    required this.assignedTo,
    required this.timestamp,
    required this.status,
    this.userName = '', // Provide a default value for userName
  });

  // Factory method to create a Complaint object from a map
  factory Complaint.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return Complaint(
        id: '',
        userId: '',
        category: '',
        complaintText: '',
        assignedTo: '',
        timestamp: DateTime.now(),
        status: 'Pending',
      );
    }

    return Complaint(
      id: map['id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      category: map['category'] as String? ?? '',
      complaintText: map['complaint_text'] as String? ?? '',
      assignedTo: map['assignedTo'] as String? ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int)
          : DateTime.now(),
      status: map['status'] as String? ?? 'Pending',
      userName: map['userName'] as String? ?? '', // Assign the value from the map to userName
    );
  }

  // Map the Complaint object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId, // Adjusted key to snake_case
      'category': category,
      'complaint_text': complaintText, // Adjusted key to snake_case
      'assignedTo': assignedTo,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'userName': userName, // Add userName to the map
    };
  }
}
