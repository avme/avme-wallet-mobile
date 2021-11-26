import 'package:avme_wallet/app/controller/services/contract.dart';
import 'package:avme_wallet/app/model/active_contracts.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/card.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Tokens extends StatefulWidget {
  @override
  _TokensState createState() => _TokensState();
}

class _TokensState extends State<Tokens> {
  Contracts contracts;
  int grid = 3;
  @override
  void initState()
  {
    contracts = Contracts.getInstance();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width / 2;
    ///Text("Transactions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
    return Consumer<ActiveContracts>(builder: (context, activeContracts, _){
      return AppCard(
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.darkBlue
          ),
          child: GridView.count(
            crossAxisCount: grid,
            padding: EdgeInsets.all(8),
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            // childAspectRatio : (itemWidth / itemHeight),
            children: activeContracts.tokens.map(
              (tokenName) => TokenItem(
                name: tokenName,
                contractObj: contracts,
              )
            ).toList(),
          ),
        ),
      );
    });    // return Container(
  }
}
class TokenItem extends StatefulWidget
{
  final String name;
  final Contracts contractObj;
  const TokenItem({
    Key key,
    @required this.name,
    @required this.contractObj
  }) : super(key: key);

  @override
  _TokenItemState createState() => _TokenItemState();
}
class _TokenItemState extends State<TokenItem> {
  @override
  Widget build(BuildContext context) {
    print(widget.contractObj.contractsRaw);
    return Container(
      // color: AppColors().randomPrimaries(),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors().randomPrimaries()
        // border: Border.all(
        //     color: AppColors.purple,
        //     width: 2
        // ),
      ),
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          Expanded(child: tokenImage(widget.contractObj.contractsRaw[widget.name]["logo"])),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text("${widget.name}",
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          Text("(${widget.contractObj.contractsRaw[widget.name]["symbol"]})",
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }

  Image tokenImage(String res)
  {
    BoxFit fit = BoxFit.scaleDown;
    return res.contains("http")
      ? Image.network(res, fit: fit,)
      : Image.asset(res, fit: fit,);
  }
}

