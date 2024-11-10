class Report {
  final int id;
  final int groupID;
  final int type;
  final double amount;
  final String description;
  final String username;
  final String category;
  final DateTime date;

  Report({
    required this.id,
    required this.groupID,
    required this.username,
    required this.type,
    required this.amount,
    required this.description,
    required this.category,
    required this.date,
  });
}
