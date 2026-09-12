import 'package:toto_partner/common/models/response_model.dart';
import 'package:toto_partner/common/widgets/custom_snackbar_widget.dart';
import 'package:toto_partner/api/api_client.dart';
import 'package:toto_partner/features/coupon/domain/models/coupon_body_model.dart';
import 'package:toto_partner/features/coupon/domain/repositories/coupon_repository_interface.dart';
import 'package:toto_partner/util/app_constants.dart';
import 'package:get/get.dart';

class CouponRepository implements CouponRepositoryInterface {
  final ApiClient apiClient;
  CouponRepository({required this.apiClient});

  @override
  Future<List<CouponBodyModel>?> getCouponList(int offset) async {
    List<CouponBodyModel>? couponList;
    Response response = await apiClient
        .getData('${AppConstants.couponListUri}?limit=50&offset=$offset');
    if (response.statusCode == 200) {
      couponList = [];
      response.body.forEach((coupon) {
        couponList!.add(CouponBodyModel.fromJson(coupon));
      });
    }
    return couponList;
  }

  @override
  Future<CouponBodyModel?> get(int id) async {
    CouponBodyModel? couponDetails;
    Response response = await apiClient
        .getData('${AppConstants.couponDetailsUri}?coupon_id=$id');
    if (response.statusCode == 200) {
      couponDetails = CouponBodyModel.fromJson(response.body[0]);
    }
    return couponDetails;
  }

  @override
  Future<bool> changeStatus(int? couponId, int status) async {
    bool success = false;
    Response response = await apiClient.postData(
        AppConstants.couponChangeStatusUri,
        {"coupon_id": couponId, "status": status});
    if (response.statusCode == 200) {
      success = true;
      showCustomSnackBar(response.body['message'], isError: false);
    }
    return success;
  }

  @override
  Future<ResponseModel?> addCoupon(Map<String, String?> data) async {
    ResponseModel? responseModel;
    Response response =
        await apiClient.postData(AppConstants.addCouponUri, data);
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body['message']);
    }
    return responseModel;
  }

  @override
  Future<ResponseModel?> update(Map<String, dynamic> body) async {
    ResponseModel? responseModel;
    Response response =
        await apiClient.postData(AppConstants.couponUpdateUri, body);
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body['message']);
    }
    return responseModel;
  }

  @override
  Future<ResponseModel?> delete({int? id}) async {
    ResponseModel? responseModel;
    Response response = await apiClient
        .postData(AppConstants.couponDeleteUri, {"coupon_id": id});
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body['message']);
    }
    return responseModel;
  }

  @override
  Future add(value) {
    // TODO: implement add
    throw UnimplementedError();
  }

  @override
  Future getList() {
    // TODO: implement getList
    throw UnimplementedError();
  }
}
