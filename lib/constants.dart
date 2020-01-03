class StyleConstants {
  static const loginBackground = 'assets/memory-login.png';
  static const loginLogo = 'assets/logo-login.svg';
}

class StringConstants {
  static const email = 'Email';
  static const password = 'Password';
  static const login = 'Login';
  static const register = 'Register';
  static const backToLogin = 'Back to Login';
  static const yourName = 'Your name';
  static const confirmPassword = 'Confirm Password';
  static const confirmationCode = 'Emailed confirmation code';
  static const verify = 'Verify';
  static const photoManagement = 'Photo Management';
  static const digitalPhotoFrame = 'Start Photo Frame';
  static const logout = 'Log out';
}

class Constants {
  static final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final sessionToken = RegExp(r'session_token=([^;]*);');
}

class ServerConfiguration {
  static const server = '72.140.70.94:32888';
  static const protocol = 'http://';
  static const signupUrl = '/signup';
  static const verifyUrl = '/verify';
  static const loginUrl = '/signin';
  static const userUrl = '/user';
  static const imagesUrl = '/images';
  static const paramIndicator = '?';
  static const paramSeparator = '&';
  static const thumbnailIndicator = 'thumbnail=true';
  static const idIndicator = 'id=';
  static const widthIndicator = 'width=';
  static const thumbnailDirectory = '/.thumbnails';
}