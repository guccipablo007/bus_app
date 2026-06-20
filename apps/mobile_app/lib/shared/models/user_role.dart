enum UserRole {
  passenger('passenger'),
  agencyOwner('agency_owner'),
  agencyAdmin('agency_admin'),
  agencyStaff('agency_staff'),
  taxiDispatcher('taxi_dispatcher'),
  taxiDriver('taxi_driver'),
  superAdmin('super_admin');

  const UserRole(this.claim);

  final String claim;

  String get label => switch (this) {
    UserRole.passenger => 'Passenger',
    UserRole.agencyOwner => 'Agency owner',
    UserRole.agencyAdmin => 'Agency admin',
    UserRole.agencyStaff => 'Agency staff',
    UserRole.taxiDispatcher => 'Taxi dispatcher',
    UserRole.taxiDriver => 'Taxi driver',
    UserRole.superAdmin => 'Super admin',
  };

  static UserRole? fromClaim(String claim) {
    for (final role in values) {
      if (role.claim == claim) return role;
    }
    return null;
  }
}

class UserSession {
  const UserSession({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.roles,
    required this.accessToken,
    required this.refreshToken,
  });

  final String userId;
  final String fullName;
  final String email;
  final String? phone;
  final List<UserRole> roles;
  final String accessToken;
  final String refreshToken;

  factory UserSession.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? const {};
    final roles = (user['roles'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .map(UserRole.fromClaim)
        .whereType<UserRole>()
        .toList(growable: false);

    return UserSession(
      userId: user['id'] as String? ?? '',
      fullName: user['fullName'] as String? ?? 'User',
      email: user['email'] as String? ?? '',
      phone: user['phone'] as String?,
      roles: roles,
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
    );
  }
}
