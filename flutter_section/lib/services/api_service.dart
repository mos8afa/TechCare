import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  static Future<void> saveTokens(String access, String refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', access);
    await prefs.setString('refresh_token', refresh);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  static Future<bool> refreshAccessToken() async {
    try {
      final refresh = await getRefreshToken();
      if (refresh == null) return false;
      final response = await http.post(
        Uri.parse('$baseUrl/token/refresh/'),
        headers: _headers,
        body: jsonEncode({'refresh': refresh}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', data['access']);
        if (data['refresh'] != null) {
          await prefs.setString('refresh_token', data['refresh']);
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<http.Response> _authGet(String url) async {
    final token = await getAccessToken();
    var response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 401) {
      final refreshed = await refreshAccessToken();
      if (refreshed) {
        final newToken = await getAccessToken();
        response = await http.get(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $newToken',
          },
        );
      }
    }
    return response;
  }

  static Future<http.Response> _authPost(
    String url,
    Map<String, dynamic> body,
  ) async {
    final token = await getAccessToken();
    var response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    if (response.statusCode == 401) {
      final refreshed = await refreshAccessToken();
      if (refreshed) {
        final newToken = await getAccessToken();
        response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $newToken',
          },
          body: jsonEncode(body),
        );
      }
    }
    return response;
  }

  static Future<http.Response> _authPut(
    String url,
    Map<String, dynamic> body,
  ) async {
    final token = await getAccessToken();
    var response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    if (response.statusCode == 401) {
      final refreshed = await refreshAccessToken();
      if (refreshed) {
        final newToken = await getAccessToken();
        response = await http.put(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $newToken',
          },
          body: jsonEncode(body),
        );
      }
    }
    return response;
  }

  static Future<http.Response> _authDelete(String url) async {
    final token = await getAccessToken();
    var response = await http.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 401) {
      final refreshed = await refreshAccessToken();
      if (refreshed) {
        final newToken = await getAccessToken();
        response = await http.delete(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $newToken',
          },
        );
      }
    }
    return response;
  }

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static String buildMediaUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return 'http://10.0.2.2:8000$path';
  }

  // ==================== AUTH ====================

  static Future<ApiResult> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login/'),
        headers: _headers,
        body: jsonEncode({'username': username, 'password': password}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return ApiResult.success(data);
      return ApiResult.error(data['error'] ?? 'Login failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  static Future<ApiResult> verifyOtpLogin({
    required String username,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp-login/'),
        headers: _headers,
        body: jsonEncode({'username': username, 'otp': otp}),
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
      if (response.statusCode == 200) return ApiResult.success(data);
      return ApiResult.error(data['error'] ?? 'Registration failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

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

  static Future<ApiResult> forgetPassword({required String email}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forget-password/'),
        headers: _headers,
        body: jsonEncode({'email': email}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return ApiResult.success(data);
      return ApiResult.error(data['error'] ?? 'Email not found');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  static Future<ApiResult> verifyOtpForgetPassword({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp-forget-password/'),
        headers: _headers,
        body: jsonEncode({'email': email, 'otp': otp}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return ApiResult.success(data);
      return ApiResult.error(data['error'] ?? 'OTP verification failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

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
      if (response.statusCode == 200) return ApiResult.success(data);
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

  // ==================== REGISTRATION (ROLE SPECIFIC) ====================

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
      request.headers['Accept'] = 'application/json';
      request.fields['gender'] = gender;
      request.fields['phone_number'] = phoneNumber;
      request.fields['address'] = address;
      request.fields['governorate'] = governorate;
      request.files.add(
        await http.MultipartFile.fromPath('profile_pic', profilePic.path),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'national_id_pic_front',
          nationalIdFront.path,
        ),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'national_id_pic_back',
          nationalIdBack.path,
        ),
      );
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return ApiResult.success(data);
      return ApiResult.error(data['error'] ?? 'Patient registration failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  static Future<ApiResult> doctorRegister({
    required String gender,
    required String phoneNumber,
    required String address,
    required String governorate,
    required File profilePic,
    required File nationalIdFront,
    required File nationalIdBack,
    required String dateOfBirth,
    required String price,
    required String specification,
    required String university,
    required File syndicateCard,
    required File practicePerm,
    required File graduationCert,
    required File excellenceCert,
  }) async {
    try {
      final token = await getAccessToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/auth/doctor/'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      request.fields['gender'] = gender;
      request.fields['phone_number'] = phoneNumber;
      request.fields['address'] = address;
      request.fields['governorate'] = governorate;
      request.fields['date_of_birth'] = dateOfBirth;
      request.fields['price'] = price;
      request.fields['specification'] = specification;
      request.fields['university'] = university;
      request.files.add(
        await http.MultipartFile.fromPath('profile_pic', profilePic.path),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'national_id_pic_front',
          nationalIdFront.path,
        ),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'national_id_pic_back',
          nationalIdBack.path,
        ),
      );
      request.files.add(
        await http.MultipartFile.fromPath('syndicate_card', syndicateCard.path),
      );
      request.files.add(
        await http.MultipartFile.fromPath('practice_permit', practicePerm.path),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'graduation_certificate',
          graduationCert.path,
        ),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'excellence_certificate',
          excellenceCert.path,
        ),
      );
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
    required String gender,
    required String phoneNumber,
    required String address,
    required String governorate,
    required File profilePic,
    required File nationalIdFront,
    required File nationalIdBack,
    required String dateOfBirth,
    required File excellenceCert,
    required File syndicateCard,
    required File practicePerm,
    required File graduationCert,
  }) async {
    try {
      final token = await getAccessToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/auth/nurse/'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      request.fields['gender'] = gender;
      request.fields['phone_number'] = phoneNumber;
      request.fields['address'] = address;
      request.fields['governorate'] = governorate;
      request.fields['date_of_birth'] = dateOfBirth;
      request.files.add(
        await http.MultipartFile.fromPath('profile_pic', profilePic.path),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'national_id_pic_front',
          nationalIdFront.path,
        ),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'national_id_pic_back',
          nationalIdBack.path,
        ),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'excellence_certificate',
          excellenceCert.path,
        ),
      );
      request.files.add(
        await http.MultipartFile.fromPath('syndicate_card', syndicateCard.path),
      );
      request.files.add(
        await http.MultipartFile.fromPath('practice_permit', practicePerm.path),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'graduation_certificate',
          graduationCert.path,
        ),
      );
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return ApiResult.success(data);
      return ApiResult.error(data['error'] ?? 'Nurse registration failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  static Future<ApiResult> donorRegister({
    required String bloodType,
    required String phoneNumber,
    required String address,
    required String governorate,
    required String dateOfBirth,
    required String? lastDonationDate,
    required File profilePic,
    required File nationalIdFront,
    required File nationalIdBack,
  }) async {
    try {
      final token = await getAccessToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/auth/donor/'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      request.fields['blood_type'] = bloodType;
      request.fields['phone_number'] = phoneNumber;
      request.fields['address'] = address;
      request.fields['governorate'] = governorate;
      request.fields['date_of_birth'] = dateOfBirth;
      if (lastDonationDate != null && lastDonationDate.isNotEmpty) {
        request.fields['last_donation_date'] = lastDonationDate;
      }
      request.files.add(
        await http.MultipartFile.fromPath('profile_pic', profilePic.path),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'national_id_pic_front',
          nationalIdFront.path,
        ),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'national_id_pic_back',
          nationalIdBack.path,
        ),
      );
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return ApiResult.success(data);
      return ApiResult.error(data['error'] ?? 'Donor registration failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  static Future<ApiResult> pharmacistRegister({
    required String gender,
    required String phoneNumber,
    required String dateOfBirth,
    required File profilePic,
    required File nationalIdFront,
    required File nationalIdBack,
    required String pharmacyName,
    required String pharmacyAddress,
    required String governorate,
    required String university,
    required File syndicateCard,
    required File practicePerm,
    required File graduationCert,
  }) async {
    try {
      final token = await getAccessToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/auth/pharmacist/'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      request.fields['gender'] = gender;
      request.fields['phone_number'] = phoneNumber;
      request.fields['date_of_birth'] = dateOfBirth;
      request.fields['pharmacy_name'] = pharmacyName;
      request.fields['pharmacy_address'] = pharmacyAddress;
      request.fields['governorate'] = governorate;
      request.fields['university'] = university;
      request.files.add(
        await http.MultipartFile.fromPath('profile_pic', profilePic.path),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'national_id_pic_front',
          nationalIdFront.path,
        ),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'national_id_pic_back',
          nationalIdBack.path,
        ),
      );
      request.files.add(
        await http.MultipartFile.fromPath('syndicate_card', syndicateCard.path),
      );
      request.files.add(
        await http.MultipartFile.fromPath('practice_permit', practicePerm.path),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'graduation_certificate',
          graduationCert.path,
        ),
      );
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return ApiResult.success(data);
      return ApiResult.error(data['error'] ?? 'Pharmacist registration failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  // ==================== GET USER ROLE ====================
  static Future<ApiResult> getUserRole() async {
    try {
      final response = await _authGet('$baseUrl/auth/user-role/');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return ApiResult.success(data);
      if (response.statusCode == 401) return ApiResult.error('Session expired');
      return ApiResult.error(data['error'] ?? 'Failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  // ==================== DOCTOR DASHBOARD ====================
  static Future<ApiResult> getDoctorDashboard({String? day}) async {
    try {
      final uri = day != null
          ? '$baseUrl/dashboard/doctor/?day=$day'
          : '$baseUrl/dashboard/doctor/';

      final response = await _authGet(uri);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) return ApiResult.success(data);
      if (response.statusCode == 401) return ApiResult.error('Session expired');

      return ApiResult.error(data['error'] ?? 'Failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  // ==================== DOCTOR EDIT PROFILE GET ====================
  static Future<ApiResult> getDoctorProfile() async {
    try {
      final response = await _authGet('$baseUrl/doctor/profile/edit/');
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) return ApiResult.success(data);
      if (response.statusCode == 401) return ApiResult.error('Session expired');

      return ApiResult.error(data['error'] ?? 'Failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  // ==================== DOCTOR EDIT PROFILE POST ====================
  static Future<ApiResult> updateDoctorProfile({
    required String username,
    required String phoneNumber,
    required String address,
    required String brief,
    required String price,
    required String governorate,
    File? profilePic,
  }) async {
    try {
      final token = await getAccessToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/doctor/profile/edit/'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      request.fields['username'] = username;
      request.fields['phone_number'] = phoneNumber;
      request.fields['address'] = address;
      request.fields['brief'] = brief;
      request.fields['price'] = price;
      request.fields['governorate'] = governorate;
      if (profilePic != null) {
        request.files.add(
          await http.MultipartFile.fromPath('profile_pic', profilePic.path),
        );
      }
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return ApiResult.success(data);
      return ApiResult.error(data['error'] ?? 'Failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  // ==================== TIME SLOTS GET ====================
  static Future<ApiResult> getTimeSlots({String? day}) async {
    try {
      final uri = day != null ? '$baseUrl/slots/?day=$day' : '$baseUrl/slots/';
      final response = await _authGet(uri);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return ApiResult.success(data);
      if (response.statusCode == 401) return ApiResult.error('Session expired');
      return ApiResult.error(data['error'] ?? 'Failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  // ==================== TIME SLOTS ADD ====================
  static Future<ApiResult> addTimeSlot({
    required String day,
    required List<String> times,
  }) async {
    try {
      final response = await _authPost('$baseUrl/slots/save/', {
        'day': day,
        'times': times,
      });
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return ApiResult.success(data);
      if (response.statusCode == 401) return ApiResult.error('Session expired');
      return ApiResult.error(data['error'] ?? 'Failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  // ==================== TIME SLOTS DELETE ====================
  static Future<ApiResult> deleteTimeSlot(int slotId) async {
    try {
      final response = await _authDelete('$baseUrl/slots/$slotId/delete/');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return ApiResult.success(data);
      if (response.statusCode == 401) return ApiResult.error('Session expired');
      return ApiResult.error(data['error'] ?? 'Failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  // ==================== DOCTOR REQUESTS ====================
  static Future<ApiResult> getDoctorRequests(String type) async {
    try {
      final response = await _authGet('$baseUrl/doctor/requests/$type/');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return ApiResult.success(data);
      if (response.statusCode == 401) return ApiResult.error('Session expired');
      return ApiResult.error(data['error'] ?? 'Failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  // ==================== DOCTOR REQUEST ACTION ====================
  static Future<ApiResult> requestActionDoctor(
    int requestId,
    String action, {
    String? time,
  }) async {
    try {
      final body = {'action': action};
      if (time != null) {
        // Doctor endpoint expects 'new_time' when rescheduling
        if (action == 'reschedule') {
          body['new_time'] = time;
        } else {
          body['selected_time'] = time;
        }
      }
      final response = await _authPost(
        '$baseUrl/requests/action/$requestId/',
        body,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return ApiResult.success(data);
      if (response.statusCode == 401) return ApiResult.error('Session expired');
      return ApiResult.error(data['error'] ?? 'Failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  // ==================== DOCTOR DONE ACTION ====================
  static Future<ApiResult> markDoneDoctor(int requestId) async {
    try {
      final response = await _authPost(
        '$baseUrl/requests/done/doctor/$requestId/',
        {},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return ApiResult.success(data);
      if (response.statusCode == 401) return ApiResult.error('Session expired');
      return ApiResult.error(data['error'] ?? 'Failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  // ==================== NURSE DASHBOARD ====================
  static Future<ApiResult> getNurseDashboard({String? day}) async {
    try {
      final uri = day != null
          ? '$baseUrl/dashboard/nurse/?day=$day'
          : '$baseUrl/dashboard/nurse/';

      final response = await _authGet(uri);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) return ApiResult.success(data);
      if (response.statusCode == 401) return ApiResult.error('Session expired');

      return ApiResult.error(data['error'] ?? 'Failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  // ==================== NURSE PROFILE (GET & POST) ====================
  /// Fetches nurse profile data for editing.
  /// Endpoint: GET /nurse/profile/edit/
  static Future<ApiResult> getNurseProfile() async {
    try {
      final response = await _authGet('$baseUrl/nurse/profile/edit/');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return ApiResult.success(data);
      if (response.statusCode == 401) return ApiResult.error('Session expired');
      return ApiResult.error(data['error'] ?? 'Failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  /// Updates nurse profile.
  /// Endpoint: POST /nurse/profile/edit/
  static Future<ApiResult> updateNurseProfile({
    required String username,
    required String phoneNumber,
    required String address,
    required String brief,
    required String governorate,
    File? profilePic,
  }) async {
    try {
      final token = await getAccessToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/nurse/profile/edit/'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      request.fields['username'] = username;
      request.fields['phone_number'] = phoneNumber;
      request.fields['address'] = address;
      request.fields['brief'] = brief;
      request.fields['governorate'] = governorate;
      if (profilePic != null) {
        request.files.add(
          await http.MultipartFile.fromPath('profile_pic', profilePic.path),
        );
      }
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return ApiResult.success(data);
      return ApiResult.error(data['error'] ?? 'Failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  // ==================== NURSE REQUESTS ====================
  static Future<ApiResult> getNurseRequests(String type) async {
    try {
      final response = await _authGet('$baseUrl/nurse/requests/$type/');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return ApiResult.success(data);
      if (response.statusCode == 401) return ApiResult.error('Session expired');
      return ApiResult.error(data['error'] ?? 'Failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  // ==================== NURSE REQUEST ACTION ====================
  static Future<ApiResult> requestActionNurse(
    int requestId,
    String action, {
    String? time,
  }) async {
    try {
      final body = {'action': action};
      if (time != null) {
        body['selected_time'] = time;
      }
      final response = await _authPost(
        '$baseUrl/requests/action/$requestId/',
        body,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return ApiResult.success(data);
      if (response.statusCode == 401) return ApiResult.error('Session expired');
      return ApiResult.error(data['error'] ?? 'Failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  // ==================== NURSE DONE ACTION ====================
  static Future<ApiResult> markDoneNurse(int requestId) async {
    try {
      final response = await _authPost(
        '$baseUrl/requests/done/nurse/$requestId/',
        {},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return ApiResult.success(data);
      if (response.statusCode == 401) return ApiResult.error('Session expired');
      return ApiResult.error(data['error'] ?? 'Failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  // ==================== SERVICES (NURSE) ====================

  /// Adds a new service for the nurse.
  /// Endpoint: POST /services/add/
  static Future<ApiResult> addService({
    required String name,
    required String description,
    required String price,
  }) async {
    try {
      final response = await _authPost('$baseUrl/services/add/', {
        'name': name,
        'description': description,
        'price': price,
      });

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) return ApiResult.success(data);
      if (response.statusCode == 401) return ApiResult.error('Session expired');

      return ApiResult.error(data['error'] ?? 'Failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  /// Edits an existing service.
  /// Endpoint: PUT /services/<service_id>/edit/
  static Future<ApiResult> editService({
    required int serviceId,
    required String name,
    required String description,
    required String price,
  }) async {
    try {
      final response = await _authPut('$baseUrl/services/$serviceId/edit/', {
        'name': name,
        'description': description,
        'price': price,
      });
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return ApiResult.success(data);
      if (response.statusCode == 401) return ApiResult.error('Session expired');
      return ApiResult.error(data['error'] ?? 'Failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  /// Deletes a service.
  /// Endpoint: DELETE /services/<service_id>/delete/
  static Future<ApiResult> deleteService(int serviceId) async {
    try {
      final response = await _authDelete('$baseUrl/services/$serviceId/delete/');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return ApiResult.success(data);
      if (response.statusCode == 401) return ApiResult.error('Session expired');
      return ApiResult.error(data['error'] ?? 'Failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  // ==================== PATIENT DASHBOARD ====================
  static Future<ApiResult> getPatientDashboard() async {
    try {
      final response = await _authGet('$baseUrl/dashboard/patient/');
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) return ApiResult.success(data);
      if (response.statusCode == 401) return ApiResult.error('Session expired');

      return ApiResult.error(data['error'] ?? 'Failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  // ==================== PATIENT REQUESTS ====================
  static Future<ApiResult> getPatientRequests(
    String category,
    String type,
  ) async {
    try {
      final response = await _authGet(
        '$baseUrl/patient/requests/$category/$type/',
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return ApiResult.success(data);
      if (response.statusCode == 401) return ApiResult.error('Session expired');
      return ApiResult.error(data['error'] ?? 'Failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  // ==================== PATIENT PROFILE GET ====================
  static Future<ApiResult> getProfile() async {
    try {
      final response = await _authGet('$baseUrl/patient/profile/edit/');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return ApiResult.success(data);
      if (response.statusCode == 401) return ApiResult.error('Session expired');
      return ApiResult.error(data['error'] ?? 'Failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  // ==================== PATIENT PROFILE POST (UPDATE) ====================
  static Future<ApiResult> updateProfile({
    required String username,
    required String phoneNumber,
    required String address,
    required String brief,
    required String governorate,
    File? profilePic,
  }) async {
    try {
      final token = await getAccessToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/patient/profile/edit/'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      request.fields['username'] = username;
      request.fields['phone_number'] = phoneNumber;
      request.fields['address'] = address;
      request.fields['brief'] = brief;
      request.fields['governorate'] = governorate;
      if (profilePic != null) {
        request.files.add(
          await http.MultipartFile.fromPath('profile_pic', profilePic.path),
        );
      }
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return ApiResult.success(data);
      if (response.statusCode == 401) return ApiResult.error('Session expired');
      return ApiResult.error(data['error'] ?? 'Failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  // ==================== DOCTOR BOOKING INFO ====================
  static Future<ApiResult> getDoctorBookingInfo(int doctorId) async {
    try {
      final response = await _authGet('$baseUrl/doctor/$doctorId/book/');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return ApiResult.success(data);
      if (response.statusCode == 401) return ApiResult.error('Session expired');
      return ApiResult.error(data['error'] ?? 'Failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  // ==================== DOCTOR BOOKING POST ====================
  static Future<ApiResult> bookDoctor({
    required int doctorId,
    required String date,
    required String time,
    required String diseaseDescription,
    required String governorate,
    required String address,
  }) async {
    try {
      final response = await _authPost('$baseUrl/doctor/$doctorId/book/', {
        'date': date,
        'time': time,
        'disease_description': diseaseDescription,
        'governorate': governorate,
        'address': address,
      });
      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200)
        return ApiResult.success(data);
      if (response.statusCode == 401) return ApiResult.error('Session expired');
      return ApiResult.error(data['error'] ?? 'Booking failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  // ==================== NURSE BOOKING (GET & POST) ====================
  static Future<ApiResult> getNurseBookingInfo(int nurseId) async {
    try {
      final response = await _authGet('$baseUrl/nurse/$nurseId/book/');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return ApiResult.success(data);
      if (response.statusCode == 401) return ApiResult.error('Session expired');
      return ApiResult.error(data['error'] ?? 'Failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  static Future<ApiResult> bookNurse({
    required int nurseId,
    required List<int> serviceIds,
    required String date,
    required String time,
    required String diseaseDescription,
    required String governorate,
    required String address,
  }) async {
    try {
      final response = await _authPost('$baseUrl/nurse/$nurseId/book/', {
        'services': serviceIds,
        'date': date,
        'time': time,
        'disease_description': diseaseDescription,
        'governorate': governorate,
        'address': address,
      });
      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200)
        return ApiResult.success(data);
      if (response.statusCode == 401) return ApiResult.error('Session expired');
      return ApiResult.error(data['error'] ?? 'Booking failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  // ==================== PATIENT - CANCEL / ACCEPT / MARK DONE ====================
  static Future<ApiResult> cancelDoctorRequest(int requestId) async {
    try {
      final response = await _authPost(
        '$baseUrl/doctor/cancel/$requestId/',
        {},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return ApiResult.success(data);
      if (response.statusCode == 401) return ApiResult.error('Session expired');
      return ApiResult.error(data['error'] ?? 'Failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  static Future<ApiResult> cancelNurseRequest(int requestId) async {
    try {
      final response = await _authPost('$baseUrl/nurse/cancel/$requestId/', {});
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return ApiResult.success(data);
      if (response.statusCode == 401) return ApiResult.error('Session expired');
      return ApiResult.error(data['error'] ?? 'Failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  static Future<ApiResult> acceptDoctorReschedule(int requestId) async {
    try {
      final response = await _authPost(
        '$baseUrl/doctor/reschedule/$requestId/',
        {},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return ApiResult.success(data);
      if (response.statusCode == 401) return ApiResult.error('Session expired');
      return ApiResult.error(data['error'] ?? 'Failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  static Future<ApiResult> acceptNurseReschedule(int requestId) async {
    try {
      final response = await _authPost(
        '$baseUrl/nurse/reschedule/$requestId/',
        {},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return ApiResult.success(data);
      if (response.statusCode == 401) return ApiResult.error('Session expired');
      return ApiResult.error(data['error'] ?? 'Failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  static Future<ApiResult> markDoctorDone(int requestId) async {
    try {
      final response = await _authPost('$baseUrl/doctor/done/$requestId/', {});
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return ApiResult.success(data);
      if (response.statusCode == 401) return ApiResult.error('Session expired');
      return ApiResult.error(data['error'] ?? 'Failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }

  static Future<ApiResult> markNurseDone(int requestId) async {
    try {
      final response = await _authPost('$baseUrl/nurse/done/$requestId/', {});
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return ApiResult.success(data);
      if (response.statusCode == 401) return ApiResult.error('Session expired');
      return ApiResult.error(data['error'] ?? 'Failed');
    } catch (e) {
      return ApiResult.error('Connection error: $e');
    }
  }
}

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