import 'package:toto_partner/features/addon/domain/models/addon_category_model.dart';
import 'package:toto_partner/features/restaurant/domain/models/product_model.dart';
import 'package:toto_partner/interface/repository_interface.dart';

abstract class AddonRepositoryInterface<T>
    implements RepositoryInterface<AddOns> {
  Future<List<AddonCategoryModel>?> getAddonCategory({required int moduleId});
  Future<bool> updateAddon(AddOns addonModel);
}
