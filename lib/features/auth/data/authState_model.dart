class AuthState {
  final bool isLoggedIn;
  final String? userId;

  const AuthState({required this.isLoggedIn, this.userId});
}