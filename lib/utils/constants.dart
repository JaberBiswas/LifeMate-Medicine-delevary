class AppConstants {
  // App Info
  static const String appName = 'LifeMate';
  
  // Collections
  static const String usersCollection = 'users';
  static const String medicinesCollection = 'medicines';
  static const String ordersCollection = 'orders';
  static const String categoriesCollection = 'categories';
  static const String cartCollection = 'cart';
  
  // User Roles
  static const String adminRole = 'admin';
  static const String userRole = 'user';
  
  // Order Status
  static const String orderPending = 'pending';
  static const String orderConfirmed = 'confirmed';
  static const String orderProcessing = 'processing';
  static const String orderShipped = 'shipped';
  static const String orderDelivered = 'delivered';
  static const String orderCancelled = 'cancelled';
  static const String orderReturned = 'returned';
  
  // Payment Status
  static const String paymentPending = 'pending';
  static const String paymentSuccess = 'success';
  static const String paymentFailed = 'failed';
  
  // Storage Paths
  static const String medicineImagesPath = 'medicine_images';
  static const String userImagesPath = 'user_images';
  static const String categoryImagesPath = 'category_images';
  
  // Default Values
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double defaultCardRadius = 16.0;
}

