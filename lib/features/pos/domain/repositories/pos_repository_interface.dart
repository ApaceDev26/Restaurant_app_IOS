import 'package:toto_partner/interface/repository_interface.dart';

abstract class PosRepositoryInterface implements RepositoryInterface {
  Future<dynamic> searchProductList(String searchText);
  Future<dynamic> searchCustomerList(String searchText);
  Future<dynamic> placeOrder(String searchText);
  Future<dynamic> getPosOrders();
}
