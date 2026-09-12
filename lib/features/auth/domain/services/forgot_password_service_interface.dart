import 'package:toto_partner/features/profile/domain/models/profile_model.dart';

abstract class ForgotPasswordServiceInterface {
  Future<dynamic> forgotPassword(String? email);
  Future<dynamic> verifyToken(String? email, String token);
  Future<dynamic> changePassword(ProfileModel userInfoModel, String password);
  Future<dynamic> resetPassword(String? resetToken, String? email,
      String password, String confirmPassword);
}
