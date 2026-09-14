class ApiConstants {
  // --- BASE URL ---
  static const String baseUrl = 'http://192.168.100.149:5195/api/';
  static const String signalRHubUrl = 'http://192.168.100.149:5195/orderHub';
  static const String cloudflareCatalogIconUrl = 'https://cdn.beyondtalentservice.id/catalog-icons/';

  // --- TIMEOUTS ---
  static const int connectionTimeout = 15000; // 15 detik (dalam milidetik)
  static const int receiveTimeout = 15000;

  // --- ENDPOINTS ---
  // --- AUTH ---
  static const String register = 'Auth/register';
  static const String login = 'Auth/login';
  static const String firebaseAuth = 'Auth/firebase-auth';
  static const String checkUser = 'Auth/check-exists'; // Check if user exists by email/phone
  static const String profile = 'Auth/profile'; // Digunakan untuk GET dan PUT
  static const String changePassword = 'Auth/change-password'; // Gunakan PUT

  // --- DRIVER ---
  static const String driverTasks = 'Driver/tasks';
  static const String driverLocation = 'Driver/location';
  static const String driverUnsettledCash = 'Driver/unsettled-cash';

  // Fungsi helper untuk Path Parameters Driver
  static String driverPickup(String orderId) => 'Driver/$orderId/pickup';
  static String driverDeliverCash(String orderId) => 'Driver/$orderId/deliver-cash';
  static String driverDeliverPhoto(String orderId) => 'Driver/$orderId/deliver-photo';
  static String driverSettleCash(String driverId) => 'Driver/$driverId/settle-cash';

  // --- MEDIA ---
  static const String uploadProfilePicture = 'Media/upload-profile-picture';
  static const String uploadCatalogImage = 'Media/upload-catalog-image';
  static const String uploadQrisImage = 'Media/upload-qris-image';

  // --- ORDER ---
  static const String checkoutOrder = 'Order/checkout';
  static const String posCheckout = 'Order/pos-checkout';
  static const String customerOrders = 'Order/customer';

  // Fungsi helper untuk Path Parameters Order
  static String confirmWeight(String orderId) => 'Order/$orderId/confirm-weight';
  static String acceptOrder(String orderId) => 'Order/$orderId/accept';
  static String cancelOrder(String orderId) => 'Order/$orderId/cancel';
  static String finishWashing(String orderId) => 'Order/$orderId/finish-washing';
  static String completeOrder(String orderId) => 'Order/$orderId/complete';
  static String getStoreOrders(String storeId) => 'Order/store/$storeId';
  static String getStoreOrderHistory(String storeId, int page, int pageSize, {String? search, String? startDate, String? endDate}) {
    String url = 'Order/store/$storeId/history?page=$page&pageSize=$pageSize';
    if (search != null && search.isNotEmpty) url += '&search=${Uri.encodeComponent(search)}';
    if (startDate != null && startDate.isNotEmpty) url += '&startDate=${Uri.encodeComponent(startDate)}';
    if (endDate != null && endDate.isNotEmpty) url += '&endDate=${Uri.encodeComponent(endDate)}';
    return url;
  }
  static String getOrderById(String orderId) => 'Order/$orderId';
  static String customerCancelOrder(String orderId) => 'Order/$orderId/customer-cancel';
  static String uploadStoreReceipt(String orderId) => 'Order/store/$orderId/upload-receipt';
  static String verifyPayment(String orderId) => 'Order/$orderId/verify-payment';
  static String driverConfirmCash(String orderId) => 'Order/$orderId/driver-confirm-cash';

  // --- REVIEW ---
  static const String postReview = 'Review';
  static String getStoreReviews(String storeId) => 'Review/store/$storeId';

  // --- STORE ---
  static const String registerStore = 'Store/register-store';
  static const String getAllStores = 'Store/all';
  static const String getNearbyStores = 'Store/nearby';
  static const String getMyStore = 'Store/my-store';
  static const String updateStore = 'Store/my-store/update';
  static String storeTransactions(String storeId) => 'Store/$storeId/transactions';

  // --- STORE BANK ACCOUNT ---
  static const String masterBankMethods = 'StoreBankAccount/master-methods';
  static const String myBankAccounts = 'StoreBankAccount/my-accounts';
  
  // Premium Store Features
  static const String storeAnalyticsSummary = 'StoreAnalytics/summary';
  static const String storePromo = 'StorePromo';
  static const String storeExpense = 'StoreExpense';

  // Bank Account
  static const String bankAccounts = '/api/StoreBankAccount';
  static const String addBankAccount = 'StoreBankAccount/add';
  static String updateBankAccount(String id) => 'StoreBankAccount/update/$id';
  static String deleteBankAccount(String id) => 'StoreBankAccount/delete/$id';

  // --- STORE CATALOG ---
  static const String addCatalog = 'StoreCatalog/add';
  static const String getMyCatalog = 'StoreCatalog/my-catalog';
  static const String getAvailableIcons = 'StoreCatalog/available-icons';
  static String getStoreCatalog(String storeId) => 'StoreCatalog/$storeId';
  static String updateCatalog(String catalogId) => 'StoreCatalog/update/$catalogId';
  static String deleteCatalog(String catalogId) => 'StoreCatalog/delete/$catalogId';

  // --- NOTIFICATION ---
  static const String syncFcmToken = 'Notification/fcm-token';
  static const String getNotifications = 'Notification';
  static String readNotification(String id) => 'Notification/$id/read';
  static const String unreadNotificationCount = 'Notification/unread-count';

  // --- MENU CONFIG ---
  static const String menu = 'Menu';

  // --- PROMO BANNERS (Server-Driven UI) ---
  static String promoBanners(String appType) => 'PromoBanners?appType=$appType';

  // --- STAFF ---
  static String storeStaffs(String storeId) => 'stores/$storeId/staffs';

  // --- INVENTORY ---
  static String storeInventory(String storeId) => 'stores/$storeId/inventory';
  static String inventoryItem(String storeId, String itemId) => 'stores/$storeId/inventory/$itemId';
  static String inventoryTransactions(String storeId, String itemId) => 'stores/$storeId/inventory/$itemId/transactions';
}