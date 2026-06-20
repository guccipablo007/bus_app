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

  static UserRole? fromClaim(String claim) {
    for (final role in values) {
      if (role.claim == claim) return role;
    }
    return null;
  }
}

class UserSession {
  const UserSession({required this.userId, required this.roles});

  final String userId;
  final List<UserRole> roles;
}
