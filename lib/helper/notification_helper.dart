import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:toto_partner/features/advertisement/controllers/advertisement_controller.dart';
import 'package:toto_partner/features/auth/controllers/auth_controller.dart';
import 'package:toto_partner/features/chat/controllers/chat_controller.dart';
import 'package:toto_partner/features/dashboard/screens/dashboard_screen.dart';
import 'package:toto_partner/features/order/controllers/order_controller.dart';
import 'package:toto_partner/features/chat/domain/models/notification_body_model.dart';
import 'package:toto_partner/features/dashboard/widgets/new_request_dialog_widget.dart';
import 'package:toto_partner/features/splash/controllers/splash_controller.dart';
import 'package:toto_partner/helper/custom_print_helper.dart';
import 'package:toto_partner/helper/route_helper.dart';
import 'package:toto_partner/helper/user_type.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:toto_partner/main.dart';
import 'package:toto_partner/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _foregroundOrderIdKey = 'foreground_order_id';

Future<void> _persistForegroundOrderId(String? orderId) async {
  final sharedPreferences = await SharedPreferences.getInstance();
  if (orderId != null && orderId.isNotEmpty) {
    await sharedPreferences.setString(_foregroundOrderIdKey, orderId);
  } else {
    await sharedPreferences.remove(_foregroundOrderIdKey);
  }
}

Future<String?> _readForegroundOrderId() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getString(_foregroundOrderIdKey);
}

Future<bool> _stopForegroundIfMatches(String? orderId) async {
  if (orderId == null || orderId.isEmpty) return false;
  final storedOrderId = await _readForegroundOrderId();
  if (storedOrderId == orderId) {
    await stopService();
    return true;
  }
  return false;
}

class NotificationHelper {
  static Future<void> initialize(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidInitialize =
        const AndroidInitializationSettings('notification_icon');
    var iOSInitialize = const DarwinInitializationSettings();
    var initializationsSettings =
        InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .requestNotificationsPermission();

    flutterLocalNotificationsPlugin.initialize(initializationsSettings,
        onDidReceiveNotificationResponse: (NotificationResponse load) async {
      try {
        if (load.payload!.isNotEmpty) {
          NotificationBodyModel payload =
              NotificationBodyModel.fromJson(jsonDecode(load.payload!));

          if (payload.notificationType == NotificationType.order) {
            Get.toNamed(RouteHelper.getOrderDetailsRoute(payload.orderId,
                fromNotification: true));
          } else if (payload.notificationType ==
              NotificationType.advertisement) {
            Get.toNamed(RouteHelper.getAdvertisementDetailsScreen(
                advertisementId: payload.advertisementId,
                fromNotification: true));
          } else if (payload.notificationType == NotificationType.message) {
            customPrint('message enter');
            Get.toNamed(RouteHelper.getChatRoute(
              notificationBody: payload,
              conversationId: payload.conversationId,
              fromNotification: true,
            ));
          } else if (payload.notificationType == NotificationType.block ||
              payload.notificationType == NotificationType.unblock) {
            Get.toNamed(RouteHelper.getSignInRoute());
          } else if (payload.notificationType == NotificationType.withdraw) {
            Get.to(const DashboardScreen(pageIndex: 3));
          } else if (payload.notificationType == NotificationType.campaign) {
            Get.toNamed(RouteHelper.getCampaignDetailsRoute(
                id: payload.campaignId, fromNotification: true));
          } else {
            Get.toNamed(
                RouteHelper.getNotificationRoute(fromNotification: true));
          }
        }
      } catch (_) {}
      return;
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      customPrint("onMessage: ${message.data}");
      customPrint("onMessage message type:${message.data['type']}");

      // Validate notification has type
      String? type = message.data['type'];
      if (type == null || type.isEmpty) {
        customPrint(
            "Skipping foreground notification with missing type. Data: ${message.data}");
        return;
      }

      // Validate notification has required content (check both notification and data payloads)
      String? dataTitle = message.data['title'];
      String? dataBody = message.data['body'];
      String? notificationTitle = message.notification?.title;
      String? notificationBody = message.notification?.body;

      // Check if both notification payload and data payload are empty
      bool hasValidNotificationPayload =
          (notificationTitle != null && notificationTitle.trim().isNotEmpty) ||
              (notificationBody != null && notificationBody.trim().isNotEmpty);
      bool hasValidDataPayload =
          (dataTitle != null && dataTitle.trim().isNotEmpty) ||
              (dataBody != null && dataBody.trim().isNotEmpty);

      // Skip if neither payload has valid content (unless it's a maintenance message which doesn't need title/body)
      if (type != 'maintenance' &&
          !hasValidNotificationPayload &&
          !hasValidDataPayload) {
        customPrint(
            "Skipping notification with empty payloads. Notification: title='$notificationTitle', body='$notificationBody'. Data: title='$dataTitle', body='$dataBody', type='$type'");
        return;
      }

      // Additional check: Block completely empty notifications (no title AND no body in both payloads)
      bool hasTitle =
          (notificationTitle != null && notificationTitle.trim().isNotEmpty) ||
              (dataTitle != null && dataTitle.trim().isNotEmpty);
      bool hasBody =
          (notificationBody != null && notificationBody.trim().isNotEmpty) ||
              (dataBody != null && dataBody.trim().isNotEmpty);

      // Block if notification has no title AND no body (completely empty)
      if (type != 'maintenance' && !hasTitle && !hasBody) {
        customPrint(
            "Blocking completely empty notification (no title and no body). Type: '$type', Data: ${message.data}");
        return;
      }

      if (message.data['type'] == 'maintenance') {
        Get.find<SplashController>().getConfigData();
        return;
      }

      if (message.data['type'] == 'message' &&
          Get.currentRoute.startsWith(RouteHelper.chatScreen)) {
        if (Get.find<AuthController>().isLoggedIn()) {
          Get.find<ChatController>().getConversationList(1);
          if (Get.find<ChatController>()
                  .messageModel!
                  .conversation!
                  .id
                  .toString() ==
              message.data['conversation_id'].toString()) {
            Get.find<ChatController>().getMessages(
              1,
              NotificationBodyModel(
                notificationType: NotificationType.message,
                adminId: message.data['sender_type'] == UserType.admin.name
                    ? 0
                    : null,
                customerId: message.data['sender_type'] == UserType.user.name
                    ? 0
                    : null,
                deliveryManId:
                    message.data['sender_type'] == UserType.delivery_man.name
                        ? 0
                        : null,
              ),
              null,
              int.parse(message.data['conversation_id'].toString()),
            );
          } else {
            NotificationHelper.showNotification(
                message, flutterLocalNotificationsPlugin);
          }
        }
      } else if (message.data['type'] == 'message' &&
          Get.currentRoute.startsWith(RouteHelper.conversationListScreen)) {
        if (Get.find<AuthController>().isLoggedIn()) {
          Get.find<ChatController>().getConversationList(1);
        }
        NotificationHelper.showNotification(
            message, flutterLocalNotificationsPlugin);
      } else if (message.data['type'] == 'maintenance') {
      } else {
        NotificationHelper.showNotification(
            message, flutterLocalNotificationsPlugin);

        // Only show new order dialog for actual new orders, not order status updates
        if (message.data['type'] == 'new_order' ||
            message.data['title'] == 'New order placed') {
          Get.find<OrderController>()
              .getPaginatedOrders(1, true, isSubscription: 0);
          Get.find<OrderController>().getCurrentOrders();

          Get.dialog(const NewRequestDialogWidget());
        } else if (message.data['type'] == 'advertisement') {
          Get.find<AdvertisementController>().getAdvertisementList('1', 'all');
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      customPrint("onOpenApp: ${message.data}");
      customPrint("onOpenApp message type:${message.data['type']}");

      // Validate notification has content before processing
      String? dataTitle = message.data['title'];
      String? dataBody = message.data['body'];
      String? notificationTitle = message.notification?.title;
      String? notificationBodyText = message.notification?.body;
      String? type = message.data['type'];

      // Check if notification has any content
      bool hasTitle = (dataTitle != null && dataTitle.trim().isNotEmpty) ||
          (notificationTitle != null && notificationTitle.trim().isNotEmpty);
      bool hasBody = (dataBody != null && dataBody.trim().isNotEmpty) ||
          (notificationBodyText != null &&
              notificationBodyText.trim().isNotEmpty);

      // Block completely empty notifications
      if (type != null && type != 'maintenance' && !hasTitle && !hasBody) {
        customPrint(
            "Blocking empty notification opened from background (no title and no body). Data: ${message.data}");
        return;
      }

      try {
        NotificationBodyModel notificationBody =
            convertNotification(message.data);

        if (notificationBody.notificationType == NotificationType.order) {
          Get.toNamed(RouteHelper.getOrderDetailsRoute(
              int.parse(message.data['order_id']),
              fromNotification: true));
        } else if (notificationBody.notificationType ==
            NotificationType.message) {
          Get.toNamed(RouteHelper.getChatRoute(
              notificationBody: notificationBody,
              conversationId: notificationBody.conversationId,
              fromNotification: true));
        } else if (notificationBody.notificationType ==
                NotificationType.block ||
            notificationBody.notificationType == NotificationType.unblock) {
          Get.toNamed(RouteHelper.getSignInRoute());
        } else if (notificationBody.notificationType ==
            NotificationType.withdraw) {
          Get.to(const DashboardScreen(pageIndex: 3));
        } else if (notificationBody.notificationType ==
            NotificationType.advertisement) {
          Get.toNamed(RouteHelper.getAdvertisementDetailsScreen(
              advertisementId: notificationBody.advertisementId,
              fromNotification: true));
        } else if (notificationBody.notificationType ==
            NotificationType.campaign) {
          Get.toNamed(RouteHelper.getCampaignDetailsRoute(
              id: notificationBody.campaignId, fromNotification: true));
        } else {
          Get.toNamed(RouteHelper.getNotificationRoute(fromNotification: true));
        }
      } catch (_) {}
    });
  }

  static Future<void> showNotification(
      RemoteMessage message, FlutterLocalNotificationsPlugin fln) async {
    // Validate notification data before displaying
    // Check both notification payload and data payload
    String? dataTitle = message.data['title'];
    String? dataBody = message.data['body'];
    String? notificationTitle = message.notification?.title;
    String? notificationBody = message.notification?.body;

    // Prefer data payload over notification payload for app-controlled notifications
    String? title = dataTitle ?? notificationTitle;
    String? body = dataBody ?? notificationBody;

    // Block notification if both title and body are empty/null
    bool hasTitle = title != null && title.trim().isNotEmpty;
    bool hasBody = body != null && body.trim().isNotEmpty;

    if (!hasTitle && !hasBody) {
      customPrint(
          "Blocking empty notification (no title and no body). Data payload - Title: '$dataTitle', Body: '$dataBody'. Notification payload - Title: '$notificationTitle', Body: '$notificationBody'. Full data: ${message.data}");
      return;
    }

    // If we have at least one (title or body), use empty string as fallback for the missing one
    final String finalTitle = hasTitle ? title.trim() : '';
    final String finalBody = hasBody ? body.trim() : '';

    // Trigger vibration when notification arrives
    _triggerVibration();

    if (!GetPlatform.isIOS) {
      String? image;
      NotificationBodyModel notificationBody;
      notificationBody = convertNotification(message.data);

      image = (message.data['image'] != null &&
              message.data['image'].isNotEmpty)
          ? message.data['image'].startsWith('http')
              ? message.data['image']
              : '${AppConstants.baseUrl}/storage/app/public/notification/${message.data['image']}'
          : null;

      if (image != null && image.isNotEmpty) {
        try {
          await showBigPictureNotificationHiddenLargeIcon(
              finalTitle, finalBody, notificationBody, image, fln);
        } catch (e) {
          await showBigTextNotification(
              finalTitle, finalBody, notificationBody, fln);
        }
      } else {
        await showBigTextNotification(
            finalTitle, finalBody, notificationBody, fln);
      }
    }
  }

  static Future<void> _triggerVibration() async {
    try {
      final bool? hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        // Vibrate pattern: wait 0ms, vibrate 500ms, wait 200ms, vibrate 500ms
        Vibration.vibrate(pattern: [0, 500, 200, 500]);
      }
    } catch (e) {
      customPrint('Vibration error: $e');
    }
  }

  static Future<void> showTextNotification(
      String title,
      String body,
      NotificationBodyModel? notificationBody,
      FlutterLocalNotificationsPlugin fln) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'stackfood',
      'stackfood',
      playSound: true,
      importance: Importance.max,
      priority: Priority.max,
      sound: const RawResourceAndroidNotificationSound('notification'),
    );
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, title, body, platformChannelSpecifics,
        payload: notificationBody != null
            ? jsonEncode(notificationBody.toJson())
            : null);
  }

  static Future<void> showBigTextNotification(
      String? title,
      String body,
      NotificationBodyModel? notificationBody,
      FlutterLocalNotificationsPlugin fln) async {
    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      body,
      htmlFormatBigText: true,
      contentTitle: title,
      htmlFormatContentTitle: true,
    );
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'stackfood',
      'stackfood',
      importance: Importance.max,
      styleInformation: bigTextStyleInformation,
      priority: Priority.max,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification'),
    );
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, title, body, platformChannelSpecifics,
        payload: notificationBody != null
            ? jsonEncode(notificationBody.toJson())
            : null);
  }

  static Future<void> showBigPictureNotificationHiddenLargeIcon(
      String? title,
      String? body,
      NotificationBodyModel? notificationBody,
      String image,
      FlutterLocalNotificationsPlugin fln) async {
    final String largeIconPath = await _downloadAndSaveFile(image, 'largeIcon');
    final String bigPicturePath =
        await _downloadAndSaveFile(image, 'bigPicture');
    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath),
      hideExpandedLargeIcon: true,
      contentTitle: title,
      htmlFormatContentTitle: true,
      summaryText: body,
      htmlFormatSummaryText: true,
    );
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'stackfood',
      'stackfood',
      largeIcon: FilePathAndroidBitmap(largeIconPath),
      priority: Priority.max,
      playSound: true,
      styleInformation: bigPictureStyleInformation,
      importance: Importance.max,
      sound: const RawResourceAndroidNotificationSound('notification'),
    );
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, title, body, platformChannelSpecifics,
        payload: notificationBody != null
            ? jsonEncode(notificationBody.toJson())
            : null);
  }

  static Future<String> _downloadAndSaveFile(
      String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  static NotificationBodyModel convertNotification(Map<String, dynamic> data) {
    if (data['type'] == 'advertisement') {
      return NotificationBodyModel(
          notificationType: NotificationType.advertisement,
          advertisementId: int.parse(data['advertisement_id']));
    } else if (data['type'] == 'new_order' ||
        data['type'] == 'New order placed' ||
        data['type'] == 'order_status') {
      return NotificationBodyModel(
          orderId: int.parse(data['order_id']),
          notificationType: NotificationType.order);
    } else if (data['type'] == 'message') {
      return NotificationBodyModel(
        orderId: (data['order_id'] != null && data['order_id'].isNotEmpty)
            ? int.parse(data['order_id'])
            : null,
        conversationId: (data['conversation_id'] != null &&
                data['conversation_id'].isNotEmpty)
            ? int.parse(data['conversation_id'])
            : null,
        notificationType: NotificationType.message,
        type: data['sender_type'] == UserType.delivery_man.name
            ? UserType.delivery_man.name
            : UserType.customer.name,
      );
    } else if (data['type'] == 'block') {
      return NotificationBodyModel(notificationType: NotificationType.block);
    } else if (data['type'] == 'unblock') {
      return NotificationBodyModel(notificationType: NotificationType.unblock);
    } else if (data['type'] == 'withdraw') {
      return NotificationBodyModel(notificationType: NotificationType.withdraw);
    } else if (data['type'] == 'campaign') {
      return NotificationBodyModel(
          notificationType: NotificationType.campaign,
          campaignId: int.parse(data['data_id']));
    } else {
      return NotificationBodyModel(notificationType: NotificationType.general);
    }
  }

  static Future<void> dismissForegroundNotificationForOrder(
      int? orderId) async {
    final bool stopped = await _stopForegroundIfMatches(orderId?.toString());
    if (!stopped) {
      await stopService();
    }
    try {
      await flutterLocalNotificationsPlugin.cancel(0);
      await flutterLocalNotificationsPlugin.cancelAll();
    } catch (e) {
      customPrint('notification cancel error: $e');
    }
  }
}

@pragma('vm:entry-point')
Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  customPrint("onBackground: ${message.data}");

  // Validate notification has required data before processing
  String? dataTitle = message.data['title'];
  String? dataBody = message.data['body'];
  String? notificationTitle = message.notification?.title;
  String? notificationBody = message.notification?.body;
  String? type = message.data['type'];

  // Skip if essential fields are missing
  if (type == null || type.isEmpty) {
    customPrint(
        "Skipping background notification with missing type. Data: ${message.data}");
    return;
  }

  // Check if notification has any content (title or body) in either payload
  bool hasTitle = (dataTitle != null && dataTitle.trim().isNotEmpty) ||
      (notificationTitle != null && notificationTitle.trim().isNotEmpty);
  bool hasBody = (dataBody != null && dataBody.trim().isNotEmpty) ||
      (notificationBody != null && notificationBody.trim().isNotEmpty);

  // Block completely empty notifications (no title AND no body)
  if (type != 'maintenance' && !hasTitle && !hasBody) {
    customPrint(
        "Blocking empty background notification (no title and no body). Data payload - Title: '$dataTitle', Body: '$dataBody'. Notification payload - Title: '$notificationTitle', Body: '$notificationBody'. Type: '$type'");
    return;
  }

  NotificationBodyModel notificationBodyModel =
      NotificationHelper.convertNotification(message.data);

  // Only start foreground service for actual new orders, not order status updates
  if (notificationBodyModel.notificationType == NotificationType.order &&
      (message.data['type'] == 'new_order' ||
          message.data['title'] == 'New order placed')) {
    FlutterForegroundTask.initCommunicationPort();

    _initService();

    await _startService(notificationBodyModel.orderId?.toString());
  } else {
    // Show notification if it has at least title or body (showNotification will handle further validation)
    NotificationHelper.showNotification(
        message, flutterLocalNotificationsPlugin);
  }
}

@pragma('vm:entry-point')
Future<ServiceRequestResult> _startService(String? orderId) async {
  ServiceRequestResult result;
  if (await FlutterForegroundTask.isRunningService) {
    result = await FlutterForegroundTask.restartService();
  } else {
    result = await FlutterForegroundTask.startService(
      serviceId: 256,
      notificationTitle: 'You got a new order ($orderId)',
      notificationText: 'Open app and check order details.',
      callback: startCallback,
      // notificationButtons: [
      //   const NotificationButton(id: '1', text: 'Open'),
      // ],
      // notificationInitialRoute: RouteHelper.getOrderDetailsRoute(int.parse(orderId!), fromNotification: true),
    );
  }
  await _persistForegroundOrderId(orderId);
  return result;
}

@pragma('vm:entry-point')
void _initService() {
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'stackfood',
      channelName: 'Foreground Service Notification',
      channelDescription:
          'This notification appears when the foreground service is running.',
      onlyAlertOnce: false,
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: false,
      playSound: false,
    ),
    foregroundTaskOptions: ForegroundTaskOptions(
      eventAction: ForegroundTaskEventAction.repeat(5000),
      autoRunOnBoot: false,
      autoRunOnMyPackageReplaced: false,
      allowWakeLock: true,
      allowWifiLock: true,
    ),
  );
}

@pragma('vm:entry-point')
Future<ServiceRequestResult> stopService() async {
  try {
    _audioPlayer.dispose();
  } catch (e) {
    customPrint('error-----$e');
  }
  await _persistForegroundOrderId(null);
  return FlutterForegroundTask.stopService();
}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

final AudioPlayer _audioPlayer = AudioPlayer();

class MyTaskHandler extends TaskHandler {
  void _playAudio() {
    _audioPlayer.play(AssetSource('notification.mp3'));
  }

  // Called when the task is started.
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    _playAudio();
  }

  // Called by eventAction in [ForegroundTaskOptions].
  // - nothing() : Not use onRepeatEvent callback.
  // - once() : Call onRepeatEvent only once.
  // - repeat(interval) : Call onRepeatEvent at milliseconds interval.
  @override
  void onRepeatEvent(DateTime timestamp) {
    _playAudio();
  }

  // Called when the task is destroyed.
  @override
  Future<void> onDestroy(DateTime timestamp) async {
    stopService();
  }

  // Called when data is sent using [FlutterForegroundTask.sendDataToTask].
  @override
  void onReceiveData(Object data) {
    _playAudio();
  }

  // Called when the notification button is pressed.
  @override
  void onNotificationButtonPressed(String id) {
    debugPrint('onNotificationButtonPressed: $id');
    if (id == '1') {
      FlutterForegroundTask.launchApp('/');
    }
    stopService();
  }

  // Called when the notification itself is pressed.
  //
  // AOS: "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted
  // for this function to be called.
  @override
  void onNotificationPressed() {
    debugPrint('onNotificationPressed');

    FlutterForegroundTask.launchApp('/');
    stopService();
  }

  // Called when the notification itself is dismissed.
  //
  // AOS: only work Android 14+
  // iOS: only work iOS 10+
  @override
  void onNotificationDismissed() {
    FlutterForegroundTask.updateService(
      notificationTitle: 'You got a new order!',
      notificationText: 'Open app and check order details.',
    );
  }
}
