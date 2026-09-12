import 'package:toto_partner/common/models/response_model.dart';
import 'package:toto_partner/features/payment/domain/models/bank_info_body_model.dart';
import 'package:toto_partner/features/payment/domain/models/earning_history_model.dart';
import 'package:toto_partner/features/payment/domain/models/wallet_payment_model.dart';
import 'package:toto_partner/features/payment/domain/models/widthdrow_method_model.dart';
import 'package:toto_partner/features/payment/domain/models/withdraw_model.dart';
import 'package:toto_partner/features/payment/domain/repositories/payment_repository_interface.dart';
import 'package:toto_partner/features/payment/domain/services/payment_service_interface.dart';

class PaymentService implements PaymentServiceInterface {
  final PaymentRepositoryInterface paymentRepositoryInterface;
  PaymentService({required this.paymentRepositoryInterface});

  @override
  Future<List<WithdrawModel>?> getWithdrawList() async {
    return await paymentRepositoryInterface.getList();
  }

  @override
  Future<bool> updateBankInfo(BankInfoBodyModel bankInfoBody) async {
    return await paymentRepositoryInterface.updateBankInfo(bankInfoBody);
  }

  @override
  Future<bool> requestWithdraw(Map<String?, String> data) async {
    return await paymentRepositoryInterface.requestWithdraw(data);
  }

  @override
  Future<List<WidthDrawMethodModel>?> getWithdrawMethodList() async {
    return await paymentRepositoryInterface.getWithdrawMethodList();
  }

  @override
  Future<ResponseModel> makeCollectCashPayment(
      double amount, String paymentGatewayName) async {
    return await paymentRepositoryInterface.makeCollectCashPayment(
        amount, paymentGatewayName);
  }

  @override
  Future<bool> makeWalletAdjustment() async {
    return await paymentRepositoryInterface.makeWalletAdjustment();
  }

  @override
  Future<List<Transactions>?> getWalletPaymentList() async {
    return await paymentRepositoryInterface.getWalletPaymentList();
  }

  @override
  Future<List<EarningHistory>?> getEarningHistory() async {
    return await paymentRepositoryInterface.getEarningHistory();
  }
}
