import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:toto_partner/common/widgets/custom_app_bar_widget.dart';
import 'package:toto_partner/common/widgets/custom_button_widget.dart';
import 'package:toto_partner/common/widgets/custom_image_widget.dart';
import 'package:toto_partner/common/widgets/custom_snackbar_widget.dart';
import 'package:toto_partner/common/widgets/custom_text_form_field_widget.dart';
import 'package:toto_partner/features/auth/controllers/auth_controller.dart';
import 'package:toto_partner/features/auth/widgets/pass_view_widget.dart';
import 'package:toto_partner/features/deliveryman/controllers/deliveryman_controller.dart';
import 'package:toto_partner/features/splash/controllers/splash_controller.dart';
import 'package:toto_partner/features/deliveryman/domain/models/delivery_man_model.dart';
import 'package:toto_partner/helper/custom_validator.dart';
import 'package:toto_partner/util/dimensions.dart';
import 'package:toto_partner/util/images.dart';
import 'package:toto_partner/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AddDeliveryManScreen extends StatefulWidget {
  final DeliveryManModel? deliveryMan;
  const AddDeliveryManScreen({super.key, required this.deliveryMan});

  @override
  State<AddDeliveryManScreen> createState() => _AddDeliveryManScreenState();
}

class _AddDeliveryManScreenState extends State<AddDeliveryManScreen> {
  final TextEditingController _fNameController = TextEditingController();
  final TextEditingController _lNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _identityNumberController =
      TextEditingController();
  final FocusNode _fNameNode = FocusNode();
  final FocusNode _lNameNode = FocusNode();
  final FocusNode _emailNode = FocusNode();
  final FocusNode _phoneNode = FocusNode();
  final FocusNode _passwordNode = FocusNode();
  final FocusNode _identityNumberNode = FocusNode();
  late bool _update;
  DeliveryManModel? _deliveryMan;
  String? _countryDialCode;

  @override
  void initState() {
    super.initState();

    _deliveryMan = widget.deliveryMan;
    _update = widget.deliveryMan != null;
    _countryDialCode = CountryCode.fromCountryCode(
            Get.find<SplashController>().configModel!.country!)
        .dialCode;
    Get.find<DeliveryManController>().pickImage(false, true);
    if (Get.find<AuthController>().showPassView) {
      Get.find<AuthController>().showHidePass();
    }

    if (_update) {
      _fNameController.text = _deliveryMan!.fName!;
      _lNameController.text = _deliveryMan!.lName!;
      _emailController.text = _deliveryMan!.email!;
      _phoneController.text = _deliveryMan!.phone!;
      _identityNumberController.text = _deliveryMan!.identityNumber!;
      Get.find<DeliveryManController>()
          .setIdentityTypeIndex(_deliveryMan!.identityType, false);
      _splitPhoneNumber(_deliveryMan!.phone!);
    } else {
      _deliveryMan = DeliveryManModel();
      Get.find<DeliveryManController>().setIdentityTypeIndex(
          Get.find<DeliveryManController>().identityTypeList[0], false);
      Get.find<DeliveryManController>().setIdentityTypeIndex(
          Get.find<DeliveryManController>().identityTypeList[0], false);
    }
  }

  void _splitPhoneNumber(String number) async {
    PhoneValid phoneNumber = await CustomValidator.isPhoneValid(number);
    setState(() {
      if (phoneNumber.countryCode.isNotEmpty) {
        _countryDialCode = '+${phoneNumber.countryCode}';
      } else {
        _countryDialCode = CountryCode.fromCountryCode(
                Get.find<SplashController>().configModel!.country!)
            .dialCode;
      }
      _phoneController.text =
          phoneNumber.phone.replaceFirst('+${phoneNumber.countryCode}', '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
          title: widget.deliveryMan != null
              ? 'update_delivery_man'.tr
              : 'add_delivery_man'.tr),
      body: GetBuilder<DeliveryManController>(builder: (dmController) {
        return GetBuilder<AuthController>(builder: (authController) {
          return Column(children: [
            Expanded(
                child: SingleChildScrollView(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              physics: const BouncingScrollPhysics(),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                        alignment: Alignment.center,
                        child: Text(
                          'delivery_man_image'.tr,
                          style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).hintColor),
                        )),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Align(
                        alignment: Alignment.center,
                        child: Stack(children: [
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusSmall),
                            child: dmController.pickedImage != null
                                ? GetPlatform.isWeb
                                    ? Image.network(
                                        dmController.pickedImage!.path,
                                        width: 150,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        File(dmController.pickedImage!.path),
                                        width: 150,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      )
                                : FadeInImage.assetNetwork(
                                    placeholder: Images.placeholder,
                                    image: _deliveryMan!.imageFullUrl ?? '',
                                    height: 120,
                                    width: 150,
                                    fit: BoxFit.cover,
                                    imageErrorBuilder: (c, o, s) => Image.asset(
                                        Images.placeholder,
                                        height: 120,
                                        width: 150,
                                        fit: BoxFit.cover),
                                  ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            top: 0,
                            left: 0,
                            child: InkWell(
                              onTap: () => dmController.pickImage(true, false),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall),
                                  border: Border.all(
                                      width: 1,
                                      color: Theme.of(context).primaryColor),
                                ),
                                child: Container(
                                  margin: const EdgeInsets.all(25),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 2, color: Colors.white),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.camera_alt,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ])),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                    Row(children: [
                      Expanded(
                          child: CustomTextFormFieldWidget(
                        hintText: 'first_name'.tr,
                        controller: _fNameController,
                        capitalization: TextCapitalization.words,
                        inputType: TextInputType.name,
                        focusNode: _fNameNode,
                        nextFocus: _lNameNode,
                      )),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(
                          child: CustomTextFormFieldWidget(
                        hintText: 'last_name'.tr,
                        controller: _lNameController,
                        capitalization: TextCapitalization.words,
                        inputType: TextInputType.name,
                        focusNode: _lNameNode,
                        nextFocus: _emailNode,
                      )),
                    ]),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                    CustomTextFormFieldWidget(
                      hintText: 'email'.tr,
                      controller: _emailController,
                      focusNode: _emailNode,
                      nextFocus: _phoneNode,
                      inputType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                    Row(children: [
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusSmall),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black12,
                                spreadRadius: 0,
                                blurRadius: 5)
                          ],
                        ),
                        child: CountryCodePicker(
                          dialogBackgroundColor: Theme.of(context).cardColor,
                          barrierColor: Colors.black12,
                          onChanged: (CountryCode countryCode) {
                            _countryDialCode = countryCode.dialCode;
                          },
                          initialSelection: _countryDialCode,
                          favorite: [_countryDialCode!],
                          showDropDownButton: true,
                          padding: EdgeInsets.zero,
                          showFlagMain: true,
                          flagWidth: 30,
                          textStyle: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(
                          flex: 1,
                          child: CustomTextFormFieldWidget(
                            hintText: 'phone'.tr,
                            controller: _phoneController,
                            focusNode: _phoneNode,
                            nextFocus: _passwordNode,
                            inputType: TextInputType.phone,
                            showTitle: false,
                          )),
                    ]),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                    CustomTextFormFieldWidget(
                      hintText: 'password'.tr,
                      controller: _passwordController,
                      focusNode: _passwordNode,
                      nextFocus: _identityNumberNode,
                      inputType: TextInputType.visiblePassword,
                      isPassword: true,
                      onChanged: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (!authController.showPassView) {
                            authController.showHidePass();
                          }
                          authController.validPassCheck(value);
                        } else {
                          if (authController.showPassView) {
                            authController.showHidePass();
                          }
                        }
                      },
                    ),
                    authController.showPassView
                        ? const PassViewWidget()
                        : const SizedBox(),
                    const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                    Row(children: [
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(
                              'identity_type'.tr,
                              style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context).hintColor),
                            ),
                            const SizedBox(
                                height: Dimensions.paddingSizeExtraSmall),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeSmall),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusSmall),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black12,
                                      spreadRadius: 0,
                                      blurRadius: 5)
                                ],
                              ),
                              child: DropdownButton<String>(
                                value: dmController.identityTypeList[
                                    dmController.identityTypeIndex],
                                items: dmController.identityTypeList
                                    .map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value.tr),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  dmController.setIdentityTypeIndex(
                                      value, true);
                                },
                                isExpanded: true,
                                underline: const SizedBox(),
                              ),
                            ),
                          ])),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(
                          child: CustomTextFormFieldWidget(
                        hintText: 'identity_number'.tr,
                        controller: _identityNumberController,
                        focusNode: _identityNumberNode,
                        inputAction: TextInputAction.done,
                      )),
                    ]),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                    _update
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Row(children: [
                                  Text(
                                    'identity_images'.tr,
                                    style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Theme.of(context).hintColor),
                                  ),
                                  const SizedBox(
                                      width: Dimensions.paddingSizeExtraSmall),
                                  Text(
                                    '(${'previously_added'.tr})',
                                    style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeExtraSmall,
                                        color: Theme.of(context).primaryColor),
                                  ),
                                ]),
                                const SizedBox(
                                    height: Dimensions.paddingSizeExtraSmall),
                                SizedBox(
                                  height: 120,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: _deliveryMan!
                                        .identityImageFullUrl!.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        margin: const EdgeInsets.only(
                                            right: Dimensions.paddingSizeSmall),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              width: 2),
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radiusSmall),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radiusSmall),
                                          child: CustomImageWidget(
                                            image: _deliveryMan!
                                                .identityImageFullUrl![index],
                                            width: 150,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(
                                    height: Dimensions.paddingSizeLarge),
                              ])
                        : const SizedBox(),
                    Text(
                      'identity_images'.tr,
                      style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).hintColor),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: dmController.pickedIdentities.length + 1,
                        itemBuilder: (context, index) {
                          XFile? file =
                              index == dmController.pickedIdentities.length
                                  ? null
                                  : dmController.pickedIdentities[index];
                          if (index == dmController.pickedIdentities.length) {
                            return InkWell(
                              onTap: () => dmController.pickImage(false, false),
                              child: Container(
                                height: 120,
                                width: 150,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall),
                                  border: Border.all(
                                      color: Theme.of(context).primaryColor,
                                      width: 2),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(
                                      Dimensions.paddingSizeDefault),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 2,
                                        color: Theme.of(context).primaryColor),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.camera_alt,
                                      color: Theme.of(context).primaryColor),
                                ),
                              ),
                            );
                          }
                          return Container(
                            margin: const EdgeInsets.only(
                                right: Dimensions.paddingSizeSmall),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Theme.of(context).primaryColor,
                                  width: 2),
                              borderRadius:
                                  BorderRadius.circular(Dimensions.radiusSmall),
                            ),
                            child: Stack(children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusSmall),
                                child: GetPlatform.isWeb
                                    ? Image.network(
                                        file!.path,
                                        width: 150,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        File(file!.path),
                                        width: 150,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: InkWell(
                                  onTap: () =>
                                      dmController.removeIdentityImage(index),
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                        Dimensions.paddingSizeSmall),
                                    child: Icon(Icons.delete_forever,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error),
                                  ),
                                ),
                              ),
                            ]),
                          );
                        },
                      ),
                    ),
                  ]),
            )),
            !dmController.isLoading
                ? CustomButtonWidget(
                    buttonText: _update ? 'update'.tr : 'add'.tr,
                    margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    height: 50,
                    onPressed: () => _addDeliveryMan(dmController),
                  )
                : const Center(child: CircularProgressIndicator()),
          ]);
        });
      }),
    );
  }

  void _addDeliveryMan(DeliveryManController dmController) async {
    String fName = _fNameController.text.trim();
    String lName = _lNameController.text.trim();
    String email = _emailController.text.trim();
    String phone = _phoneController.text.trim();
    String password = _passwordController.text.trim();
    String identityNumber = _identityNumberController.text.trim();

    String numberWithCountryCode = _countryDialCode! + phone;
    PhoneValid phoneValid =
        await CustomValidator.isPhoneValid(numberWithCountryCode);

    if (fName.isEmpty) {
      showCustomSnackBar('enter_delivery_man_first_name'.tr);
    } else if (lName.isEmpty) {
      showCustomSnackBar('enter_delivery_man_last_name'.tr);
    } else if (email.isEmpty) {
      showCustomSnackBar('enter_delivery_man_email_address'.tr);
    } else if (!GetUtils.isEmail(email)) {
      showCustomSnackBar('enter_a_valid_email_address'.tr);
    } else if (phone.isEmpty) {
      showCustomSnackBar('enter_delivery_man_phone_number'.tr);
    } else if (!phoneValid.isValid) {
      showCustomSnackBar('enter_a_valid_phone_number'.tr);
    } else if (!_update && password.isEmpty) {
      showCustomSnackBar('enter_password_for_delivery_man'.tr);
    } else if (!_update && password.length < 6) {
      showCustomSnackBar('password_should_be'.tr);
    } else if (identityNumber.isEmpty) {
      showCustomSnackBar('enter_delivery_man_identity_number'.tr);
    } else if (!_update && dmController.pickedImage == null) {
      showCustomSnackBar('upload_delivery_man_image'.tr);
    } else {
      _deliveryMan!.fName = fName;
      _deliveryMan!.lName = lName;
      _deliveryMan!.email = email;
      _deliveryMan!.phone = numberWithCountryCode;
      _deliveryMan!.identityType =
          dmController.identityTypeList[dmController.identityTypeIndex];
      _deliveryMan!.identityNumber = identityNumber;
      dmController.addDeliveryMan(
        _deliveryMan!,
        password,
        Get.find<AuthController>().getUserToken(),
        widget.deliveryMan == null,
      );
    }
  }
}
