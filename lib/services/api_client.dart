import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String baseUrl = "http://10.0.2.2:8000/api";
  // Emulator Android => 10.0.2.2 ; device real => IP Wi-Fi laptop kamu
  // VPS => ganti jadi "https://vps.hoaks.my.id/api"

  static const Duration _timeout = Duration(seconds: 20);

  // -------------------------
  // Helpers
  // -------------------------
  static Map<String, dynamic> _safeJson(String body) {
    try {
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic>
          ? decoded
          : {"status": "error", "message": "Unexpected response"};
    } catch (_) {
      // biar bisa lihat error asli dari server (HTML/error text)
      return {"status": "error", "message": "Invalid JSON", "raw": body};
    }
  }

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // -------------------------
  // Public methods
  // -------------------------

  /// POST tanpa token (login / register)
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final res = await http
        .post(
          url,
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
          body: jsonEncode(body),
        )
        .timeout(_timeout);

    if ((res.statusCode == 200 || res.statusCode == 204) && res.body.isEmpty) {
      return {"status": "success"};
    }
    return _safeJson(res.body);
  }

  /// GET dengan token
  static Future<Map<String, dynamic>> getAuth(String endpoint) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/$endpoint');
    final res = await http
        .get(
          url,
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            if (token != null) "Authorization": "Bearer $token",
          },
        )
        .timeout(_timeout);

    if ((res.statusCode == 200 || res.statusCode == 204) && res.body.isEmpty) {
      return {"status": "success"};
    }
    return _safeJson(res.body);
  }

  /// POST dengan token (JSON)
  static Future<Map<String, dynamic>> postAuth(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/$endpoint');
    final res = await http
        .post(
          url,
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            if (token != null) "Authorization": "Bearer $token",
          },
          body: jsonEncode(body),
        )
        .timeout(_timeout);

    if ((res.statusCode == 200 || res.statusCode == 204) && res.body.isEmpty) {
      return {"status": "success"};
    }
    return _safeJson(res.body);
  }

  /// PUT dengan token (JSON)
  static Future<Map<String, dynamic>> putAuth(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/$endpoint');
    final res = await http
        .put(
          url,
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            if (token != null) "Authorization": "Bearer $token",
          },
          body: jsonEncode(body),
        )
        .timeout(_timeout);

    if ((res.statusCode == 200 || res.statusCode == 204) && res.body.isEmpty) {
      return {"status": "success"};
    }
    return _safeJson(res.body);
  }

  /// PATCH dengan token (JSON)
  static Future<Map<String, dynamic>> patchAuth(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/$endpoint');
    final res = await http
        .patch(
          url,
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            if (token != null) "Authorization": "Bearer $token",
          },
          body: jsonEncode(body),
        )
        .timeout(_timeout);

    if ((res.statusCode == 200 || res.statusCode == 204) && res.body.isEmpty) {
      return {"status": "success"};
    }
    return _safeJson(res.body);
  }

  /// Multipart dengan token (untuk upload foto, dll)
  static Future<Map<String, dynamic>> multipartAuth(
    String endpoint, {
    Map<String, String>? fields,
    String? fileField,
    File? file,
  }) async {
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl/$endpoint');

    final req = http.MultipartRequest('POST', uri);
    req.headers['Accept'] = 'application/json';
    if (token != null) req.headers['Authorization'] = 'Bearer $token';

    // form fields
    if (fields != null && fields.isNotEmpty) {
      req.fields.addAll(fields);
    }

    // file (opsional)
    if (fileField != null && file != null) {
      req.files.add(await http.MultipartFile.fromPath(fileField, file.path));
    }

    final streamed = await req.send().timeout(_timeout);
    final body = await streamed.stream.bytesToString();

    if ((streamed.statusCode == 200 || streamed.statusCode == 204) &&
        body.isEmpty) {
      return {"status": "success"};
    }
    return _safeJson(body);
  }
}
