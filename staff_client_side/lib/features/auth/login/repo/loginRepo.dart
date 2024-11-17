// ignore_for_file: file_names

import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staff_client_side/server/server.dart';

class LoginRepo {
  static Future<bool> checkMNumberIsExist({
    required String mobile,
  }) async {
    var url = 'https://training-centre.vercel.app/api/checkNumberIsExist/';

    try {
      // Make the POST request
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          'mobile': mobile,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      // Log the response status code
      print('mobile: $mobile');
      print('response: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Decode response body
        final responseData = jsonDecode(response.body);

        // Save data to SharedPreferences
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', responseData['jwtToken'] ?? '');
        await prefs.setString('name', responseData['name'] ?? '');
        await prefs.setString('mobile', responseData['mblnumber'] ?? '');
        await prefs.setString('email', responseData['email'] ?? '');
        await prefs.setString('role', responseData['role'] ?? '');
        await prefs.setString('id', responseData['user_id'] ?? '');
        await prefs.setString('dob', responseData['dob'] ?? '');
        await prefs.setString('address', responseData['address'] ?? '');
        await prefs.setString('image_path', responseData['image_path'] ?? '');
        await prefs.setString('gender', responseData['gender'] ?? '');
        await prefs.setString('bloodGroup', responseData['bloodGroup'] ?? '');
        await prefs.setString('qualification', responseData['qualification'] ?? '');
        await prefs.setString('work_experience', responseData['work_experience'] ?? '');
        await prefs.setString('government_id', responseData['government_id'] ?? '');
        await prefs.setString('training_center_name', responseData['training_center_name'] ?? '');
        await prefs.setString('training_center_address', responseData['training_center_address'] ?? '');
        await prefs.setString('training_center_logo', responseData['training_center_logo'] ?? '');

        log('JWT Token saved: ${responseData['jwtToken']}');
        return true;
      } else {
        log('Error: Server returned status code ${response.statusCode}');
        return false;
      }
    } catch (e) {
      log('Error: ${e.toString()}');
      return false;
    }
  }
}
