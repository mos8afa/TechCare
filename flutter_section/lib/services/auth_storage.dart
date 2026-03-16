import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  // حفظ بيانات الـ OTP flow مؤقتاً
  static Future<void> saveLoginSession({
    required String username,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('session_username', username);
    await prefs.setString('otp_source', 'login');
  }

  static Future<void> saveRegisterSession({
    required String pendingUserId,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('session_pending_user_id', pendingUserId);
    await prefs.setString('session_role', role);
    await prefs.setString('otp_source', 'signup');
  }

  static Future<void> saveForgetSession({required String email}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('session_email', email);
    await prefs.setString('otp_source', 'forget');
  }

  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('session_username');
  }

  static Future<String?> getPendingUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('session_pending_user_id');
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('session_role');
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('session_email');
  }

  static Future<String?> getOtpSource() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('otp_source');
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_username');
    await prefs.remove('session_pending_user_id');
    await prefs.remove('session_role');
    await prefs.remove('session_email');
    await prefs.remove('otp_source');
  }
}