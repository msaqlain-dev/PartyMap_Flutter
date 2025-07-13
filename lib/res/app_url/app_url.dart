class AppUrl {
  static const String liveUrl = 'https://anwar.shahfahad.info';
  static const String localURL = 'http://10.0.2.2:8080';
  static const String environment = 'pub';

  static String get baseUrl => environment == 'dev' ? localURL : liveUrl;

  static final loginApi = '$baseUrl/api/auth/user/login';
  static final registerApi = '$baseUrl/api/auth/user/register';
  static final markersApi = '$baseUrl/api/markers';
}
