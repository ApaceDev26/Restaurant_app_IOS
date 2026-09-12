import 'package:toto_partner/common/widgets/confirmation_dialog_widget.dart';
import 'package:toto_partner/common/widgets/custom_asset_image_widget.dart';
import 'package:toto_partner/common/widgets/custom_snackbar_widget.dart';
import 'package:toto_partner/features/auth/controllers/auth_controller.dart';
import 'package:toto_partner/features/language/controllers/localization_controller.dart';
import 'package:toto_partner/features/language/widgets/language_bottom_sheet_widget.dart';
import 'package:toto_partner/features/menu/domain/models/menu_model.dart';
import 'package:toto_partner/features/menu/widgets/profile_image_widget.dart';
import 'package:toto_partner/features/profile/controllers/profile_controller.dart';
import 'package:toto_partner/features/subscription/controllers/subscription_controller.dart';
import 'package:toto_partner/helper/route_helper.dart';
import 'package:toto_partner/util/app_constants.dart';
import 'package:toto_partner/util/dimensions.dart';
import 'package:toto_partner/util/images.dart';
import 'package:toto_partner/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MenuButtonWidget extends StatelessWidget {
  final MenuModel menu;
  final bool isProfile;
  final bool isLogout;
  const MenuButtonWidget(
      {super.key,
      required this.menu,
      required this.isProfile,
      required this.isLogout});

  @override
  Widget build(BuildContext context) {
    double iconSize = 50.0; // Fixed size for ListView layout

    return Container(
      margin: const EdgeInsets.symmetric(
          vertical: Dimensions.paddingSizeExtraSmall),
      child: InkWell(
        onTap: !AppConstants.onTapon
            ? null
            : () async {
                if (menu.isBlocked) {
                  showCustomSnackBar('this_feature_is_blocked_by_admin'.tr);
                } else if (menu.isNotSubscribe) {
                  showCustomSnackBar('you_have_no_available_subscription'.tr);
                } else if (menu.isLanguage) {
                  Get.back();
                  _manageLanguageFunctionality();
                } else {
                  if (isLogout) {
                    Get.back();
                    if (Get.find<AuthController>().isLoggedIn()) {
                      Get.dialog(
                          ConfirmationDialogWidget(
                              icon: Images.support,
                              description: 'are_you_sure_to_logout'.tr,
                              isLogOut: true,
                              onYesPressed: () async {
                                Get.find<AuthController>().clearSharedData();
                                await Get.find<ProfileController>()
                                    .trialWidgetShow(
                                        route: RouteHelper.payment);
                                Get.offAllNamed(RouteHelper.getSignInRoute());
                              }),
                          useSafeArea: false);
                    } else {
                      await Get.find<ProfileController>()
                          .trialWidgetShow(route: RouteHelper.payment);
                      Get.find<AuthController>().clearSharedData();
                      Get.toNamed(RouteHelper.getSignInRoute());
                    }
                  } else {
                    if (menu.route.contains(RouteHelper.mySubscription)) {
                      Get.toNamed(menu.route);
                    } else {
                      if (!Get.find<SubscriptionController>()
                          .isTrialEndModalShown) {
                        Get.find<SubscriptionController>()
                            .trialEndBottomSheet()
                            .then((trialEnd) {
                          if (trialEnd) {
                            Get.toNamed(menu.route);
                          } else {
                            Get.find<SubscriptionController>()
                                .setTrialEndModalShown(true);
                          }
                        });
                      } else {
                        Get.toNamed(menu.route);
                      }
                    }
                  }
                }
              },
        child: Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            color: Theme.of(context).cardColor,
            boxShadow: const [
              BoxShadow(color: Colors.black12, spreadRadius: 0, blurRadius: 5)
            ],
          ),
          child: Row(children: [
            Container(
              height: iconSize,
              width: iconSize,
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                color: isLogout
                    ? Get.find<AuthController>().isLoggedIn()
                        ? Theme.of(context).colorScheme.error
                        : Colors.green
                    : Theme.of(context).primaryColor,
              ),
              alignment: Alignment.center,
              child: isProfile
                  ? ProfileImageWidget(size: iconSize * 0.6)
                  : CustomAssetImageWidget(
                      image: menu.icon,
                      width: iconSize * 0.6,
                      height: iconSize * 0.6,
                      color: menu.iconColor,
                      fit: BoxFit.contain),
            ),
            const SizedBox(width: Dimensions.paddingSizeDefault),
            Expanded(
              child: Text(menu.title,
                  style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault),
                  textAlign: TextAlign.start),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: Dimensions.fontSizeDefault, color: Colors.grey),
          ]),
        ),
      ),
    );
  }

  _manageLanguageFunctionality() {
    Get.find<LocalizationController>().saveCacheLanguage(null);
    Get.find<LocalizationController>().searchSelectedLanguage();

    showModalBottomSheet(
      isScrollControlled: true,
      useRootNavigator: true,
      context: Get.context!,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Dimensions.radiusExtraLarge),
            topRight: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      builder: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: const LanguageBottomSheetWidget(),
        );
      },
    ).then((value) => Get.find<LocalizationController>().setLanguage(
        Get.find<LocalizationController>().getCacheLocaleFromSharedPref()));
  }
}
