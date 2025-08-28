import 'dart:async';
import 'dart:io';

import 'package:fast_ai/component/app_dialog.dart';
import 'package:fast_ai/component/f_loading.dart';
import 'package:fast_ai/component/f_toast.dart';
import 'package:fast_ai/data/order_data.dart';
import 'package:fast_ai/data/sku_data.dart';
import 'package:fast_ai/services/api.dart';
import 'package:fast_ai/services/app_log_event.dart';
import 'package:fast_ai/services/app_user.dart';
import 'package:fast_ai/values/app_values.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

import '../generated/locales.g.dart';
import '../services/app_service.dart';

enum IAPEvent { vipSucc, goldSucc }

class IAPTool {
  // 单例模式
  static final IAPTool _instance = IAPTool._internal();
  factory IAPTool() => _instance;
  IAPTool._internal() {
    _initIAP();
  }

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  Set<String> _consumableIds = {};
  Set<String> _subscriptionIds = {};

  List<SkuData> allList = [];
  List<SkuData> consumableList = [];
  List<SkuData> subscriptionList = [];

  VipFrom? _vipFrom;
  ConsumeFrom? _consFrom;
  OrderData? _orderData;

  bool _isUserBuy = false;
  SkuData? _currentSkuData;

  final RxInt _eventCounter = 0.obs;
  Rxn<(IAPEvent, String, int)> iapEvent = Rxn<(IAPEvent, String, int)>();

  // 初始化 IAP
  void _initIAP() {
    _subscription = _inAppPurchase.purchaseStream.listen(
      (purchaseDetailsList) => _processPurchaseDetails(purchaseDetailsList),
      onError: (error) => log.e('[iap] 购买监听错误: $error'),
    );
  }

  // 查询产品详情
  Future<void> query() async {
    // if (!consumableList.isNotEmpty && !subscriptionList.isNotEmpty) {
    //   return;
    // }

    if (!await _isAvailable()) return;
    // iOS 平台特定逻辑
    await _finishTransaction();

    // 请求服务器，拿到所有 SkuData 列表
    await _getSkuDatas();
    if (allList.isEmpty) {
      return;
    }
    // SkuData ids
    final skuDataIds = _consumableIds.union(_subscriptionIds);

    final response = await _inAppPurchase.queryProductDetails(skuDataIds);
    if (response.notFoundIDs.isNotEmpty) {
      log.e('[iap] notFoundIDs: ${response.notFoundIDs}');
    }

    for (final productDetails in response.productDetails) {
      final skuData = allList.firstWhereOrNull((e) => e.sku == productDetails.id);
      if (skuData != null) {
        skuData.productDetails = productDetails;
      }
    }

    // 根据 sku.orderNum 从小到大排序
    consumableList = allList.where((sku) => _consumableIds.contains(sku.sku)).toList()
      ..sort((a, b) => (a.orderNum ?? 0).compareTo(b.orderNum ?? 0));

    subscriptionList = allList.where((sku) => _subscriptionIds.contains(sku.sku)).toList()
      ..sort((a, b) => (a.orderNum ?? 0).compareTo(b.orderNum ?? 0));
  }

  Future<void> _getSkuDatas() async {
    log.d('[iap] _getSkuDatas');
    final list = await Api.getSkuList();
    allList = list ?? [];

    _consumableIds = allList
        .where((e) => e.skuType == 0 && e.shelf == true)
        .map((e) => e.sku ?? '')
        .toSet();
    _subscriptionIds = allList
        .where((e) => e.skuType != 0 && e.shelf == true)
        .map((e) => e.sku ?? '')
        .toSet();
    log.d('[iap] _consumableIds: $_consumableIds');
    log.d('[iap] _subscriptionIds: $_subscriptionIds');
  }

  // 购买产品
  Future<void> buy(SkuData data, {VipFrom? vipFrom, ConsumeFrom? consFrom}) async {
    try {
      FLoading.showLoading();
      if (!await _isAvailable()) return;
      await _finishTransaction();
      _vipFrom = vipFrom;
      _consFrom = consFrom;
      _isUserBuy = true;
      _currentSkuData = data;

      final productDetails = data.productDetails;
      if (productDetails == null) {
        FLoading.dismiss();
        log.e('[iap] buy productDetails is null');
        FToast.toast('So sorry, ProductDetails is null.');
        return;
      }

      await _createOrder(productDetails);

      String? orderNo = _orderData?.orderNo;
      if (orderNo == null || orderNo.isEmpty) {
        FLoading.dismiss();
        FToast.toast(LocaleKeys.create_order_error.tr);
        return;
      }

      final purchaseParam = PurchaseParam(
        productDetails: productDetails,
        applicationUserName: orderNo,
      );

      final isConsumable = data.skuType == 0;

      await (isConsumable
          ? _inAppPurchase.buyConsumable(purchaseParam: purchaseParam)
          : _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam));
    } catch (e) {
      await FLoading.dismiss();
      FToast.toast(e.toString());
      log.e('[iap] catch: $e');
    }
  }

  // 恢复购买
  Future<void> restore({bool isNeedShowLoading = true}) async {
    if (!await _isAvailable()) return;

    log.d('[iap] restore.....');
    _isUserBuy = true;
    await _inAppPurchase.restorePurchases();
  }

  // 处理购买详情
  Future<void> _processPurchaseDetails(List<PurchaseDetails> purchaseDetailsList) async {
    if (purchaseDetailsList.isEmpty) return;

    // 按交易日期降序排序
    purchaseDetailsList.sort(
      (a, b) => (int.tryParse(b.transactionDate ?? '0') ?? 0).compareTo(
        int.tryParse(a.transactionDate ?? '0') ?? 0,
      ),
    );

    final first = purchaseDetailsList.first;

    for (var purchaseDetails in purchaseDetailsList) {
      switch (purchaseDetails.status) {
        case PurchaseStatus.purchased:
          if (first.purchaseID == purchaseDetails.purchaseID ||
              _currentSkuData?.sku == purchaseDetails.purchaseID) {
            await _handleSuccessfulPurchase(purchaseDetails);
          }
          break;
        case PurchaseStatus.restored:
          await _handleSuccessfulPurchase(purchaseDetails);
          break;

        case PurchaseStatus.error:
        case PurchaseStatus.canceled:
          _handlePurchaseError(purchaseDetails);
          break;

        case PurchaseStatus.pending:
          FLoading.showLoading();
          break;
      }

      // 处理挂起的交易
      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
        log.d('[iap] 完成挂起的交易: ${purchaseDetails.productID}');
      }
    }
  }

  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) async {
    log.d(' 购买成功 status: ${purchaseDetails.status}');
    log.d(' 购买成功 pendingCompletePurchase: ${purchaseDetails.pendingCompletePurchase}');
    log.d(
      '[iap] 成功购买: ${purchaseDetails.productID}, ${purchaseDetails.purchaseID}, ${purchaseDetails.transactionDate}',
    );
    if (!_isUserBuy) {
      log.d('[iap] 自动购买, 不需要处理');
      return;
    }

    // if (await _isPurchaseProcessed(purchaseDetails.purchaseID)) return;

    if (await _verifyAndCompletePurchase(purchaseDetails)) {
      await _markPurchaseAsProcessed(purchaseDetails.purchaseID);
    } else {
      log.e('[iap] 验证失败: ${purchaseDetails.productID}');
    }
    _isUserBuy = false;
    _currentSkuData = null;
    await _inAppPurchase.completePurchase(purchaseDetails);
  }

  void _handlePurchaseError(PurchaseDetails purchaseDetails) {
    final error = purchaseDetails.error;
    _handleError(
      IAPError(
        source: error?.source ?? '',
        code: error?.code ?? '',
        message: purchaseDetails.status.name,
      ),
    );
  }

  Future<bool> _verifyAndCompletePurchase(PurchaseDetails purchaseDetails) async {
    bool isValid = await verifyPurchaseWithServer(purchaseDetails);
    FLoading.dismiss();
    if (isValid) {
      _reportPurchase(purchaseDetails);
      AppUser().getUserInfo();
    }
    return isValid;
  }

  Future<bool> verifyPurchaseWithServer(PurchaseDetails purchaseDetails) async {
    if (Platform.isIOS) return await _verifyApple(purchaseDetails);
    if (Platform.isAndroid) return await _verifyGoogle(purchaseDetails);
    return false;
  }

  Future<bool> _verifyApple(PurchaseDetails purchaseDetails) async {
    try {
      final purchaseID = purchaseDetails.purchaseID;
      final transactionDate = purchaseDetails.transactionDate;
      final productID = purchaseDetails.productID;
      log.d('[iap] purchaseID: $purchaseID, transactionDate:$transactionDate');

      final receipt = purchaseDetails.verificationData.serverVerificationData;
      final localVerificationData = purchaseDetails.verificationData.localVerificationData;
      log.d('[iap] receipt: $receipt');
      log.d('[iap] localVerificationData: $localVerificationData');

      var createImg = (_consFrom == ConsumeFrom.aiphoto || _consFrom == ConsumeFrom.undr)
          ? true
          : null;
      var createVideo = _consFrom == ConsumeFrom.img2v ? true : null;

      var result = await Api.verifyIosOrder(
        receipt: receipt,
        skuId: productID,
        transactionId: purchaseID,
        purchaseDate: transactionDate,
        orderId: _orderData?.id ?? 0,
        createImg: createImg,
        createVideo: createVideo,
      );
      return result;
    } catch (e) {
      _handleError(IAPError(source: '', code: '400', message: e.toString()));
      return false;
    } finally {
      _orderData = null;
    }
  }

  Future<bool> _verifyGoogle(PurchaseDetails purchaseDetails) async {
    try {
      var createImg = (_consFrom == ConsumeFrom.aiphoto || _consFrom == ConsumeFrom.undr)
          ? true
          : null;
      var createVideo = _consFrom == ConsumeFrom.img2v ? true : null;

      final googleDetail = purchaseDetails as GooglePlayPurchaseDetails;
      final result = await Api.verifyAndOrder(
        originalJson: googleDetail.billingClientPurchase.originalJson,
        purchaseToken: googleDetail.billingClientPurchase.purchaseToken,
        skuId: purchaseDetails.productID,
        orderType: _subscriptionIds.contains(purchaseDetails.productID) ? 'SUBSCRIPTION' : 'GEMS',
        orderId: _orderData?.orderNo ?? '',
        createImg: createImg,
        createVideo: createVideo,
      );

      _orderData = null;
      return result;
    } catch (e) {
      _handleError(IAPError(source: '', code: '400', message: e.toString()));
      return false;
    }
  }

  Future<void> _createOrder(ProductDetails productDetails) async {
    final orderType = _consumableIds.contains(productDetails.id) ? 'GEMS' : 'SUBSCRIPTION';

    if (Platform.isIOS) {
      try {
        final order = await Api.makeIosOrder(orderType: orderType, skuId: productDetails.id);
        if (order == null || order.id == null) throw Exception('Creat order error');
        _orderData = order;
      } catch (e) {
        FToast.toast('${LocaleKeys.create_order_error.tr} $e');
        rethrow;
      }
    }
    if (Platform.isAndroid) {
      try {
        final order = await Api.makeAndOrder(orderType: orderType, skuId: productDetails.id);
        if (order == null || order.orderNo == null) throw Exception('Creat order error');

        _orderData = order;
      } catch (e) {
        FToast.toast('${LocaleKeys.create_order_error.tr} $e');
        rethrow;
      }
    }
  }

  Future _finishTransaction() async {
    // iOS 平台特定逻辑
    if (Platform.isIOS) {
      final iosPlatformAddition = _inAppPurchase
          .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());

      // 清理挂起的交易
      final transactions = await SKPaymentQueueWrapper().transactions();
      for (var transaction in transactions) {
        await SKPaymentQueueWrapper().finishTransaction(transaction);
      }
    }
  }

  // 工具方法：标记购买为已处理
  Future<void> _markPurchaseAsProcessed(String? purchaseID) async {
    if (purchaseID != null) await _storage.write(key: purchaseID, value: 'processed');
  }

  Future<bool> _isPurchaseProcessed(String? purchaseID) async {
    if (purchaseID == null) return false;
    final value = await _storage.read(key: purchaseID);
    return value == 'processed';
  }

  Future<bool> _isAvailable() async {
    final isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      await FLoading.showLoading();
      FToast.toast(LocaleKeys.iap_not_support.tr);
    }
    return isAvailable;
  }

  void _reportPurchase(PurchaseDetails purchaseDetails) {
    log.d('[iap] 上报购买事件: ${purchaseDetails.productID}');
    final id = purchaseDetails.productID;
    var path = '';
    var from = '';
    _eventCounter.value++;

    if (_consumableIds.contains(id)) {
      path = 'gems';
      from = _consFrom?.name ?? '';
      logEvent('suc_gems');
      final name = 'suc_${path}_${id}_$from';
      log.d('[iap] report: $name');
      logEvent(name);
      if (_consFrom != ConsumeFrom.undr &&
          _consFrom != ConsumeFrom.creaimg &&
          _consFrom != ConsumeFrom.creavideo &&
          _consFrom != ConsumeFrom.aiphoto &&
          _consFrom != ConsumeFrom.img2v) {
        _showRechargeSuccess(id);
      }
      iapEvent.value = (IAPEvent.goldSucc, id, _eventCounter.value);
    } else {
      path = 'sub';
      from = _vipFrom?.name ?? '';
      logEvent('suc_sub');
      final name = 'suc_${path}_${id}_$from';
      log.d('[iap] report: $name');
      logEvent(name);
      _handleVipSuccess();
      iapEvent.value = (IAPEvent.vipSucc, id, _eventCounter.value);
    }
  }

  void _handleVipSuccess() {
    if (_vipFrom == VipFrom.dailyrd) {
      _dailyrdSubSuccess();
    } else {
      Get.back();
    }
  }

  void _dailyrdSubSuccess() async {
    FLoading.showLoading();
    await Api.getDailyReward();
    await AppUser().getUserInfo();
    FLoading.dismiss();

    AppDialog.dismiss();
    Get.back();
  }

  void _showRechargeSuccess(String productID) {
    logEvent('t_suc_gems');

    final number = _currentSkuData?.number ?? 0;
    AppDialog.showRechargeSuccess(number);
  }

  void _handleError(IAPError error) {
    FLoading.dismiss();
    log.e('[iap] 错误: ${error.message}');
    FToast.toast(error.message);
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}

/// Example implementation of the
/// [`SKPaymentQueueDelegate`](https://developer.apple.com/documentation/storekit/skpaymentqueuedelegate?language=objc).
///
/// The payment queue delegate can be implementated to provide information
/// needed to complete transactions.
class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
    SKPaymentTransactionWrapper transaction,
    SKStorefrontWrapper storefront,
  ) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
