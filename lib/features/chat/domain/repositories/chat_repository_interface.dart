import 'package:toto_partner/api/api_client.dart';
import 'package:toto_partner/helper/user_type.dart';
import 'package:toto_partner/interface/repository_interface.dart';

abstract class ChatRepositoryInterface implements RepositoryInterface {
  Future<dynamic> getConversationList(int offset, String type);
  Future<dynamic> searchConversationList(String name);
  Future<dynamic> getMessages(
      int offset, int? userId, UserType userType, int? conversationID);
  Future<dynamic> sendMessage(String message, List<MultipartBody> images,
      int? conversationId, int? userId, UserType userType);
}
