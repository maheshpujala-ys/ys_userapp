/// Inputs for the authenticate endpoint.
/// `subdomain` and `customerCode` are hardcoded in the data source layer
/// (see [AuthRemoteDataSource.authenticate]); the UI only collects credentials.
class AuthCredentials {
  const AuthCredentials({
    required this.username,
    required this.password,
  });

  final String username;
  final String password;
}
