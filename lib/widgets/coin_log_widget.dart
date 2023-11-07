import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:project_june_client/services.dart';

import '../actions/transaction/models/CoinLog.dart';
import '../constants.dart';

class CoinLogWidget extends StatelessWidget {
  final CoinLog coinLog;

  const CoinLogWidget({Key? key, required this.coinLog}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorConstants.lightGray,
      child: Column(
        children: [
          ListTile(
            title: Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(
                coinLog.description,
              ),
            ),
            subtitle: Text(coinLog.created.toString().substring(2, 10)),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                        transactionService.currencyFormatter
                            .format(coinLog.amount)
                            .toString(),
                        style: TextStyle(
                          fontSize: 18,
                          color: ColorConstants.primary,
                        )),
                    Icon(
                      PhosphorIcons.coin_vertical,
                      color: ColorConstants.primary,
                      size: 18,
                    ),
                  ],
                ),
                SizedBox(height: 3),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      transactionService.currencyFormatter
                          .format(coinLog.balance)
                          .toString(),
                      style: TextStyle(
                          color: ColorConstants.neutral, fontSize: 14),
                    ),
                    Icon(
                      PhosphorIcons.coin_vertical,
                      color: ColorConstants.primary,
                      size: 14,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 28),
            height: 2,
            decoration: DottedDecoration(
              shape: Shape.line,
              linePosition: LinePosition.top,
              color: ColorConstants.neutral,
              dash: const [5, 5],
              strokeWidth: 1,
            ),
          ),
        ],
      ),
    );
  }
}
