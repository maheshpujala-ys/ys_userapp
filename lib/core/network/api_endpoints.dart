/// All API paths in one place — easier to audit and swap.
/// Mirrors the UAB Parking Management API surface used by this app.
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String authenticate = '/api/v1/auth/authenticate';
  static const String register = '/api/v1/auth/register';
  static const String changePassword = '/api/v1/auth/change-password';

  // Dashboard
  static const String dashboardStats = '/api/v1/dashboard/stats';
  static const String dashboardParkingLogs = '/api/v1/dashboard/parking-logs';

  // User logs (admin activity)
  static const String userLogs = '/api/v1/user-logs';

  // Tenants (= residents in UI)
  static const String tenants = '/api/v1/tenants';
  static const String tenantTypes = '/api/v1/tenants/types';
  static const String tenantStats = '/api/v1/tenants/stats';

  // Smart cards
  static const String smartCards = '/api/v1/smart_cards';
  static const String smartCardsAvailable = '/api/v1/smart_cards/available';
  static const String smartCardsStats = '/api/v1/smart_cards/stats';

  // Vehicles (registrations)
  static const String vehicles = '/api/v1/vehicle';
  static const String vehicleTypes = '/api/v1/vehicle_type';
  static const String registrations = '/api/v1/registrations';

  // Users (admin accounts)
  static const String users = '/api/v1/users';
  static const String userStats = '/api/v1/users/stats';

  // Parking locations (used to populate a location picker for create flows)
  static const String parkingLocations = '/api/v1/parking_location';

  // Image preview / download — presigned URL service.
  static String imagePreview(String imageId) => '/api/v1/images/preview/$imageId';
  static String imageDownload(String imageId) =>
      '/api/v1/images/download/$imageId';
}
