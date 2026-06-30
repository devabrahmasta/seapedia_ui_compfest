import 'package:supabase_flutter/supabase_flutter.dart';

class DriverEarningsSummary {
  final double totalEarnings;
  final int completedJobCount;
  final double averagePerJob;

  const DriverEarningsSummary({
    required this.totalEarnings,
    required this.completedJobCount,
    required this.averagePerJob,
  });
}

class DriverEarningsRepository {
  DriverEarningsRepository(this._client);

  final SupabaseClient _client;

  Future<DriverEarningsSummary> getEarningsSummary(String driverId) async {
    final data = await _client
        .from('driver_earnings')
        .select('amount')
        .eq('driver_id', driverId);

    final rows = data as List;
    double totalEarnings = 0;
    for (final row in rows) {
      totalEarnings += (row['amount'] as num).toDouble();
    }

    final completedJobCount = rows.length;
    final averagePerJob = completedJobCount > 0
        ? totalEarnings / completedJobCount
        : 0.0;

    return DriverEarningsSummary(
      totalEarnings: totalEarnings,
      completedJobCount: completedJobCount,
      averagePerJob: averagePerJob,
    );
  }
}
