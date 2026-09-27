class StoreBankAccountModel {
  final String id;
  final String storeId;
  final String bankName;
  final String accountNumber;
  final String accountHolderName;
  final String? qrisImageUrl;

  StoreBankAccountModel({
    required this.id,
    required this.storeId,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolderName,
    this.qrisImageUrl,
  });

  factory StoreBankAccountModel.fromJson(Map<String, dynamic> json) {
    return StoreBankAccountModel(
      id: json['id'] ?? '',
      storeId: json['storeId'] ?? '',
      bankName: json['bankName'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      accountHolderName: json['accountHolderName'] ?? '',
      qrisImageUrl: json['qrisImageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeId': storeId,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountHolderName': accountHolderName,
      'qrisImageUrl': qrisImageUrl,
    };
  }
}
