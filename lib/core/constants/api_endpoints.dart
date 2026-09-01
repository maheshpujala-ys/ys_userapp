class ApiEndpoints {
  // Authentication & Profile
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String currentUser = '/auth/me';
  static const String forgotPassword = '/auth/forgot-password';
  static const String updateProfile = '/auth/profile';

  // Parking Hub
  static const String parkingSpots = '/parking/spots';
  static const String bookParkingSpot = '/parking/book';
  static const String activeParkingBookings = '/parking/bookings/active';
  static const String cancelParkingBooking = '/parking/bookings/cancel';
  static const String extendParkingBooking = '/parking/bookings/extend';

  // Residence & Society
  static const String residenceDetails = '/residence/details';
  static const String visitors = '/residence/visitors';
  static const String inviteVisitor = '/residence/visitors/invite';
  static const String cancelVisitor = '/residence/visitors/cancel';
  static const String deliveries = '/residence/deliveries';
  static const String updateDelivery = '/residence/deliveries/status';
  static const String domesticStaff = '/residence/staff';
  static const String amenities = '/residence/amenities';
  static const String bookAmenity = '/residence/amenities/book';
  static const String maintenanceTickets = '/residence/maintenance';
  static const String createMaintenanceTicket = '/residence/maintenance/create';
  static const String communityNotices = '/residence/community/notices';

  // Vehicles & Garage
  static const String vehicles = '/vehicles';
  static const String setPrimaryVehicle = '/vehicles/set-primary';
  static const String addVehicle = '/vehicles/register';

  // Services Hub
  static const String vehicleServices = '/services/catalog';
  static const String bookService = '/services/book';
  static const String activeServiceTrack = '/services/tracking';

  // EV Charging
  static const String evStations = '/ev/stations';
  static const String startEvCharging = '/ev/sessions/start';
  static const String stopEvCharging = '/ev/sessions/stop';
  static const String activeEvSession = '/ev/sessions/active';

  // Wallet & Payments
  static const String walletBalance = '/wallet/balance';
  static const String walletTransactions = '/wallet/transactions';
  static const String walletTopUp = '/wallet/topup';

  // Emergency SOS
  static const String emergencyDispatch = '/emergency/dispatch';
  static const String emergencyCancel = '/emergency/cancel';

  // Notifications
  static const String notifications = '/notifications';
  static const String markNotificationRead = '/notifications/read';
  static const String markAllNotificationsRead = '/notifications/read-all';

  // Admin Module
  static const String adminDashboard = '/admin/dashboard';
  static const String adminResidents = '/admin/residents';
  static const String adminVehicles = '/admin/vehicles';
  static const String adminSmartCards = '/admin/smart-cards';
  static const String adminSecurityLogs = '/admin/security/logs';
  static const String adminEntryExit = '/admin/entry-exit';
}
