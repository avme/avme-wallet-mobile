// @dart=2.12
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';

import '../../../../../controller/size_config.dart';
import '../../../../../lib/utils.dart';
import '../../button.dart';
import '../../neon_button.dart';
import '../../popup.dart';
import '../../textform.dart';

Future<bool> requestApproveTransaction(BuildContext context,
  String origin,
  {
    bool unlocked = false,
    required EtherAmount gasLimit,
    required EtherAmount gasPrice,
    required EtherAmount fee,
    required EtherAmount valueAmount,
  }) async {
  Completer<bool> askForTransaction = Completer();
  showDialog(
    context: context, builder: (BuildContext context) {
    return AppPopupWidget(
      title: "Warning",
      cancelable: false,
      canClose: unlocked,
      actions: [
        AppNeonButton(
          expanded: false,
          onPressed: () {
            askForTransaction.complete(false);
            Navigator.of(context).pop();
          },
          text: "CANCEL"
        ),
        AppButton(
          expanded: false,
          onPressed: () {
            askForTransaction.complete(true);
            Navigator.of(context).pop();
          },
          text: "CONFIRM"
        ),
      ],
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Wrap(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: 'The following website is requesting a transaction:\n'),
                        TextSpan(text: '$origin', style: TextStyle(fontWeight: FontWeight.bold),),
                      ]
                    )
                  ),
                ),
              ],
            ),
            Divider(),
            SizedBox(
              height: SizeConfig.safeBlockVertical,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 3,
                  child: Text('Total Value: ')
                ),
                Expanded(
                  flex: 4,
                  child: AppTextFormField(
                    enabled: false,
                    controller: TextEditingController(text: "${valueAmount.getValueInUnit(EtherUnit.ether)} AVAX"),
                    textAlign: TextAlign.end,
                    keyboardType: TextInputType.number,
                    contentPadding: EdgeInsets.symmetric(vertical: 3, horizontal: 2),
                    isDense: true,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: SizeConfig.safeBlockVertical,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 3,
                  child: Text('Gas Limit: ')
                ),
                Expanded(
                  flex: 4,
                  child: AppTextFormField(
                    enabled: false,
                    controller: TextEditingController(text: gasLimit.getValueInUnit(EtherUnit.gwei).toInt().toString()),
                    textAlign: TextAlign.end,
                    keyboardType: TextInputType.number,
                    contentPadding: EdgeInsets.symmetric(vertical: 3, horizontal: 2),
                    isDense: true,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: SizeConfig.safeBlockVertical,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 3,
                  child: Text('Gas Price: ')
                ),
                Expanded(
                  flex: 4,
                  child: AppTextFormField(
                    enabled: false,
                    controller: TextEditingController(text: gasPrice.getValueInUnit(EtherUnit.gwei).toInt().toString()),
                    textAlign: TextAlign.end,
                    keyboardType: TextInputType.number,
                    contentPadding: EdgeInsets.symmetric(vertical: 3, horizontal: 2),
                    isDense: true,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: SizeConfig.safeBlockVertical,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 3,
                  child: Text('Fee Cost: ')
                ),
                Expanded(
                  flex: 4,
                  child: AppTextFormField(
                    enabled: false,
                    controller: TextEditingController(text: "${shortAmount(weiToFixedPoint(fee.getInWei.toInt().toString(), digits: 18))} AVAX"),
                    textAlign: TextAlign.end,
                    keyboardType: TextInputType.number,
                    contentPadding: EdgeInsets.symmetric(vertical: 3, horizontal: 2),
                    isDense: true,
                  ),
                ),
              ],
            ),
          ],
        )
      ]
    );
  });
  return await askForTransaction.future;
}