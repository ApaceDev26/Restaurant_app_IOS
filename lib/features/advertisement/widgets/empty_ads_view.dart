import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toto_partner/common/widgets/custom_asset_image_widget.dart';
import 'package:toto_partner/common/widgets/custom_button_widget.dart';
import 'package:toto_partner/helper/route_helper.dart';
import 'package:toto_partner/util/dimensions.dart';
import 'package:toto_partner/util/images.dart';
import 'package:toto_partner/util/styles.dart';

class EmptyAdsView extends StatelessWidget {
  const EmptyAdsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: Get.height * 0.7,
        child: Column(children: [
          const CustomAssetImageWidget(
            image: Images.adsListImage,
            height: 70,
            width: 70,
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Text('advertisement_list'.tr,
              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Text(
            'uh_oh_You_didnt_created_any_advertisement_yet'.tr,
            textAlign: TextAlign.center,
            style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).hintColor),
          ),
          const SizedBox(height: Dimensions.paddingSizeOverLarge),
          CustomButtonWidget(
            margin: EdgeInsets.symmetric(horizontal: context.width * 0.2),
            buttonText: 'create_ads'.tr,
            onPressed: () {
              Get.toNamed(RouteHelper.getCreateAdvertisementRoute());
            },
          ),
          const SizedBox(height: Dimensions.paddingSizeOverLarge),
          const Divider(),
          const SizedBox(height: Dimensions.paddingSizeOverLarge),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeLarge),
            child: Text(
              'by_creating_advertisement'.tr,
              textAlign: TextAlign.center,
              style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).hintColor),
            ),
          ),
        ]),
      ),
    );
  }
}
