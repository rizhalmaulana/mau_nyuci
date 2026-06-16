class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final List<String>? errors;
  final Map<String, dynamic>? errorDetails;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
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
      message: json['message'],
      errors: json['errors'] != null
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
