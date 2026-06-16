class ApiConstants {
  // --- BASE URL ---
  static const String baseUrl = 'http://10.167.14.43:5195/api/';
  static const String signalRHubUrl = 'http://10.167.14.43:5195/orderHub';

  // --- TIMEOUTS ---
  static const int connectionTimeout = 8000; // 8 detik (dalam milidetik)
  static const int receiveTimeout = 8000;

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

  // --- ORDER ---
  static const String checkoutOrder = 'Order/checkout';
  static const String customerOrders = 'Order/customer';

  // Fungsi helper untuk Path Parameters Order
  static String confirmWeight(String orderId) => 'Order/$orderId/confirm-weight';
  static String acceptOrder(String orderId) => 'Order/$orderId/accept';
  static String cancelOrder(String orderId) => 'Order/$orderId/cancel';
  static String finishWashing(String orderId) => 'Order/$orderId/finish-washing';
  static String completeOrder(String orderId) => 'Order/$orderId/complete';
  static String getStoreOrders(String storeId) => 'Order/store/$storeId';
  static String getOrderById(String orderId) => 'Order/$orderId';
  static String customerCancelOrder(String orderId) => 'Order/$orderId/customer-cancel';
  static String uploadReceipt(String orderId) => 'Order/$orderId/upload-receipt';
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

  // --- STORE CATALOG ---
  static const String addCatalog = 'StoreCatalog/add';
  static String getStoreCatalog(String storeId) => 'StoreCatalog/$storeId';
}