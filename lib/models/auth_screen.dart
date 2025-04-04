// lib/models/auth_response.dart
class AuthResponse {
  final String clientId;
  final String clientSecret;

  AuthResponse({
    required this.clientId,
    required this.clientSecret,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      clientId: json['clientID'],
      clientSecret: json['clientSecret'],
    );
  }
}