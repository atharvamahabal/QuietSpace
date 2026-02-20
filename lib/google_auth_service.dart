import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '1082989712826-194kk6si8039tovlp9hf64ov8n67o1js.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserName = 'user_name';
  static const String _keyUserPhoto = 'user_photo';
  static const String _keyUserId = 'user_id'; // Add this for better tracking

  /// Checks if the user is currently logged in and validates session
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedLogin = prefs.getBool(_keyIsLoggedIn) ?? false;

      // Verify with actual Google Sign-In state
      final googleUser = await _googleSignIn.signInSilently();

      if (storedLogin && googleUser != null) {
        return true;
      } else if (storedLogin && googleUser == null) {
        // Clear invalid session
        await _clearUserData(prefs);
        return false;
      }

      return false;
    } catch (e) {
      print('GoogleAuthService.isLoggedIn error: $e');
      return false;
    }
  }

  /// Gets the current user data.
  static Future<Map<String, String?>> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'id': prefs.getString(_keyUserId),
        'email': prefs.getString(_keyUserEmail),
        'name': prefs.getString(_keyUserName),
        'photo': prefs.getString(_keyUserPhoto),
      };
    } catch (e) {
      print('GoogleAuthService.getCurrentUser error: $e');
      return {};
    }
  }

  /// Signs in with Google.
  static Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Sign out first to ensure clean state
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return {'success': false, 'message': 'Sign-in cancelled by user'};
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyUserId, googleUser.id);
      await prefs.setString(_keyUserEmail, googleUser.email);
      await prefs.setString(_keyUserName, googleUser.displayName ?? '');
      await prefs.setString(_keyUserPhoto, googleUser.photoUrl ?? '');

      print('Google sign-in successful: ${googleUser.email}');

      return {
        'success': true,
        'user': {
          'id': googleUser.id,
          'email': googleUser.email,
          'name': googleUser.displayName,
          'photo': googleUser.photoUrl,
        },
        'idToken': googleAuth.idToken,
        'accessToken': googleAuth.accessToken,
      };
    } catch (e) {
      print('Google sign-in failed: $e');
      return {'success': false, 'message': 'Sign-in failed: ${e.toString()}'};
    }
  }

  /// Signs out the current user.
  static Future<bool> signOut() async {
    try {
      await _googleSignIn.signOut();

      final prefs = await SharedPreferences.getInstance();
      await _clearUserData(prefs);

      print('Google sign-out successful');
      return true;
    } catch (e) {
      print('Google sign-out failed: $e');
      return false;
    }
  }

  /// Disconnects the user (revokes access)
  static Future<bool> disconnect() async {
    try {
      await _googleSignIn.disconnect();

      final prefs = await SharedPreferences.getInstance();
      await _clearUserData(prefs);

      print('Google disconnect successful');
      return true;
    } catch (e) {
      print('Google disconnect failed: $e');
      return false;
    }
  }

  /// Gets the current GoogleSignInAccount.
  static Future<GoogleSignInAccount?> getCurrentGoogleUser() async {
    try {
      return await _googleSignIn.signInSilently();
    } catch (e) {
      print('Google silent sign-in failed: $e');
      return null;
    }
  }

  /// Helper method to clear user data
  static Future<void> _clearUserData(SharedPreferences prefs) async {
    await prefs.setBool(_keyIsLoggedIn, false);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserPhoto);
  }
}
