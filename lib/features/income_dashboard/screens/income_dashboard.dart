import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toto_partner/common/controllers/theme_controller.dart';
import 'package:toto_partner/common/widgets/confirmation_dialog_widget.dart';
import 'package:toto_partner/common/widgets/custom_card.dart';
import 'package:toto_partner/common/widgets/custom_snackbar_widget.dart';
import 'package:toto_partner/common/widgets/order_shimmer_widget.dart';
import 'package:toto_partner/common/widgets/order_widget.dart';
import 'package:toto_partner/features/auth/controllers/auth_controller.dart';
import 'package:toto_partner/features/home/widgets/ads_section_widget.dart';
import 'package:toto_partner/features/home/widgets/order_summary_card.dart';
import 'package:toto_partner/features/notification/controllers/notification_controller.dart';
import 'package:toto_partner/features/order/controllers/order_controller.dart';
import 'package:toto_partner/features/order/domain/models/order_model.dart';
import 'package:toto_partner/features/home/widgets/order_button_widget.dart';
import 'package:toto_partner/features/profile/controllers/profile_controller.dart';
import 'package:toto_partner/features/subscription/controllers/subscription_controller.dart';
import 'package:toto_partner/helper/route_helper.dart';
import 'package:toto_partner/util/dimensions.dart';
import 'package:toto_partner/util/images.dart';
import 'package:toto_partner/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class IncomeDashboard extends StatefulWidget {
  const IncomeDashboard({super.key});

  @override
  State<IncomeDashboard> createState() => _IncomeDashboardState();
}

class _IncomeDashboardState extends State<IncomeDashboard> {
  late final AppLifecycleListener _listener;
  bool _isNotificationPermissionGranted = true;
  bool _isBatteryOptimizationGranted = true;

  @override
  void initState() {
    super.initState();

    // Initialize the AppLifecycleListener class and pass callbacks
    _listener = AppLifecycleListener(
      onStateChange: _onStateChanged,
    );

    _loadData();

    Future.delayed(const Duration(milliseconds: 200), () {
      checkPermission();
    });
  }

  // Listen to the app lifecycle state changes
  void _onStateChanged(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.resumed:
        Future.delayed(const Duration(milliseconds: 200), () {
          checkPermission();
        });
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
        break;
      case AppLifecycleState.paused:
        break;
    }
  }

  @override
  void dispose() {
    _listener.dispose();

    super.dispose();
  }

  Future<void> _loadData() async {
    await Get.find<ProfileController>().getProfile();
    await Get.find<OrderController>().getCurrentOrders();
    await Get.find<NotificationController>().getNotificationList();
  }

  Future<void> checkPermission() async {
    var notificationStatus = await Permission.notification.status;
    var batteryStatus = await Permission.ignoreBatteryOptimizations.status;

    if (notificationStatus.isDenied || notificationStatus.isPermanentlyDenied) {
      setState(() {
        _isNotificationPermissionGranted = false;
        _isBatteryOptimizationGranted = true;
      });
    } else if (batteryStatus.isDenied) {
      setState(() {
        _isBatteryOptimizationGranted = false;
        _isNotificationPermissionGranted = true;
      });
    } else {
      setState(() {
        _isNotificationPermissionGranted = true;
        _isBatteryOptimizationGranted = true;
      });
      Get.find<ProfileController>().setBackgroundNotificationActive(true);
    }

    if (batteryStatus.isDenied) {
      Get.find<ProfileController>().setBackgroundNotificationActive(false);
    }
  }

  final WidgetStateProperty<Icon?> thumbIcon =
      WidgetStateProperty.resolveWith<Icon?>(
    (Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return Icon(Icons.circle,
            color: Get.find<ThemeController>().darkTheme
                ? Colors.black
                : Colors.white);
      }
      return Icon(Icons.circle,
          color: Get.find<ThemeController>().darkTheme
              ? Colors.white
              : Colors.black);
    },
  );

  Future<void> requestNotificationPermission() async {
    if (await Permission.notification.request().isGranted) {
      return;
    } else {
      await openAppSettings();
    }

    checkPermission();
  }

  void requestBatteryOptimization() async {
    var status = await Permission.ignoreBatteryOptimizations.status;

    if (status.isGranted) {
      return;
    } else if (status.isDenied) {
      await Permission.ignoreBatteryOptimizations.request();
    } else {
      openAppSettings();
    }

    checkPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Theme.of(context).cardColor,
        titleSpacing: 0,
        surfaceTintColor: Theme.of(context).cardColor,
        shadowColor: Theme.of(context).hintColor.withValues(alpha: 0.5),
        elevation: 2,
        title: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Image.asset(
            Get.isDarkMode ? Images.logoNameWhite : Images.logoName,
            width: 220,
            height: 60,
          ),
        ),
        actions: [
          IconButton(
            icon: GetBuilder<NotificationController>(
                builder: (notificationController) {
              bool hasNewNotification = false;

              if (notificationController.notificationList != null) {
                hasNewNotification =
                    notificationController.notificationList!.length !=
                        notificationController.getSeenNotificationCount();
              }

              return Stack(children: [
                Icon(Icons.notifications,
                    size: 25,
                    color: Theme.of(context).textTheme.bodyLarge!.color),
                hasNewNotification
                    ? Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          height: 10,
                          width: 10,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                                width: 1, color: Theme.of(context).cardColor),
                          ),
                        ))
                    : const SizedBox(),
              ]);
            }),
            onPressed: () {
              Get.find<SubscriptionController>()
                  .trialEndBottomSheet()
                  .then((trialEnd) {
                if (trialEnd) {
                  Get.toNamed(RouteHelper.getNotificationRoute());
                }
              });
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadData();
        },
        child: Column(
          children: [
            if (!_isNotificationPermissionGranted)
              permissionWarning(
                  isBatteryPermission: false,
                  onTap: requestNotificationPermission,
                  closeOnTap: () {
                    setState(() {
                      _isNotificationPermissionGranted = true;
                    });
                  }),
            if (!_isBatteryOptimizationGranted)
              permissionWarning(
                  isBatteryPermission: true,
                  onTap: requestBatteryOptimization,
                  closeOnTap: () {
                    setState(() {
                      _isBatteryOptimizationGranted = true;
                    });
                  }),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                physics: const AlwaysScrollableScrollPhysics(),
                child:
                    GetBuilder<ProfileController>(builder: (profileController) {
                  return profileController.profileModel != null
                      ? Column(children: [
                          SizedBox(
                              height: profileController
                                          .modulePermission?.restaurantConfig ??
                                      false
                                  ? Dimensions.paddingSizeDefault
                                  : 0),
                          profileController.modulePermission?.myWallet ?? false
                              ? OrderSummaryCard(
                                  profileController: profileController)
                              : const SizedBox(),
                          SizedBox(
                              height: profileController
                                          .modulePermission?.myWallet ??
                                      false
                                  ? Dimensions.paddingSizeLarge
                                  : 0),
                          profileController.modulePermission?.newAds ?? false
                              ? const AdsSectionWidget()
                              : const SizedBox(),
                          SizedBox(
                              height:
                                  profileController.modulePermission?.newAds ??
                                          false
                                      ? Dimensions.paddingSizeLarge
                                      : 0),
                        ])
                      : Column(children: [
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusDefault),
                            child: Shimmer(
                              child: Container(
                                height: 50,
                                width: double.infinity,
                                color: Theme.of(context).shadowColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeDefault),
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusDefault),
                            child: Shimmer(
                              child: Container(
                                height: 200,
                                width: double.infinity,
                                color: Theme.of(context).shadowColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeDefault),
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusDefault),
                            child: Shimmer(
                              child: Container(
                                height: 150,
                                width: double.infinity,
                                color: Theme.of(context).shadowColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeDefault),
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusDefault),
                            child: Shimmer(
                              child: Container(
                                height: 70,
                                width: double.infinity,
                                color: Theme.of(context).shadowColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeDefault),
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusDefault),
                            child: Shimmer(
                              child: Container(
                                height: 70,
                                width: double.infinity,
                                color: Theme.of(context).shadowColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeDefault),
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusDefault),
                            child: Shimmer(
                              child: Container(
                                height: 70,
                                width: double.infinity,
                                color: Theme.of(context).shadowColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeDefault),
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusDefault),
                            child: Shimmer(
                              child: Container(
                                height: 70,
                                width: double.infinity,
                                color: Theme.of(context).shadowColor,
                              ),
                            ),
                          ),
                        ]);
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget permissionWarning(
      {required bool isBatteryPermission,
      required Function() onTap,
      required Function() closeOnTap}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
      ),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Row(children: [
                if (isBatteryPermission)
                  const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(
                      Icons.warning_rounded,
                      color: Colors.yellow,
                    ),
                  ),
                Expanded(
                  child: Row(children: [
                    Flexible(
                      child: Text(
                        isBatteryPermission
                            ? 'for_better_performance_allow_notification_to_run_in_background'
                                .tr
                            : 'notification_is_disabled_please_allow_notification'
                                .tr,
                        maxLines: 2,
                        style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    const Icon(
                      Icons.arrow_circle_right_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ]),
                ),
                const SizedBox(width: 20),
              ]),
            ),
            Positioned(
              top: 5,
              right: 5,
              child: InkWell(
                onTap: closeOnTap,
                child: const Icon(Icons.clear, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
