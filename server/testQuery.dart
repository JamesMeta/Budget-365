class DataPage extends StatelessWidget {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> fetchReports() async {
    final response = await supabase.from('report').select().execute();
    if (response.error != null) {
      print('Error: ${response.error!.message}');
    } else {
      print('Reports: ${response.data}');
    }
  }

  Future<void> insertReport(Map<String, dynamic> reportData) async {
    final response = await supabase.from('report').insert(reportData).execute();
    if (response.error != null) {
      print('Error: ${response.error!.message}');
    } else {
      print('Inserted report: ${response.data}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            TextButton(
              onPressed: fetchReports,
              child: Text('Fetch Reports'),
            ),
            TextButton(
              onPressed: () async {
                await insertReport({
                  'report_type': 1,
                  'amount': 100.0,
                  'description': 'Lunch',
                  'category': 'Food',
                  'id_group': 1,
                });
              },
              child: Text('Insert Report'),
            ),
          ],
        ),
      ),
    );
  }
}
