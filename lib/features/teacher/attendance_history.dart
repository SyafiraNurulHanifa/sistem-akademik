import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceHistory extends StatefulWidget {
  const AttendanceHistory({super.key});

  @override
  State<AttendanceHistory> createState() => _AttendanceHistoryState();
}

class _AttendanceHistoryState extends State<AttendanceHistory> {
  static const _storageKey = 'attendance_days_v1';

  final Map<String, _Rec> _days = {};
  late DateTime _cursorMonth; // selalu di tanggal 1

  @override
  void initState() {
    super.initState();
    _cursorMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return;
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final map = <String, _Rec>{};
    decoded.forEach((k, v) => map[k] = _Rec.fromMap(v as Map<String, dynamic>));
    setState(() {
      _days
        ..clear()
        ..addAll(map);
    });
  }

  void _prevMonth() {
    setState(() {
      _cursorMonth = DateTime(_cursorMonth.year, _cursorMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _cursorMonth = DateTime(_cursorMonth.year, _cursorMonth.month + 1);
    });
  }

  List<_Rec> get _monthRecs {
    return _days.values
        .where(
          (r) =>
              r.date.year == _cursorMonth.year &&
              r.date.month == _cursorMonth.month,
        )
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // terbaru dulu
  }

  int get _attendedCount => _monthRecs
      .where((r) => (r.inStatus ?? '').toLowerCase() == 'hadir')
      .length;

  int get _absenceCount {
    return _monthRecs.where((r) {
      final s = (r.inStatus ?? '').toLowerCase();
      return s == 'izin' || s == 'sakit' || s == 'alpha';
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final title = "${_monthIndo(_cursorMonth.month)} ${_cursorMonth.year}";

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        title: const Text(
          "Attendance History",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Month switcher + title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _prevMonth,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: _nextMonth,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Summary chips
            Row(
              children: [
                Expanded(
                  child: _miniInfo("Total Attended", "$_attendedCount Day"),
                ),
                const SizedBox(width: 12),
                Expanded(child: _miniInfo("Absence", "$_absenceCount Day")),
              ],
            ),
            const SizedBox(height: 16),

            // List
            Expanded(
              child: _monthRecs.isEmpty
                  ? const Center(child: Text("Belum ada data di bulan ini"))
                  : ListView.builder(
                      itemCount: _monthRecs.length,
                      itemBuilder: (context, i) {
                        final r = _monthRecs[i];
                        return _historyCard(r);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== Widgets =====
  Widget _miniInfo(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _historyCard(_Rec r) {
    const hari = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final wd = hari[(r.date.weekday + 6) % 7];
    final total = _calcTotal(r);
    final chip = _statusForChip(r.inStatus) ?? _statusForChip(r.outStatus);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date box
          Container(
            width: 55,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${r.date.day}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  wd,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Detail
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _timeCol(r.inTime ?? "—", "Check In"),
                    _divider(),
                    _timeCol(r.outTime ?? "Not Yet", "Check Out"),
                    _divider(),
                    _timeCol(total ?? "—", "Total Hours"),
                  ],
                ),
                const SizedBox(height: 8),

                // status + lokasi di tengah bawah
                Column(
                  children: [
                    if (chip != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          chip,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(height: 6),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            r.location ?? "—",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _timeCol(String time, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          time,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  static Widget _divider() => Container(
    height: 30,
    width: 1,
    color: Colors.grey.shade300,
    margin: const EdgeInsets.symmetric(horizontal: 8),
  );

  String? _calcTotal(_Rec r) {
    if (r.inTime == null || r.outTime == null) return null;
    final key = r.date.toIso8601String().split('T').first;
    final inDt = DateTime.tryParse("$key ${r.inTime!}");
    final outDt = DateTime.tryParse("$key ${r.outTime!}");
    if (inDt == null || outDt == null) return null;
    final diff = outDt.difference(inDt);
    final hh = diff.inHours.toString().padLeft(2, '0');
    final mm = (diff.inMinutes % 60).toString().padLeft(2, '0');
    return "$hh:$mm";
  }

  static String _monthIndo(int m) {
    const bulan = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return bulan[m - 1];
  }

  // Tampilkan chip hanya jika status ada dan ≠ "Hadir"
  String? _statusForChip(String? s) {
    if (s == null) return null;
    final t = s.trim();
    if (t.isEmpty) return null;
    if (t.toLowerCase() == 'hadir') return null;
    return t;
  }
}

/// Model untuk History (sesuai struktur di SharedPreferences)
class _Rec {
  _Rec({
    required this.date,
    this.inTime,
    this.outTime,
    this.inStatus,
    this.outStatus,
    this.location,
  });

  DateTime date;
  String? inTime;
  String? outTime;
  String? inStatus;
  String? outStatus;
  String? location;

  Map<String, dynamic> toMap() => {
    'date': date.toIso8601String().split('T').first,
    'inTime': inTime,
    'outTime': outTime,
    'inStatus': inStatus,
    'outStatus': outStatus,
    'location': location,
  };

  factory _Rec.fromMap(Map<String, dynamic> m) {
    final d =
        (m['date'] as String?) ??
        DateTime.now().toIso8601String().split('T').first;
    return _Rec(
      date: DateTime.parse(d),
      inTime: m['inTime'] as String?,
      outTime: m['outTime'] as String?,
      inStatus: m['inStatus'] as String?,
      outStatus: m['outStatus'] as String?,
      location: m['location'] as String?,
    );
  }
}
