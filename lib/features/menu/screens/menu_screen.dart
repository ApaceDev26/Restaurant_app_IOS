import 'package:toto_partner/common/widgets/custom_app_bar_widget.dart';
import 'package:toto_partner/features/profile/controllers/profile_controller.dart';
import 'package:toto_partner/features/profile/domain/models/employed_permission_model.dart';
import 'package:toto_partner/features/profile/domain/models/profile_model.dart';
import 'package:toto_partner/features/splash/controllers/splash_controller.dart';
import 'package:toto_partner/features/menu/domain/models/menu_model.dart';
import 'package:toto_partner/features/menu/widgets/menu_button_widget.dart';
import 'package:toto_partner/helper/route_helper.dart';
import 'package:toto_partner/util/dimensions.dart';
import 'package:toto_partner/util/images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Restaurant? restaurant = Get.find<ProfileController>().profileModel != null
        ? Get.find<ProfileController>().profileModel!.restaurants![0]
        : null;

    ModulePermissionModel? modulePermission =
        Get.find<ProfileController>().modulePermission;

    final List<MenuModel> menuList = [];

    menuList.add(MenuModel(
        icon: '', title: 'profile'.tr, route: RouteHelper.getProfileRoute()));

    if (modulePermission!.food!) {
      menuList.add(MenuModel(
        icon: Images.addFood,
        title: 'all_food'.tr,
        route: RouteHelper.getAllProductsRoute(),
        isBlocked: !Get.find<ProfileController>()
            .profileModel!
            .restaurants![0]
            .foodSection!,
      ));
    }

    if (modulePermission.campaign!) {
      menuList.add(MenuModel(
          icon: Images.campaign,
          title: 'campaign'.tr,
          route: RouteHelper.getCampaignRoute()));
    }

    if (modulePermission.restaurantConfig!) {
      menuList.add(MenuModel(
          icon: Images.settingIcon,
          title: 'restaurant_config'.tr,
          route: RouteHelper.getRestaurantSettingRoute(restaurant)));
    }

    if (restaurant?.selfDeliverySystem == 1) {
      menuList.add(MenuModel(
        icon: Images.deliveryMan,
        iconColor: Colors.white,
        title: 'delivery_man'.tr,
        route: RouteHelper.getDeliveryManRoute(),
      ));
    }

    if (modulePermission.adsList!) {
      menuList.add(MenuModel(
          icon: Images.adsMenu,
          title: 'advertisements'.tr,
          route: RouteHelper.getAdvertisementListRoute()));
    }

    if (modulePermission.addon!) {
      menuList.add(MenuModel(
          icon: Images.addon,
          title: 'addons'.tr,
          route: RouteHelper.getAddonsRoute()));
    }

    if (modulePermission.category!) {
      menuList.add(MenuModel(
          icon: Images.categories,
          title: 'categories'.tr,
          route: RouteHelper.getCategoriesRoute()));
    }

    if (modulePermission.coupon!) {
      menuList.add(MenuModel(
          icon: Images.coupon,
          title: 'coupon'.tr,
          route: RouteHelper.getCouponRoute()));
    }

    if (modulePermission.businessPlan!) {
      menuList.add(MenuModel(
          icon: Images.subscription,
          iconColor: Colors.white,
          title: 'my_business_plan'.tr,
          route: RouteHelper.getMySubscriptionRoute()));
    }

    if (modulePermission.reviews!) {
      menuList.add(MenuModel(
          icon: Images.review,
          title: 'reviews'.tr,
          route: RouteHelper.getCustomerReviewRoute()));
    }

    if (modulePermission.expenseReport! ||
        modulePermission.transaction! ||
        modulePermission.orderReport! ||
        modulePermission.foodReport! ||
        modulePermission.taxReport!) {
      menuList.add(MenuModel(
          icon: Images.reportsIcon,
          title: 'reports'.tr,
          route: RouteHelper.getReportsRoute()));
    }

    if (modulePermission.disbursement!) {
      if (Get.find<SplashController>().configModel!.disbursementType ==
          'automated') {
        menuList.add(MenuModel(
            icon: Images.disbursementIcon,
            title: 'disbursement'.tr,
            route: RouteHelper.getDisbursementRoute()));
      }
    }

    if (modulePermission.walletMethod!) {
      menuList.add(MenuModel(
          icon: Images.walletMethodIcon,
          title: 'wallet_method'.tr,
          route: RouteHelper.getWithdrawMethodRoute()));
    }

    menuList.add(MenuModel(
        icon: Images.language,
        title: 'language'.tr,
        route: '',
        isLanguage: true));

    if (modulePermission.chat!) {
      menuList.add(
        MenuModel(
          icon: Images.chat,
          title: 'conversation'.tr,
          route: RouteHelper.getConversationListRoute(),
          isNotSubscribe: (Get.find<ProfileController>()
                      .profileModel!
                      .restaurants![0]
                      .restaurantModel ==
                  'subscription' &&
              Get.find<ProfileController>().profileModel!.subscription !=
                  null &&
              Get.find<ProfileController>().profileModel!.subscription!.chat ==
                  0),
        ),
      );
    }
    menuList.add(MenuModel(
        icon: Images.chatIcon,
        title: 'Help & Support',
        route: RouteHelper.getHelpSupportRoute()));

    menuList.add(MenuModel(
        icon: Images.policy,
        title: 'privacy_policy'.tr,
        route: RouteHelper.getPrivacyRoute()));

    menuList.add(MenuModel(
        icon: Images.terms,
        title: 'terms_condition'.tr,
        route: RouteHelper.getTermsRoute()));

    // menuList.add(MenuModel(
    //     icon: Images.skylonItLogo,
    //     title: 'skylon_it'.tr,
    //     route: RouteHelper.getSkylonItRoute()));

    menuList.add(MenuModel(icon: Images.logOut, title: 'logout'.tr, route: ''));

    return Scaffold(
      appBar: CustomAppBarWidget(title: 'Menu'.tr, isBackButtonExist: false),
      backgroundColor: Theme.of(context).cardColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(children: [
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: menuList.length,
            itemBuilder: (context, index) {
              return MenuButtonWidget(
                  menu: menuList[index],
                  isProfile: index == 0,
                  isLogout: index == menuList.length - 1);
            },
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
        ]),
      ),
    );
  }
}
