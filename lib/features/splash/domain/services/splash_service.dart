import 'package:toto_partner/common/models/config_model.dart';
import 'package:toto_partner/features/splash/domain/repositories/splash_repository_service.dart';
import 'package:toto_partner/features/splash/domain/services/splash_service_interface.dart';

class SplashService implements SplashServiceInterface {
  final SplashRepositoryInterface splashRepositoryInterface;
  SplashService({required this.splashRepositoryInterface});

  @override
  Future<ConfigModel?> getConfigData() async {
    return await splashRepositoryInterface.getConfigData();
  }

  @override
  Future<bool> initSharedData() {
    return splashRepositoryInterface.initSharedData();
  }

  @override
  Future<bool> removeSharedData() {
    return splashRepositoryInterface.removeSharedData();
  }

  @override
  bool showIntro() {
    return splashRepositoryInterface.showIntro();
  }

  @override
  void setIntro(bool intro) {
    splashRepositoryInterface.setIntro(intro);
  }
}
