import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:toto_partner/common/widgets/custom_dropdown_widget.dart';
import 'package:toto_partner/features/auth/controllers/location_controller.dart';
import 'package:toto_partner/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ZoneSelectionWidget extends StatelessWidget {
  final List<DropdownItem<int>> zoneList;
  final GoogleMapController? mapController;
  final ValueChanged<int?>? onZoneSelected;
  const ZoneSelectionWidget({
    super.key,
    required this.zoneList,
    this.mapController,
    this.onZoneSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocationController>(builder: (locationController) {
      return locationController.zoneList != null
          ? locationController.zoneList!.isNotEmpty
              ? Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusDefault),
                    color: Theme.of(context).cardColor,
                    border: Border.all(
                        color:
                            Theme.of(context).hintColor.withValues(alpha: 0.5)),
                  ),
                  child: CustomDropdownWidget<int>(
                    onChange: (int? value, int index) {
                      locationController.setZoneIndex(
                        value,
                        mapController: mapController,
                      );
                      onZoneSelected?.call(value);
                    },
                    dropdownButtonStyle: DropdownButtonStyle(
                      height: 45,
                      padding: const EdgeInsets.symmetric(
                        vertical: Dimensions.paddingSizeExtraSmall,
                        horizontal: Dimensions.paddingSizeExtraSmall,
                      ),
                      primaryColor:
                          Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                    iconColor: Theme.of(context).hintColor,
                    dropdownStyle: DropdownStyle(
                      elevation: 10,
                      color: Theme.of(context).cardColor,
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusDefault),
                      padding: const EdgeInsets.all(
                          Dimensions.paddingSizeExtraSmall),
                    ),
                    items: zoneList,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        locationController.selectedZoneIndex != null &&
                                locationController.selectedZoneIndex != -1
                            ? '${locationController.zoneList![locationController.selectedZoneIndex!].name}'
                            : 'select_zone'.tr,
                      ),
                    ),
                  ),
                )
              : Container(
                  height: 45,
                  width: context.width,
                  decoration: BoxDecoration(
                    color: Theme.of(context).shadowColor,
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusDefault),
                    border: Border.all(
                        color:
                            Theme.of(context).hintColor.withValues(alpha: 0.5)),
                  ),
                  child: Center(
                      child: Text('service_not_available_in_this_area'.tr)),
                )
          : Shimmer(
              child: Container(
                height: 45,
                width: context.width,
                decoration: BoxDecoration(
                  color: Theme.of(context).shadowColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
              ),
            );
    });
  }
}
