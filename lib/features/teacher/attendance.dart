import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'checkin_form.dart';
import 'checkout_form.dart';
import 'attendance_history.dart';

class TeacherAttendance extends StatefulWidget {
  const TeacherAttendance({super.key});

  @override
  State<TeacherAttendance> createState() => _TeacherAttendanceState();
}

class _TeacherAttendanceState extends State<TeacherAttendance> {
  final Map<String, DailyAttendance> _days = {};
  static const String _checkInLimit = "07:00";
  static const String _checkOutLimit = "17:00";
  static const _storageKey = 'attendance_days_v1';

  String get _todayKey => DateTime.now().toIso8601String().split('T').first;

  @override
  void initState() {
    super.initState();
    _loadFromDisk();
  }

  DailyAttendance _todayRec() {
    return _days[_todayKey] ??= DailyAttendance(date: DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final today = _todayRec();
    final headerDate = _formatFullIndo(DateTime.now());

    final isNonHadir =
        (today.inStatus ?? '').isNotEmpty &&
        (today.inStatus ?? '').toLowerCase() != 'hadir';

    // ====== Check In ======
    final bool hasIn = today.inTime != null;
    final String inSub = hasIn
        ? (_isEarlyIn(today.inTime!) ? "Early" : "Late")
        : "Not Yet";
    final Color inColor = hasIn
        ? (_isEarlyIn(today.inTime!) ? Colors.green : Colors.red)
        : Colors.grey;
    final String inTimeText = hasIn ? today.inTime! : _checkInLimit;
    final bool inMuted = !hasIn;

    // ====== Check Out ======
    String outSub;
    Color outColor;
    String outTimeText;
    bool outMuted;

    if (isNonHadir) {
      outSub = "N/A";
      outColor = Colors.grey;
      outTimeText = "—";
      outMuted = true;
    } else {
      final bool hasOut = today.outTime != null;
      outSub = hasOut
          ? (_isEarlyOut(today.outTime!) ? "Early" : "Late")
          : "Not Yet";
      outColor = hasOut
          ? (_isEarlyOut(today.outTime!) ? Colors.red : Colors.green)
          : Colors.grey;
      outTimeText = hasOut ? today.outTime! : _checkOutLimit;
      outMuted = !hasOut;
    }

    // ====== Agregasi bulan ======
    final now = DateTime.now();
    final monthRecs = _days.values
        .where((r) => r.date.year == now.year && r.date.month == now.month)
        .toList();
    final int totalAttended = monthRecs
        .where((r) => (r.inStatus ?? '').toLowerCase() == 'hadir')
        .length;
    final int totalAbsence = monthRecs.where((r) {
      final s = (r.inStatus ?? '').toLowerCase();
      return s == 'izin' || s == 'sakit' || s == 'alpha';
    }).length;

    final recent = _sortedMonthRecs.take(4).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        title: const Text(
          "ATTENDANCE",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: const Icon(Icons.calendar_today, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  headerDate,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        today.location ?? "—",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Check In / Out
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CheckInForm()),
                      );
                      if (result is Map) _applyResult(result);
                    },
                    child: _infoCard(
                      title: "Check In",
                      subtitle: inSub,
                      time: inTimeText,
                      subtitleColor: inColor,
                      status: _statusForChip(today.inStatus),
                      muted: inMuted,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      if (isNonHadir) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Status non-hadir tidak perlu Check Out.",
                            ),
                          ),
                        );
                        return;
                      }
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CheckOutForm()),
                      );
                      if (result is Map) _applyResult(result);
                    },
                    child: _infoCard(
                      title: "Check Out",
                      subtitle: outSub,
                      time: outTimeText,
                      subtitleColor: outColor,
                      status: _statusForChip(today.outStatus),
                      muted: outMuted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Absence & Attended
            Row(
              children: [
                Expanded(
                  child: _infoCard(
                    title: "Absence",
                    subtitle: _monthIndo(now.month),
                    time: "$totalAbsence Day",
                    subtitleColor: Colors.grey,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _infoCard(
                    title: "Total Attended",
                    subtitle: _monthIndo(now.month),
                    time: "$totalAttended Day",
                    subtitleColor: Colors.grey,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // History
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Attendance History",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AttendanceHistory(),
                    ),
                  ),
                  child: const Text(
                    "View More",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recent.length,
              itemBuilder: (context, index) {
                final rec = recent[index];
                return _attendanceCard(
                  day: rec.date,
                  inTime: rec.inTime,
                  outTime: rec.outTime,
                  total: _calcTotal(rec),
                  location: rec.location,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _applyResult(Map data) {
    final type = (data['type'] as String?) ?? '';
    final dateKey = (data['date'] as String?) ?? _todayKey;
    final time = data['time'] as String?;
    final status = data['status'] as String?;
    final location = data['location'] as String?;
    final rec =
        _days[dateKey] ?? DailyAttendance(date: DateTime.parse(dateKey));

    if (type == 'in') {
      rec.inTime = time;
      rec.inStatus = status;
      if ((status ?? '').toLowerCase() != 'hadir' &&
          (status ?? '').isNotEmpty) {
        rec.outTime = null;
        rec.outStatus = null;
      }
    } else if (type == 'out') {
      rec.outTime = time;
      rec.outStatus = status;
    }
    if (location != null && location.isNotEmpty) rec.location = location;

    setState(() => _days[dateKey] = rec);
    _saveToDisk();
  }

  Future<void> _saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonMap = _days.map((k, v) => MapEntry(k, v.toMap()));
    await prefs.setString(_storageKey, jsonEncode(jsonMap));
  }

  Future<void> _loadFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return;
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final loaded = <String, DailyAttendance>{};
    decoded.forEach(
      (k, v) => loaded[k] = DailyAttendance.fromMap(v as Map<String, dynamic>),
    );
    setState(() {
      _days
        ..clear()
        ..addAll(loaded);
    });
  }

  List<DailyAttendance> get _sortedMonthRecs {
    final now = DateTime.now();
    final list = _days.values
        .where((r) => r.date.year == now.year && r.date.month == now.month)
        .toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  static String? _calcTotal(DailyAttendance rec) {
    if (rec.inTime == null || rec.outTime == null) return null;
    final dateKey = rec.date.toIso8601String().split('T').first;
    final inDt = DateTime.tryParse("$dateKey ${rec.inTime!}");
    final outDt = DateTime.tryParse("$dateKey ${rec.outTime!}");
    if (inDt == null || outDt == null) return null;
    final diff = outDt.difference(inDt);
    final hh = diff.inHours.toString().padLeft(2, '0');
    final mm = (diff.inMinutes % 60).toString().padLeft(2, '0');
    return "$hh:$mm";
  }

  static int _toMinutes(String hhmm) {
    final p = hhmm.split(':');
    final h = int.tryParse(p[0]) ?? 0;
    final m = int.tryParse(p[1]) ?? 0;
    return h * 60 + m;
  }

  bool _isEarlyIn(String time) => _toMinutes(time) <= _toMinutes(_checkInLimit);
  bool _isEarlyOut(String time) =>
      _toMinutes(time) < _toMinutes(_checkOutLimit);

  static String _formatFullIndo(DateTime d) {
    const hari = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
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
    final h = hari[d.weekday - 1];
    return "$h, ${d.day} ${bulan[d.month - 1]} ${d.year}";
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

  String? _statusForChip(String? s) {
    if (s == null) return null;
    final t = s.trim();
    if (t.isEmpty) return null;
    if (t.toLowerCase() == 'hadir') return null;
    return t;
  }

  static Widget _infoCard({
    required String title,
    required String subtitle,
    required String time,
    required Color subtitleColor,
    String? status,
    bool muted = false,
    double fontSize = 24,
  }) {
    final hasStatus = (status != null && status.trim().isNotEmpty);
    final bgColor = muted ? const Color(0xFFF0F2F5) : Colors.white;
    final textColor = muted ? Colors.grey : Colors.black87;
    final subColor = muted ? Colors.grey : subtitleColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: muted
            ? []
            : [
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              if (hasStatus)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: muted ? Colors.grey.shade200 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
            ],
          ),
          Text(subtitle, style: TextStyle(fontSize: 12, color: subColor)),
          const SizedBox(height: 8),
          Text(
            time,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: muted ? Colors.grey : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _attendanceCard({
    required DateTime day,
    String? inTime,
    String? outTime,
    String? total,
    String? location,
  }) {
    const hari = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final weekday = hari[(day.weekday + 6) % 7];
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
                  "${day.day}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  weekday,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _timeColumn(inTime ?? "—", "Check In"),
                    _divider(),
                    _timeColumn(outTime ?? "Not Yet", "Check Out"),
                    _divider(),
                    _timeColumn(total ?? "—", "Total Hours"),
                  ],
                ),
                const SizedBox(height: 8),
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
                        location ?? "—",
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
          ),
        ],
      ),
    );
  }

  static Widget _timeColumn(String time, String label) {
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
}

class DailyAttendance {
  DailyAttendance({
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

  factory DailyAttendance.fromMap(Map<String, dynamic> m) {
    final d =
        (m['date'] as String?) ??
        DateTime.now().toIso8601String().split('T').first;
    return DailyAttendance(
      date: DateTime.parse(d),
      inTime: m['inTime'] as String?,
      outTime: m['outTime'] as String?,
      inStatus: m['inStatus'] as String?,
      outStatus: m['outStatus'] as String?,
      location: m['location'] as String?,
    );
  }
}
