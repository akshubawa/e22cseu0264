// lib/models/token_response.dart
class TokenResponse {
  final String tokenType;
  final String accessToken;
  final String expiresIn;

  TokenResponse({
    required this.tokenType,
    required this.accessToken,
    required this.expiresIn,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      tokenType: json['token_type'],
      accessToken: json['access_token'],
      expiresIn: json['expires_in'],
    );
  }
}