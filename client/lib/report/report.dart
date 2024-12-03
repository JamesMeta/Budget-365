class Report {
  final int id;
  final int groupID;
  final int type;
  final int userID;
  final double amount;
  final String description;
  final String category;
  final DateTime date;

  Report({
    required this.id,
    required this.groupID,
    required this.userID,
    required this.type,
    required this.amount,
    required this.description,
    required this.category,
    required this.date,
  });

  //converts the Report instance to a JSON-compatible map (for exporting to user device)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupID': groupID,
      'type': type,
      'userID': userID,
      'amount': amount,
      'description': description,
      'category': category,
      'date': date.toIso8601String(),
    };
  }
}
