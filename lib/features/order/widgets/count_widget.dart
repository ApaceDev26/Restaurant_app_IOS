import 'package:get/get.dart';
import 'package:toto_partner/util/dimensions.dart';
import 'package:toto_partner/util/styles.dart';
import 'package:flutter/material.dart';

class CountWidget extends StatelessWidget {
  final String title;
  final int? count;
  const CountWidget({super.key, required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Get.isDarkMode
              ? const Color(0xff171515)
              : const Color(0xffF5F5FF),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
        child: Column(children: [
          Text(count.toString(),
              style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeExtraLarge)),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Text(title,
              style:
                  robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
        ]),
      ),
    );
  }
}
