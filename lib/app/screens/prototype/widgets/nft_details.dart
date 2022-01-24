import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/button.dart';
import 'package:avme_wallet/app/screens/widgets/custom_widgets.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'card.dart';

class NFTDetails extends StatelessWidget {
  final Map nftData;
  final Object heroTag;
  const NFTDetails({Key key, @required this.nftData, @required this.heroTag}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    print("NFT DATA $nftData");
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Flexible(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    child: cachedImage(
                      nftData["imageUrl"],
                      height: double.maxFinite,
                      width: double.maxFinite,
                      fit: BoxFit.cover
                    ),
                    tag: heroTag,
                  ),
                  Positioned.fill(
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  color: Colors.black45.withOpacity(0.05),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      AppIconButton(
                                        onPressed: () => null,
                                        icon: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Align(
                                              child: Icon(
                                                Icons.more_horiz,
                                                color: AppColors.cardDefaultColor.withOpacity(0.5),
                                              ),
                                              alignment:
                                                Alignment(0.4,0.4),
                                            ),
                                            Icon(
                                              Icons.more_horiz
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      AppIconButton(
                                        onPressed: () => null,
                                        icon: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Align(
                                              child: FaIcon(
                                                FontAwesomeIcons.expand,
                                                color: AppColors.cardDefaultColor.withOpacity(0.5),
                                              ),
                                              alignment: Alignment(0.4,0.4),
                                            ),
                                            Center(
                                              child: FaIcon(
                                                FontAwesomeIcons.expand,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        )
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      )
                    ),
                  )
                ],
              )
            ),
            Flexible(
              child: AppCard(
                child: Row(
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LabelText("Name:", fontSize: 20,),
                          Text(nftData["name"], style: TextStyle(fontSize: 16),),
                          LabelText("Title:", fontSize: 20,),
                          Text(nftData["title"], style: TextStyle(fontSize: 16),),
                          LabelText("Description:", fontSize: 20,),
                          RichText(text: TextSpan(
                            text: nftData["properties"]["description"]["description"],
                            style: TextStyle(fontSize: 16)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Expanded(child: Image.network(nftData["imageUrl"], fit: BoxFit.fitHeight,))
          ],
        ),
      ),
    );
  }
}
