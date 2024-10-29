// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class GroupInterfaceWidget extends StatefulWidget {
//   const GroupInterfaceWidget({Key? key}) : super(key: key);

//   @override
//   _GroupInterfaceWidgetState createState() => _GroupInterfaceWidgetState();
// }

// class _GroupInterfaceWidgetState extends State<GroupInterfaceWidget> {
//   final SupabaseClient supabase = Supabase.instance.client;
//   late Future<List<Map<String, dynamic>>> _groupDataFuture;

//   @override
//   void initState() {
//     super.initState();
//     _groupDataFuture = _fetchGroupData();
//   }

//   Future<List<Map<String, dynamic>>> _fetchGroupData() async {
//     // Fetch aggregated data grouped by `group_id`
//     final response = await supabase
//         .from('transactions')
//         .select('group_id, sum(amount) as total_amount, count(*) as transaction_count')
//         .eq('type', 'expense') // You can change or remove this filter as needed
//         .group('group_id')
//         .execute();

//     if (response.error != null) {
//       // Handle error
//       throw Exception('Failed to load group data: ${response.error!.message}');
//     }

//     // Return the list of groups with aggregated data
//     return (response.data as List).map((e) => e as Map<String, dynamic>).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Group Summary"),
//       ),
//       body: FutureBuilder<List<Map<String, dynamic>>>(
//         future: _groupDataFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text("No data available"));
//           } else {
//             final groupData = snapshot.data!;
//             return ListView.builder(
//               itemCount: groupData.length,
//               itemBuilder: (context, index) {
//                 final group = groupData[index];
//                 return Card(
//                   margin: const EdgeInsets.all(10),
//                   child: ListTile(
//                     title: Text('Group ID: ${group['group_id']}'),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('Total Amount: \$${group['total_amount']}'),
//                         Text('Transactions: ${group['transaction_count']}'),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }
