import 'dart:io';

import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:intl/intl.dart';

import '../actions/transaction/queries.dart';

enum PurchaseState { coin, point, both, impossible }

class TransactionService {
  bool purchaseUpdatedListener(BuildContext context,
      PurchaseDetails purchaseDetails, InAppPurchase inAppPurchase) {
    if (purchaseDetails.status == PurchaseStatus.pending) {
      _handlePendingTransaction(context, purchaseDetails);
      return true;
    } else {
      if (purchaseDetails.status == PurchaseStatus.error ||
          purchaseDetails.status == PurchaseStatus.canceled) {
        _handleErrorTransaction(context, purchaseDetails, inAppPurchase);
      }
      else if (purchaseDetails.status == PurchaseStatus.purchased) {
        _handlePurchasedTransaction(context, purchaseDetails, inAppPurchase);
      }
      return false;
    }
  }

  final currencyFormatter = NumberFormat.currency(decimalDigits: 0, name: '');

  void _handlePendingTransaction(
      BuildContext context, PurchaseDetails purchaseDetails) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '잠시만 기다려주세요...',
        ),
      ),
    );
  }

  void _handleErrorTransaction(BuildContext context,
      PurchaseDetails purchaseDetails, InAppPurchase inAppPurchase) {
    inAppPurchase.completePurchase(purchaseDetails);
    handleNewTransaction();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '결제 도중 에러가 발생했어요. 에러가 계속되면 고객센터로 문의주세요.',
        ),
      ),
    );
  }

  void _handlePurchasedTransaction(BuildContext context,
      PurchaseDetails purchaseDetails, InAppPurchase inAppPurchase) {
    verifyPurchaseMutation(
      onSuccess: (res, arg) {
        inAppPurchase.completePurchase(purchaseDetails);
        handleNewTransaction();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '결제가 완료되었어요.',
            ),
          ),
        );
      },
    ).mutate(purchaseDetails);
  }

  PurchaseParam setPurchaseParam(ProductDetails productDetails) {
    if (Platform.isAndroid) {
      return GooglePlayPurchaseParam(
        productDetails: productDetails,
      );
    } else {
      return PurchaseParam(
        productDetails: productDetails,
      );
    }
  }

  void initiatePurchase(
      ProductDetails productDetails, InAppPurchase inAppPurchase) async {
    final purchaseParam = setPurchaseParam(productDetails);
    if (kProductIds.contains(productDetails.id)) {
      inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
    } else {
      // 애초에 build 되지 않아서 사용되지 않는 로직.
      inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    }
  }

  void handleNewTransaction() {
    CachedQuery.instance.refetchQueries(keys: ["retrieve-me", "coin-logs"]);
  }

  Map<String, dynamic> productDetailsToJson(ProductDetails details) {
    return {
      'id': details.id,
      'title': details.title,
      'description': details.description,
      'price': details.price,
      'currencyCode': details.currencyCode,
      'rawPrice': details.rawPrice,
    };
  }

  List<ProductDetails> productListFromJson(List<Map<String, dynamic>> json) {
    final defaultProductList = json
        .map((e) => ProductDetails(
              id: e['id'],
              title: e['title'],
              description: e['description'],
              price: e['price'],
              currencyCode: e['currencyCode'],
              rawPrice: e['rawPrice'],
            ))
        .toList();
    defaultProductList.sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
    return defaultProductList;
  }

  PurchaseState getPurchaseState(
      int coin, int point, int coinPrice, int pointPrice) {
    if (coin >= coinPrice && point >= pointPrice) {
      return PurchaseState.both;
    } else if (coin >= coinPrice && point < pointPrice) {
      return PurchaseState.coin;
    } else if (coin < coinPrice && point >= pointPrice) {
      return PurchaseState.point;
    } else {
      return PurchaseState.impossible;
    }
  }

  String getPurchaseStateText(String userPayment) {
    return userPayment == 'coin' ? '50코인을 사용했어요!' : '100포인트를 사용했어요!';
  }
}
