import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:toto_partner/common/widgets/custom_app_bar_widget.dart';
import 'package:toto_partner/common/widgets/custom_button_widget.dart';
import 'package:toto_partner/common/widgets/custom_snackbar_widget.dart';
import 'package:toto_partner/util/dimensions.dart';
import 'package:toto_partner/util/images.dart';
import 'package:toto_partner/util/styles.dart';

class SkylonItScreen extends StatelessWidget {
  static const String websiteUrl = 'https://skylon-it.com/';
  static const String facebookUrl = 'https://www.facebook.com/skylonit';
  static const String phonePrimary = '+8801743233833';
  static const String phoneSecondary = '+8801783197788';

  const SkylonItScreen({super.key});

  Future<void> _launchUri(String uri) async {
    if (await canLaunchUrlString(uri)) {
      await launchUrlString(uri, mode: LaunchMode.externalApplication);
    } else {
      showCustomSnackBar('${'can_not_launch'.tr} $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: CustomAppBarWidget(title: 'skylon_it'.tr),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset(Images.skylonItLogo, height: 56),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  Text('skylon_it_tagline'.tr,
                      style: robotoRegular.copyWith(
                          color: Theme.of(context).hintColor,
                          fontSize: Dimensions.fontSizeDefault)),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  Text('skylon_it_description'.tr,
                      style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault)),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            Text('contact_info'.tr,
                style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).hintColor)),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            _Card(
              child: Column(children: [
                _InfoTile(
                  icon: Icons.location_on_outlined,
                  title: 'address'.tr,
                  value: 'skylon_it_address'.tr,
                ),
                const Divider(),
                _InfoTile(
                  icon: Icons.phone_outlined,
                  title: 'phone'.tr,
                  value: '(+880)1743233833',
                  onCall: () => _launchUri('tel:$phonePrimary'),
                  onWhatsapp: () => _launchUri(
                      'https://wa.me/${phonePrimary.replaceAll('+', '')}'),
                ),
                const Divider(),
                _InfoTile(
                  icon: Icons.phone_outlined,
                  title: 'phone'.tr,
                  value: '(+880)1783197788',
                  onCall: () => _launchUri('tel:$phoneSecondary'),
                  onWhatsapp: () => _launchUri(
                      'https://wa.me/${phoneSecondary.replaceAll('+', '')}'),
                ),
                const Divider(),
                _InfoTile(
                  icon: Icons.email_outlined,
                  title: 'email'.tr,
                  value: 'skylonit@gmail.com',
                  onTap: () => _launchUri('mailto:skylonit@gmail.com'),
                ),
              ]),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            Text('services'.tr,
                style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).hintColor)),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            _Card(
              child: Column(children: [
                _ServiceRow(label: 'skylon_service_mobile'.tr),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                _ServiceRow(label: 'skylon_service_web'.tr),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                _ServiceRow(label: 'skylon_service_saas'.tr),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                _ServiceRow(label: 'skylon_service_pos'.tr),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                _ServiceRow(label: 'skylon_service_management'.tr),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                _ServiceRow(label: 'skylon_service_support'.tr),
              ]),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Row(children: [
            Expanded(
              child: CustomButtonWidget(
                buttonText: 'visit_website'.tr,
                icon: Icons.open_in_new_rounded,
                height: 44,
                onPressed: () => _launchUri(websiteUrl),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
              child: CustomButtonWidget(
                buttonText: 'facebook'.tr,
                icon: Icons.facebook,
                height: 44,
                color: const Color(0xFF1877F2),
                onPressed: () => _launchUri(facebookUrl),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(
            color: Theme.of(context).disabledColor.withValues(alpha: 0.2)),
      ),
      child: child,
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
    this.onCall,
    this.onWhatsapp,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;
  final VoidCallback? onCall;
  final VoidCallback? onWhatsapp;

  @override
  Widget build(BuildContext context) {
    final hasActions = onCall != null && onWhatsapp != null;
    return InkWell(
      onTap: hasActions ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: Theme.of(context).hintColor),
            const SizedBox(width: Dimensions.paddingSizeDefault),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).hintColor)),
                  const SizedBox(height: 4),
                  Text(value, style: robotoMedium),
                  if (hasActions) ...[
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Row(children: [
                      Expanded(
                        child: CustomButtonWidget(
                          buttonText: 'call'.tr,
                          icon: Icons.call_outlined,
                          height: 36,
                          transparent: true,
                          onPressed: onCall,
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(
                        child: CustomButtonWidget(
                          buttonText: 'whatsapp'.tr,
                          icon: Icons.chat,
                          height: 36,
                          color: const Color(0xFF25D366),
                          onPressed: onWhatsapp,
                        ),
                      ),
                    ]),
                  ],
                ],
              ),
            ),
            if (!hasActions && onTap != null)
              Icon(Icons.chevron_right_rounded,
                  color: Theme.of(context).hintColor),
          ],
        ),
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(Icons.check_circle_outline,
          size: 18, color: Theme.of(context).primaryColor),
      const SizedBox(width: Dimensions.paddingSizeDefault),
      Expanded(child: Text(label, style: robotoRegular)),
    ]);
  }
}
