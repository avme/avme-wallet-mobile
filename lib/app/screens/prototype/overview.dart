import 'package:avme_wallet/app/lib/utils.dart';
import 'widgets/balance.dart';
import 'widgets/neon_button.dart';
import 'widgets/button.dart';
import 'widgets/card.dart';
import 'widgets/token_distribution.dart';
import 'widgets/token_value.dart';
import 'package:avme_wallet/app/screens/widgets/custom_widgets.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'widgets/history_snippet.dart';


class Overview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return ListView(
      children: [
        OverviewAndButtons(),
        TokenDistribution(),

        ///AVAX Token Card
        TokenValue(
          image:
          Image.asset(
            'assets/avax_logo.png',
            fit: BoxFit.fitHeight,),
          name: 'AVAX',
          amount: "12 101,001221",
          marketValue: "1731,76",
          valueDifference: "2,013",
        ),

        ///AVME Token Card
        TokenValue(
          image:
            Image.asset(
            'assets/resized-newlogo02-trans.png',
            fit: BoxFit.fitHeight,),
          name: 'AVME',
          amount: "3 633,226251",
          marketValue: "1631,76",
          valueDifference: "8,669",
        ),
        AppCard(
          child: Column(
            children: [
              Text("History"),
              SizedBox(
                height: 12,
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.darkBlue
                ),
                child: Column(
                  children: [
                    HistorySnippet(
                      amount: "32,30",
                      sent: true,
                    ),
                    HistorySnippet(
                      amount: "12,99",
                      sent: false,
                    ),
                    HistorySnippet(
                      amount: "2,12",
                      sent: false,
                    ),
                    HistorySnippet(
                      amount: "15,13",
                      sent: true,
                    ),
                    HistorySnippet(
                      amount: "0,37",
                      sent: true,
                    ),
                  ],
                )
              ),
              SizedBox(
                height: 12,
              ),
              AppNeonButton(onPressed: (){}, text: "SHOW FULL HISTORY"),
            ],
          ),
        )
      ],
    );
  }
}
