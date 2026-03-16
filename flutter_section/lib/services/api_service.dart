import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // غير الـ IP ده لـ IP الجهاز بتاعك
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // ==================== Token Management ====================
  static Future<void> saveTokens(String access, String refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', access);
    await prefs.setString('refresh_token', refresh);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  // ==================== Headers ====================
  static Future<Map<String, String>> _authHeaders() async {
    final token = await getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  // ==================== LOGIN ====================
  static Future<ApiResult> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login/'),
        headers: _headers,
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResult.success(data);
      }
      return ApiResult.error(data['error'] ?? 'Login failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  // ==================== VERIFY OTP LOGIN ====================
  static Future<ApiResult> verifyOtpLogin({
    required String username,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp-login/'),
        headers: _headers,
        body: jsonEncode({
          'username': username,
          'otp': otp,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await saveTokens(data['access'], data['refresh']);
        return ApiResult.success(data);
      }
      return ApiResult.error(data['error'] ?? 'OTP verification failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  // ==================== REGISTER ====================
  static Future<ApiResult> register({
    required String username,
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register/'),
        headers: _headers,
        body: jsonEncode({
          'username': username,
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'password': password,
          'role': role.toLowerCase(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResult.success(data);
      }
      return ApiResult.error(data['error'] ?? 'Registration failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  // ==================== VERIFY OTP REGISTER ====================
  static Future<ApiResult> verifyOtpRegister({
    required String userId,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp-register/$userId/'),
        headers: _headers,
        body: jsonEncode({'otp': otp}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await saveTokens(data['access'], data['refresh']);
        return ApiResult.success(data);
      }
      return ApiResult.error(data['error'] ?? 'OTP verification failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  // ==================== FORGET PASSWORD ====================
  static Future<ApiResult> forgetPassword({required String email}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forget-password/'),
        headers: _headers,
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResult.success(data);
      }
      return ApiResult.error(data['error'] ?? 'Email not found');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  // ==================== VERIFY OTP FORGET PASSWORD ====================
  static Future<ApiResult> verifyOtpForgetPassword({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp-forget-password/'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResult.success(data);
      }
      return ApiResult.error(data['error'] ?? 'OTP verification failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  // ==================== RESET PASSWORD ====================
  static Future<ApiResult> resetPassword({
    required String email,
    required String password,
    required String confirm,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password/'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
          'confirm': confirm,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResult.success(data);
      }
      return ApiResult.error(data['error'] ?? 'Reset failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  static Future<ApiResult> resendOtp({
    required String source,
    String? username,
    String? pendingUserId,
    String? email,
  }) async {
    try {
      final body = {'source': source};
      if (username != null) body['username'] = username;
      if (pendingUserId != null) body['pending_user_id'] = pendingUserId;
      if (email != null) body['email'] = email;
      final response = await http.post(
        Uri.parse('$baseUrl/auth/resend-otp/'),
        headers: _headers,
        body: jsonEncode(body),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return ApiResult.success(data);
      return ApiResult.error(data['error'] ?? 'Resend failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  // ==================== PATIENT REGISTER ====================
  static Future<ApiResult> patientRegister({
    required String gender,
    required String phoneNumber,
    required String address,
    required String governorate,
    required File profilePic,
    required File nationalIdFront,
    required File nationalIdBack,
  }) async {
    try {
      final token = await getAccessToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/auth/patient/'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['gender'] = gender;
      request.fields['phone_number'] = phoneNumber;
      request.fields['address'] = address;
      request.fields['governorate'] = governorate;

      request.files.add(await http.MultipartFile.fromPath('profile_pic', profilePic.path));
      request.files.add(await http.MultipartFile.fromPath('national_id_pic_front', nationalIdFront.path));
      request.files.add(await http.MultipartFile.fromPath('national_id_pic_back', nationalIdBack.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResult.success(data);
      }
      return ApiResult.error(data['error'] ?? 'Patient registration failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  static Future<ApiResult> doctorRegister({
    required String gender, required String phoneNumber,
    required String address, required String governorate,
    required File profilePic, required File nationalIdFront,
    required File nationalIdBack, required String dateOfBirth,
    required String price, required String specification,
    required String university, required File syndicateCard,
    required File practicePerm, required File graduationCert,
    required File excellenceCert,
  }) async {
    try {
      final token = await getAccessToken();
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/auth/doctor/'));
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['gender'] = gender;
      request.fields['phone_number'] = phoneNumber;
      request.fields['address'] = address;
      request.fields['governorate'] = governorate;
      request.fields['date_of_birth'] = dateOfBirth;
      request.fields['price'] = price;
      request.fields['specification'] = specification;
      request.fields['university'] = university;
      request.files.add(await http.MultipartFile.fromPath('profile_pic', profilePic.path));
      request.files.add(await http.MultipartFile.fromPath('national_id_pic_front', nationalIdFront.path));
      request.files.add(await http.MultipartFile.fromPath('national_id_pic_back', nationalIdBack.path));
      request.files.add(await http.MultipartFile.fromPath('syndicate_card', syndicateCard.path));
      request.files.add(await http.MultipartFile.fromPath('practice_permit', practicePerm.path));
      request.files.add(await http.MultipartFile.fromPath('graduation_certificate', graduationCert.path));
      request.files.add(await http.MultipartFile.fromPath('excellence_certificate', excellenceCert.path));
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return ApiResult.success(data);
      return ApiResult.error(data['error'] ?? 'Doctor registration failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  static Future<ApiResult> nurseRegister({
    required String gender, required String phoneNumber,
    required String address, required String governorate,
    required File profilePic, required File nationalIdFront,
    required File nationalIdBack, required String dateOfBirth,
    required File excellenceCert, required File syndicateCard,
    required File practicePerm, required File graduationCert,
  }) async {
    try {
      final token = await getAccessToken();
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/auth/nurse/'));
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['gender'] = gender;
      request.fields['phone_number'] = phoneNumber;
      request.fields['address'] = address;
      request.fields['governorate'] = governorate;
      request.fields['date_of_birth'] = dateOfBirth;
      request.files.add(await http.MultipartFile.fromPath('profile_pic', profilePic.path));
      request.files.add(await http.MultipartFile.fromPath('national_id_pic_front', nationalIdFront.path));
      request.files.add(await http.MultipartFile.fromPath('national_id_pic_back', nationalIdBack.path));
      request.files.add(await http.MultipartFile.fromPath('excellence_certificate', excellenceCert.path));
      request.files.add(await http.MultipartFile.fromPath('syndicate_card', syndicateCard.path));
      request.files.add(await http.MultipartFile.fromPath('practice_permit', practicePerm.path));
      request.files.add(await http.MultipartFile.fromPath('graduation_certificate', graduationCert.path));
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return ApiResult.success(data);
      return ApiResult.error(data['error'] ?? 'Nurse registration failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }
}

// ==================== ApiResult Helper ====================
class ApiResult {
  final bool success;
  final dynamic data;
  final String? error;

  ApiResult._({required this.success, this.data, this.error});

  factory ApiResult.success(dynamic data) =>
      ApiResult._(success: true, data: data);

  factory ApiResult.error(String error) =>
      ApiResult._(success: false, error: error);
}