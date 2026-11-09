class AppConstants {
  AppConstants._();

  static const appName = 'Study Armenia LK';
  static const packageId = 'com.armenia.lanka.edu';
  static const supportEmail = 'armenialankaedu@gmail.com';
  static const facebookUrl = 'https://www.facebook.com/share/17kEMmU4fu/';

  static const counselor1Phone = '94778200056';
  static const counselor2Phone = '94778200043';
  static const counselor3Phone = '94778200053';

  static Uri whatsappUri(String phone, String message) => Uri.https(
        'wa.me',
        '/$phone',
        {'text': message},
      );

  static Uri get meetingBookingUri => whatsappUri(
        counselor1Phone,
        'Hello, I would like to book a counseling meeting.',
      );

  static Uri get playStoreUri => Uri.parse('market://details?id=$packageId');
  static Uri get playStoreWebUri => Uri.parse(
        'https://play.google.com/store/apps/details?id=$packageId',
      );
}
