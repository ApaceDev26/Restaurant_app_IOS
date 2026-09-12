import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:toto_partner/common/models/config_model.dart';
import 'package:toto_partner/common/models/response_model.dart';
import 'package:toto_partner/api/api_client.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toto_partner/features/business/domain/models/package_model.dart';
import 'package:toto_partner/features/profile/domain/models/profile_model.dart';

abstract class AuthServiceInterface {
  Future<dynamic> login(String? email, String password, String type);
  Future<bool> saveUserToken(String token, String zoneTopic, String type);
  Future<dynamic> updateToken({String notificationDeviceToken = ''});
  bool isLoggedIn();
  Future<bool> clearSharedData();
  Future<void> saveUserCredentials(String number, String password, String type);
  String getUserNumber();
  String getUserPassword();
  Future<bool> clearUserCredentials();
  String getUserToken();
  void setNotificationActive(bool isActive);
  Future<dynamic> toggleRestaurantClosedStatus();
  Future<dynamic> deleteVendor();
  Future<dynamic> registerRestaurant(Map<String, String> data, XFile? logo,
      XFile? cover, List<MultipartDocument> additionalDocument);
  Future<FilePickerResult?> picFile(MediaData mediaData);
  Future<XFile?> pickImageFromGallery();
  List<MultipartDocument> prepareMultipartDocuments(
      List<String> inputTypeList, List<FilePickerResult> additionalDocuments);
  Future<ResponseModel?> manageLogin(Response response, String type);
  String? getSubscriptionType(Response response);
  String? getExpiredToken(Response response, int? subscription);
  ProfileModel? getProfileModel(Response response, int? subscription);
  Future<bool> saveIsRestaurantRegistration(bool status);
  bool getIsRestaurantRegistration();
  Future<PackageModel?> getPackageList();
  String getUserType();
}
