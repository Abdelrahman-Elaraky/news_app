class ApiResponse {
  final bool isSuccessful;
  final String? message;
  final List<dynamic> data;

  ApiResponse({
    required this.isSuccessful,
    this.message,
    required this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      isSuccessful: json['status'] == 'ok',
      message: json['message'],
      data: json['articles'] ?? [],
    );
  }

  factory ApiResponse.error(String message) {
    return ApiResponse(
      isSuccessful: false,
      message: message,
      data: [],
    );
  }
}
