import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:toto_partner/features/auth/controllers/auth_controller.dart';
import 'package:toto_partner/features/dashboard/screens/dashboard_screen.dart';
import 'package:toto_partner/features/splash/controllers/splash_controller.dart';
import 'package:toto_partner/features/chat/domain/models/notification_body_model.dart';
import 'package:toto_partner/features/profile/controllers/profile_controller.dart';
import 'package:toto_partner/helper/route_helper.dart';
import 'package:toto_partner/util/app_constants.dart';
import 'package:toto_partner/util/dimensions.dart';
import 'package:toto_partner/util/images.dart';
import 'package:toto_partner/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  final NotificationBodyModel? body;
  const SplashScreen({super.key, required this.body});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  StreamSubscription<List<ConnectivityResult>>? _onConnectivityChanged;

  @override
  void initState() {
    super.initState();

    bool firstTime = true;
    _onConnectivityChanged = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      bool isConnected = result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.mobile);

      if (!firstTime) {
        ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();
        ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
          backgroundColor: isConnected ? Colors.green : Colors.red,
          duration: Duration(seconds: isConnected ? 3 : 6000),
          content: Text(isConnected ? 'connected'.tr : 'no_connection'.tr,
              textAlign: TextAlign.center),
        ));
        if (isConnected) {
          _route();
        }
      }

      firstTime = false;
    });

    Get.find<SplashController>().initSharedData();
    _route();
  }

  @override
  void dispose() {
    super.dispose();

    _onConnectivityChanged?.cancel();
  }

  void _route() {
    Get.find<SplashController>().getConfigData().then((isSuccess) async {
      if (isSuccess) {
        Timer(const Duration(seconds: 1), () async {
          double? minimumVersion = _getMinimumVersion();
          bool isMaintenanceMode =
              Get.find<SplashController>().configModel!.maintenanceMode!;
          bool needsUpdate = AppConstants.appVersion < minimumVersion!;
          bool inMaintenanceForApp = isMaintenanceMode &&
              Get.find<SplashController>()
                  .configModel!
                  .maintenanceModeData!
                  .maintenanceSystemSetup!
                  .contains('restaurant_app');

          if (needsUpdate || inMaintenanceForApp) {
            Get.offNamed(RouteHelper.getUpdateRoute(needsUpdate));
            return;
          }

          if (widget.body != null) {
            await _handleNotificationRouting(widget.body);
          } else {
            await _handleDefaultRouting();
          }
        });
      }
    });
  }

  double? _getMinimumVersion() {
    if (GetPlatform.isAndroid) {
      return Get.find<SplashController>().configModel!.appMinimumVersionAndroid;
    } else if (GetPlatform.isIOS) {
      return Get.find<SplashController>().configModel!.appMinimumVersionIos;
    }
    return 0;
  }

  Future<void> _handleNotificationRouting(NotificationBodyModel? body) async {
    if (body!.notificationType == NotificationType.order) {
      await Get.find<ProfileController>().getProfile();
      Get.toNamed(RouteHelper.getOrderDetailsRoute(body.orderId,
          fromNotification: true));
    } else if (body.notificationType == NotificationType.message) {
      Get.toNamed(RouteHelper.getChatRoute(
          notificationBody: body,
          conversationId: body.conversationId,
          fromNotification: true));
    } else if (body.notificationType == NotificationType.block ||
        body.notificationType == NotificationType.unblock) {
      Get.toNamed(RouteHelper.getSignInRoute());
    } else if (body.notificationType == NotificationType.withdraw) {
      Get.to(const DashboardScreen(pageIndex: 3));
    } else if (body.notificationType == NotificationType.advertisement) {
      Get.toNamed(RouteHelper.getAdvertisementDetailsScreen(
          advertisementId: body.advertisementId, fromNotification: true));
    } else if (body.notificationType == NotificationType.campaign) {
      Get.toNamed(RouteHelper.getCampaignDetailsRoute(
          id: body.campaignId, fromNotification: true));
    } else {
      Get.toNamed(RouteHelper.getNotificationRoute(fromNotification: true));
    }
  }

  Future<void> _handleDefaultRouting() async {
    if (Get.find<AuthController>().isLoggedIn()) {
      await Get.find<AuthController>().updateToken();
      await Get.find<ProfileController>().getProfile();
      Get.offNamed(RouteHelper.getInitialRoute());
    } else {
      if (AppConstants.languages.length > 1 &&
          Get.find<SplashController>().showIntro()) {
        Get.offNamed(RouteHelper.getLanguageRoute('splash'));
      } else {
        Get.offNamed(RouteHelper.getSignInRoute());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(20), // adjust radius as needed
                    child: Image.asset(
                      Images.splashLogo,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ]),
            ),
          ),
          // Positioned(
          //   left: 0,
          //   right: 0,
          //   bottom: MediaQuery.of(context).padding.bottom + 16,
          //   child: Center(
          //     child: Image.asset(
          //       Images.skylonDevelopedByLogo,
          //       height: 32,
          //       fit: BoxFit.contain,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
