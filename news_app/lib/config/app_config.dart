import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../features/news_app/data/models/api_response.dart';



class AppConfig {
  static const String baseUrl = 'https://newsapi.org/v2';
  static const String newsApiKey = 'c414bf24520d44198b7cf713defa023e';

  static Future<ApiResponse> getSearchResults({required String query, int page = 1}) async {
    final uri = Uri.parse('$baseUrl/everything?q=$query&page=$page&apiKey=$newsApiKey');
    final response = await http.get(uri);
    return _handleResponse(response);
  }

  static ApiResponse _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return ApiResponse.fromJson(json);
    } else {
      return ApiResponse.error('Error: ${response.statusCode}');
    }
  }
}
