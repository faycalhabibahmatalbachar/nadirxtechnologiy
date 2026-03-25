class AppConfig {
  const AppConfig._();

  // Supabase
  static const String supabaseUrl = 'https://xbrlpovbwwyjvefblmuz.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhicmxwb3Zid3d5anZlZmJsbXV6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMzNDg2ODMsImV4cCI6MjA4ODkyNDY4M30.SPPTQJg9aknHd1EL6kwl1VVHh1MMLv7Qdlkp3fsfbRg';

  // Storage
  static const String participantsBucket = 'participants';

  // Edge Functions
  static const String submitFunction = 'submit-inscription';

  // App info
  static const String appName = 'NADIRX TECHNOLOGY';
  static const String appVersion = '1.0.0';

  // Contact NADIRX
  static const String contactWhatsapp = '+23568663737';
  static const String contactEmail = 'nadirxtechnology@gmail.com';
  static const String contactPhone = '+23568881226';
  static const String contactFacebook = 'https://www.facebook.com/faycalhabibahmat';

  // Local Storage keys
  static const String keyInscriptionId = 'inscription_id';
  static const String keyOnboardingSeen = 'onboarding_seen';
  static const String keyAdminLoggedIn = 'admin_logged_in';
}
