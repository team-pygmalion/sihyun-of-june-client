import 'dart:io';

import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:intl/intl.dart';

import '../actions/transaction/queries.dart';

class TransactionService {
  void purchaseUpdatedListener(BuildContext context,
      PurchaseDetails purchaseDetails, InAppPurchase inAppPurchase) {
    if (purchaseDetails.status == PurchaseStatus.pending) {
      _handlePendingTransaction(context, purchaseDetails);
    } else if (purchaseDetails.status == PurchaseStatus.error ||
        purchaseDetails.status == PurchaseStatus.canceled) {
      _handleErrorTransaction(context, purchaseDetails, inAppPurchase);
    } else if (purchaseDetails.status == PurchaseStatus.purchased) {
      _handlePurchasedTransaction(context, purchaseDetails, inAppPurchase);
    }
  }

  var currencyFormatter = NumberFormat.currency(decimalDigits: 0, name: '');

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
    late PurchaseParam purchaseParam =
        PurchaseParam(productDetails: productDetails);
    if (Platform.isAndroid) {
      return purchaseParam = GooglePlayPurchaseParam(
        productDetails: productDetails,
      );
    } else {
      return purchaseParam = PurchaseParam(
        productDetails: productDetails,
      );
    }
  }

  void initiatePurchase(ProductDetails productDetails,
      InAppPurchase inAppPurchase, List<String> kProductIds) async {
    var purchaseParam = setPurchaseParam(productDetails);
    if (kProductIds.contains(productDetails.id)) {
      inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
    } else {
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
    return json
        .map((e) => ProductDetails(
              id: e['id'],
              title: e['title'],
              description: e['description'],
              price: e['price'],
              currencyCode: e['currencyCode'],
              rawPrice: e['rawPrice'],
            ))
        .toList();
  }
}
