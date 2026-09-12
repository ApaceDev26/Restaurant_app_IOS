import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:toto_partner/features/home/widgets/trial_widget.dart';
import 'package:toto_partner/features/language/controllers/localization_controller.dart';
import 'package:toto_partner/common/controllers/theme_controller.dart';
import 'package:toto_partner/features/chat/domain/models/notification_body_model.dart';
import 'package:toto_partner/features/profile/controllers/profile_controller.dart';
import 'package:toto_partner/helper/date_converter_helper.dart';
import 'package:toto_partner/helper/notification_helper.dart';
import 'package:toto_partner/helper/route_helper.dart';
import 'package:toto_partner/theme/dark_theme.dart';
import 'package:toto_partner/theme/light_theme.dart';
import 'package:toto_partner/util/app_constants.dart';
import 'package:toto_partner/util/messages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:url_strategy/url_strategy.dart';
import 'firebase_options.dart';
import 'helper/get_di.dart' as di;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  if (!GetPlatform.isWeb) {
    HttpOverrides.global = MyHttpOverrides();
  }
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  Map<String, Map<String, String>> languages = await di.init();

  // Initialize Firebase only if it hasn't been initialized already
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  NotificationBodyModel? body;
  try {
    if (GetPlatform.isMobile) {
      final RemoteMessage? remoteMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (remoteMessage != null) {
        body = NotificationHelper.convertNotification(remoteMessage.data);
      }
      await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
      FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
    }
  } catch (_) {}

  runApp(MyApp(languages: languages, body: body));
}

class MyApp extends StatelessWidget {
  final Map<String, Map<String, String>>? languages;
  final NotificationBodyModel? body;
  const MyApp({super.key, required this.languages, required this.body});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    Get.find<ProfileController>().setTrialWidgetNotShow(false);

    return GetBuilder<ThemeController>(builder: (themeController) {
      return GetBuilder<LocalizationController>(builder: (localizeController) {
        return GetMaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          navigatorKey: Get.key,
          theme: themeController.darkTheme ? dark : light,
          locale: localizeController.locale,
          translations: Messages(languages: languages),
          fallbackLocale: Locale(AppConstants.languages[0].languageCode!,
              AppConstants.languages[0].countryCode),
          initialRoute: RouteHelper.getSplashRoute(body),
          getPages: RouteHelper.routes,
          defaultTransition: Transition.topLevel,
          transitionDuration: const Duration(milliseconds: 500),
          builder: (BuildContext context, widget) {
            return MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(1.0)),
                child: Material(
                  child: SafeArea(
                    top: false,
                    bottom: GetPlatform.isAndroid,
                    child: Stack(children: [
                      widget!,
                      GetBuilder<ProfileController>(
                          builder: (profileController) {
                        bool canShow = profileController.profileModel != null &&
                            profileController.profileModel!.subscription !=
                                null &&
                            profileController
                                    .profileModel!.subscription!.isTrial ==
                                1 &&
                            profileController
                                    .profileModel!.subscription!.status ==
                                1 &&
                            DateConverter.differenceInDaysIgnoringTime(
                                    DateTime.parse(profileController
                                        .profileModel!
                                        .subscription!
                                        .expiryDate!),
                                    null) >=
                                0;

                        return canShow && !profileController.trialWidgetNotShow
                            ? Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 90),
                                  child: TrialWidget(
                                      subscription: profileController
                                          .profileModel!.subscription!),
                                ),
                              )
                            : const SizedBox();
                      }),
                    ]),
                  ),
                ));
          },
        );
      });
    });
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
