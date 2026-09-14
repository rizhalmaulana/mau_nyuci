class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;
  final List<String>? errors;
  final Map<String, dynamic>? errorDetails;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
    this.errors,
    this.errorDetails,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      message: json['message']?.toString(),
      statusCode: json['statusCode'] is int ? json['statusCode'] as int : null,
      errors: json['errors'] != null && json['errors'] is List
          ? List<String>.from(json['errors'])
          : null,
      errorDetails: json['errors'] is Map<String, dynamic>
          ? json['errors']
          : null,
    );
  }

  bool get hasError => !success;
  bool get hasValidationErrors => errors != null && errors!.isNotEmpty;
}
