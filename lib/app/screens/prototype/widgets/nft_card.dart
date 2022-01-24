import 'package:avme_wallet/app/controller/size_config.dart';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/nft_details.dart';
import 'package:avme_wallet/app/screens/widgets/custom_widgets.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';
class NFTCard extends StatelessWidget {

  final Map nftData;

  const NFTCard({Key key, this.nftData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) {
                  return NFTDetails(nftData: nftData, heroTag: "${nftData['tokenName']}_${nftData['tokenId']}_card",);
                })
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    color: Colors.white60,
                    child: Hero(
                      tag: "${nftData['tokenName']}_${nftData['tokenId']}_card",
                      child: cachedImage(nftData['imageUrl'], fit: BoxFit.cover)
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: AppColors.cardDefaultColor,
                    child: Padding(
                      padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Text(
                                    nftData["properties"]["description"]["description"].replaceAll("", "\u{200B}"),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColors.labelDefaultColor
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    nftData["title"].replaceAll("", "\u{200B}"),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        // fontWeight: FontWeight.bold,
                                        // fontSize: 16,
                                        // color: AppColors.labelDefaultColor
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "#${nftData["tokenId"]}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                    )
                  ),
                )
              ],
            ),
          ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.start,
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     ElevatedButton(onPressed: () async{
          //       await CachedNetworkImage.evictFromCache(nftData['imageUrl']);
          //     }, child: Icon(Icons.clear))
          //   ],
          // ),
        ],
      ),
    );
  }
}
