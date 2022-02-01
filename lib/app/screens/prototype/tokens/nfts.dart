import 'dart:convert';

import 'package:avme_wallet/app/controller/database/nfts.dart';
import 'package:avme_wallet/app/controller/services/nft_contract.dart';
import 'package:avme_wallet/app/controller/size_config.dart';
import 'package:avme_wallet/app/lib/extensions.dart';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/account_item.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/external/fade_indexed_stack.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/labeltext.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/nft_card.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/nft_details.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/notification_bar.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/popup.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/textform.dart';
import 'package:avme_wallet/app/screens/widgets/custom_widgets.dart';
import 'package:avme_wallet/app/screens/widgets/theme.dart';
import 'package:avme_wallet/external/contracts/erc721_full.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';

import '../../qrcode_reader.dart';
class NFTManagement extends StatefulWidget {
  const NFTManagement({Key key}) : super(key: key);
  @override
  _NFTManagementState createState() => _NFTManagementState();
}

class _NFTManagementState extends State<NFTManagement> {

  NFTContracts nftContracts;
  WalletInterface wi;
  List<AccountObject> accounts;
  Future<NFTData> _initialize;

  List<String> nftAddress = [];
  TableNFT nftTable = TableNFT.instance;
  // String defaultDropdownValue = "No filters";
  String tokenDropdownValue = "No filters";
  String defaultDropdownValue = "No filters";
  TextEditingController filterController = TextEditingController();
  OutlineInputBorder fieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(6.0),
    borderSide: BorderSide(
      width: 2
    )
  );

  NFTData galleryData;
  NFTData _galleryData;
  Map rawContractsNft;
  
  bool canSelectToTransfer = false;

  List<String> bigPictureModes = [
    "AUTO",
    "SHOWN",
    "HIDDEN"
  ];

  List<int> selectedTokens = [];

  String currentBigPictureMode;

  StateSetter nftManagementState;

  @override
  void initState() {
    super.initState();
    nftContracts = NFTContracts.getInstance();
    wi = WalletInterface(listen: false);
    currentBigPictureMode = bigPictureModes.first;
    _initialize = initialize();
  }

  Future<NFTData> initialize() async
  {
    print("\x1B[31m${"INITIALIZE STARTED"}\x1B[0m");
    Map contracts = await nftContracts.initialize();
    String owner = wi.wallet.currentAccount.address;
    EthereumAddress ownerAddress = EthereumAddress.fromHex(owner);

    if(contracts.length == 0)
    {
      this.galleryData = NFTData(contracts: {}, collection: {}, lastSelected: {});
      this._galleryData = NFTData(contracts: {}, collection: {}, lastSelected: {});
      return this.galleryData;
    }

    Map<String,List> _metadata = {};

    for(int i = 0; i < contracts.length; i++)
    {
      String tokenName = contracts.entries.elementAt(i).key;
      print("\x1B[32m${"Processing: \"$tokenName\" token"}\x1B[0m");
      http.Client httpClient = http.Client();
      Web3Client web3client = Web3Client(env['NETWORK_URL'], httpClient);

      ERC721 erc721 = ERC721(
        nftContracts.contracts[tokenName][0],
        address: EthereumAddress.fromHex(nftContracts.contracts[tokenName][1]),
        chainId: int.parse(nftContracts.chainId),
        client: web3client
      );

      int ownedQtd = (await erc721.balanceOf(ownerAddress)).toInt();

      print("\x1B[34m${"[$tokenName] Owner has $ownedQtd tokens"}\x1B[0m");

      if(ownedQtd == 0)
        continue;

      // int totalSupply = (await erc721.totalSupply()).toInt();
      // print("\x1B[34m${"Total Supply [$tokenName]: $totalSupply"}\x1B[0m");
      // if(totalSupply == 0) {
      //   print("\x1B[33m${"[Warning]: The NFT contract $tokenName returned 0 at Total Supply."}\x1B[0m");
      //   continue;
      // }

      //Requesting the NFT catalog
      List _tokenNfts = [];

      //Generating placeholders
      // int generate = 5;
      // for(var i = 0; i < generate; i++)
      // {
      //   String dim = "";
      //   if(i < 10)
      //     dim = "30$i";
      //   else if (i < 99)
      //     dim = "3$i";
      //   else
      //     dim = i.toString();
      //   int rndToken = (Random().nextInt(100000) + i);
      //   _tokenNfts.add(
      //     {
      //       "name" : "Generic Image from API #$i",
      //       "title" : "Generic Image from API #$i",
      //       "tokenId" : "$rndToken",
      //       "tokenName" : tokenName,
      //       "imageUrl" : 'https://picsum.photos/$dim/$dim',
      //       "properties" : {
      //         "description" : {
      //           "type" : "string",
      //           "description" : "lorem ipsum quia da la si ad met, lorem ipsum quia daaaa la si ad met, looooooorem ipsuuuum quia DAAAAAAAAAAAAAAAAAAAAA... album [USA] from anamanaguchi song's name 'lorem ipsum'... I don't know, i just want to be happy or have a beautiful girlfriend or something to be proud of, but i guess life is cock and ball torture, but without cock and ball... all i do is try to speak to you, but time moves me forward separating me fr-, all i do is try to speak to-..."
      //         }
      //       }
      //     }
      //   );
      // }

      for(int l = 0; l < ownedQtd; l++)
      {
        BigInt _id = await erc721.tokenOfOwnerByIndex(ownerAddress, BigInt.from(l));
        String _tokenURI = await erc721.tokenURI(_id);
        print("\x1B[34m${"[$l] $tokenName: Token #${_id.toInt()}'s URI: $_tokenURI"}\x1B[0m");
        Map<String, dynamic> _metadata = await nftContracts.metadata(_tokenURI, _id);
        _metadata['tokenName'] = tokenName;
        _tokenNfts.add(_metadata);
      }
      _metadata[tokenName] = _tokenNfts;
      print("\x1B[32m${"Process $tokenName ended."}\x1B[0m");
    }

    ///For now we're not storing anywhere the last clicked nft id
    ///instead i'll apply the first NFT token

    this.galleryData = NFTData(
      contracts: contracts,
      collection: _metadata,
      lastSelected: _metadata.length > 0 ? _metadata.entries.first.value[0] : {}
    );
    this._galleryData = NFTData(
      contracts: contracts,
      collection: _metadata,
      lastSelected: _metadata.length > 0 ? _metadata.entries.first.value[0] : {}
    );
    return this.galleryData;
  }

  Future<Map> sendTokens({
    String receiver,
    List<Map> tokens,
    List<ValueNotifier> notifier
  })
  async {

    Map contracts = nftContracts.contracts;
    print("\x1B[32m${"Process of send Assets/Tokens started"}\x1B[0m");
    Credentials credentials = wi.wallet.currentAccount.walletObj.privateKey;
    EthereumAddress _sender = EthereumAddress.fromHex(wi.wallet.currentAccount.address);
    EthereumAddress _receiver = EthereumAddress.fromHex(receiver);

    String url = env["NETWORK_URL"];
    http.Client httpClient = http.Client();
    Web3Client web3client = Web3Client(url, httpClient);

    Map hashList = {};
    notifier[0].value = 50;
    for(int i = 0; i < tokens.length; i++)
    {
      notifier[1].value = "${i+1}/${tokens.length} Sending: \"${tokens[i]["tokenName"]}\" #${tokens[i]["tokenId"]}";
      print("\x1B[31m${"Processing NFT #${tokens[i]["tokenId"]} from ${tokens[i]["tokenName"]}"}\x1B[0m");
      EthereumAddress _contract = EthereumAddress.fromHex(contracts[tokens[i]["tokenName"]][1]);
      ContractAbi abi = contracts[tokens[i]["tokenName"]][0];
      BigInt tokenId = BigInt.from(tokens[i]["tokenId"]);
      ERC721 erc721 = ERC721(
        abi,
        address: _contract,
        client: web3client,
        chainId: int.parse(nftContracts.chainId)
      );
      print("\x1B[31m${"Started NFT #${tokens[i]["tokenId"]} ${tokens[i]["tokenName"]}.safeTransferFrom"}\x1B[0m");
      String hash = await erc721.safeTransferFrom(_sender, _receiver, tokenId, credentials: credentials);
      hashList[tokens[i]["tokenId"]] = hash;
      print("\x1B[33m${"NFT #${tokens[i]["tokenId"]}Transaction hash: $hash when processed by ${tokens[i]["tokenName"]}.safeTransferFrom(${wi.wallet.currentAccount.address},$receiver,${tokens[i]["tokenId"]})"}\x1B[0m");
    }
    notifier[0].value = 95;
    notifier[1].value = "Updating assets list";
    _initialize = initialize();
    await _initialize;
    selectedTokens = [];
    setState(() {});
    return hashList;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    nftManagementState = setState;
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            child: Container(
              color: AppColors.darkBlue,
              child: Container(
                color: AppColors.darkBlue.withOpacity(0.4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          FutureBuilder(
                            future: _initialize,
                            builder: (_, AsyncSnapshot<NFTData> loaded){
                              int bigPictureMode = this.bigPictureModes.indexOf(this.currentBigPictureMode);
                              ///Defining Icon based on bigPictureMode
                              IconData icon = Icons.image_search;
                              switch(bigPictureMode) {
                                case 1:
                                  icon = Icons.image;
                                  break;
                                case 2:
                                  icon = Icons.hide_image;
                                  break;
                              }

                              if(loaded.data != null && loaded.data.contracts.length > 0 && loaded.data.length > 0)
                                return AppIconButton(
                                  onPressed: () {
                                    setState(() {
                                      if(bigPictureMode == 2)
                                        this.currentBigPictureMode = this.bigPictureModes[0];
                                      else
                                        this.currentBigPictureMode = this.bigPictureModes[bigPictureMode + 1];

                                      NotificationBar().show(context, text: "Changed preview to ${this.currentBigPictureMode.capitalize()}.");
                                    });
                                  },
                                  icon: Icon(icon)
                                );
                              return AppIconButton(
                                onPressed: () => showFilters(),
                                  icon: Icon(icon, color: AppColors.labelDisabledColor,)
                              );
                            },
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 250),
                        child: this.selectedTokens.length > 0
                          ? Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text("Selected token(s): "),
                                  LabelText(this.selectedTokens.length.toString()),
                                ],
                              ),
                            ),
                          )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                FutureBuilder(
                                  future: _initialize,
                                  builder: (_, AsyncSnapshot<NFTData> loaded){
                                    if(loaded.data != null && loaded.data.contracts.length > 0 && loaded.data.length > 0)
                                      return AppIconButton(
                                        onPressed: () => showFilters(),
                                        icon: Icon(Icons.search)
                                      );
                                    return AppIconButton(
                                      icon: Icon(Icons.search, color: AppColors.labelDisabledColor,)
                                    );
                                  }
                                ),
                                FutureBuilder(
                                  future: _initialize,
                                  builder: (_, AsyncSnapshot<NFTData> loaded) {
                                    if(loaded.data != null && loaded.data.contracts.length > 0)
                                      return SizedBox(
                                        width: SizeConfig.safeBlockVertical * 6,
                                        child: Theme(
                                          data:
                                          avmeTheme.copyWith(
                                            splashColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                          ),
                                          child: PopupMenuButton(
                                            padding: EdgeInsets.all(0),
                                            onSelected: (value) {
                                              switch (value) {
                                                case 0:
                                                  newNFTToken(setState);
                                                  break;
                                                case 1:
                                                  toggleSelection(true);
                                                  break;
                                                case 2:
                                                  _initialize = initialize();
                                                  _initialize.then((value) => setState(() {}));
                                                  break;
                                              }
                                            },
                                            itemBuilder: (context) =>
                                            [
                                              PopupMenuItem(
                                                padding: EdgeInsets.zero,
                                                child: Row(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                      child: FittedBox(child: Icon(Icons.add)),
                                                    ),
                                                    Text("Add Contract"),
                                                  ],
                                                ),
                                                value: 0,
                                              ),
                                              PopupMenuItem(
                                                padding: EdgeInsets.zero,
                                                child: Row(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                      child: FittedBox(
                                                        child: Icon(
                                                          Icons.import_export_outlined,
                                                          color: loaded.data.length > 0 ? Colors.white : AppColors.labelDisabledColor
                                                        )
                                                      ),
                                                    ),
                                                    Text("Transfer Tokens", style: TextStyle(
                                                      color: loaded.data.length > 0 ? Colors.white : AppColors.labelDisabledColor
                                                    ),),
                                                  ],
                                                ),
                                                value: loaded.data.length > 0 ? 1 : -1,
                                              ),
                                              PopupMenuItem(
                                                padding: EdgeInsets.zero,
                                                child: Row(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                      child: FittedBox(child: Icon(Icons.refresh)),
                                                    ),
                                                    Text("Refresh"),
                                                  ],
                                                ),
                                                value: 2,
                                              ),
                                            ]
                                          ),
                                        ),
                                      );
                                    return AppIconButton(
                                      icon: Icon(Icons.adaptive.more, color: AppColors.labelDisabledColor,)
                                    );
                                  }
                                ),
                              ],
                            ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 12,
        ),
        Expanded(
          flex: 10,
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            child: Container(
              color: AppColors.darkBlue,
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      color: AppColors.darkBlue,
                      child: FutureBuilder(
                        future: _initialize,
                        builder: (_, AsyncSnapshot<NFTData> init){
                          if(init.data == null)
                          {
                            return Center(
                              child: SizedBox(
                                width: 80,
                                height: 80,
                                child: CircularProgressIndicator(
                                  color: AppColors.purple,
                                  strokeWidth: 6,
                                ),
                              ),
                            );
                          }
                          else if(galleryData.contracts.length == 0)
                          {
                            return Center(
                              child: introduction(),
                            );
                          }
                          else if(galleryData.length == 0) {
                            return Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth / 12),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: FittedBox(
                                                      child: Icon(
                                                        // Icons.close_rounded,
                                                        Icons.sentiment_dissatisfied,
                                                        color: AppColors.labelDisabledColor,
                                                      ),
                                                    ),
                                                  ),
                                                  Flexible(
                                                    flex: 3,
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(left: 16),
                                                      child: Text(
                                                        "Looks like you don't have any NFT Token...",
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 18
                                                        ),
                                                        textAlign: TextAlign.left,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: SizeConfig.safeBlockVertical * 3,),
                                        Row(
                                          children: [
                                            Expanded(child: Container(),),
                                            Expanded(
                                              child: AppButton(
                                                expanded: true,
                                                onPressed: () {
                                                  _initialize = initialize();
                                                  _initialize.then((value) => setState(() {}));
                                                },
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                // paddingBetweenIcons: 8,
                                                iconData: Icons.refresh,
                                                text: " REFRESH",
                                              ),
                                            ),
                                            Expanded(child: Container(),),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            );
                          }
                          return NFTBigPicture(
                            nftData: this.galleryData,
                            filter: showFilters,
                            addContract: newNFTToken,
                            pageState: setState,
                            toggleSelection: toggleSelection,
                            selectMode: this.canSelectToTransfer,
                            mode: this.currentBigPictureMode,
                            selectedTokens: this.selectedTokens,
                            updateSelectedTokens: updateSelectedTokens,
                            sendTokens: sendTokens,
                          );
                        },
                      )
                    ),
                  ),
                ],
              ),
            )
          ),
        ),
      ],
    );
  }

  toggleSelection(bool mode)
  {
    setState(() {
      this.canSelectToTransfer = mode;
    });
  }

  updateSelectedTokens(int single, {List<int> list = const []})
  {
    List<int> index = [];
    index.addAll(list);
    if(single != null)
      index.add(single);

    for(int i = 0; i < index.length; i++)
    {
      if(this.selectedTokens.contains(index[i]))
        this.selectedTokens.remove(index[i]);
      else
        this.selectedTokens.add(index[i]);
    }
    setState(() {});
  }


  void showFilters()
  {
    showDialog(context: context, builder: (_) =>
      StatefulBuilder(builder: (context, setState) {
        return AppPopupWidget(
          title: "Advanced Search",
          // showIndicator: false,
          cancelable: false,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppLabelText("Filter by Contract", fontSize: 18,),
                SizedBox(
                  height: SizeConfig.safeBlockVertical * 2,
                ),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: tokenDropdownValue,
                  icon: Icon(Icons.keyboard_arrow_down, color: AppColors.labelDefaultColor),
                  elevation: 16,
                  onChanged: (String selectedAddress){
                    tokenDropdownValue = selectedAddress;
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.darkBlue,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 12
                    ),
                    enabledBorder: fieldBorder.copyWith(
                      borderSide: BorderSide(
                        width: 2,
                        color: AppColors.labelDefaultColor,
                      ),
                    ),
                    errorBorder: fieldBorder.copyWith(
                      borderSide: BorderSide(
                        width: 2,
                        color: AppColors.labelDefaultColor,
                      )
                    ),
                  ),
                  items: nftContracts.contractsRaw.entries.map((raw) =>
                    DropdownMenuItem<String>(
                      value: raw.key,
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right:SizeConfig.safeBlockVertical * 1.5),
                            child: resolveImage(raw.value['logo'], width: SizeConfig.safeBlockVertical * 3.5),
                          ),
                          Text(raw.key, style: AppTextStyles.label,),
                        ],
                      ),
                    ),
                  ).toList()..insert(0,
                    DropdownMenuItem<String>(
                      value: defaultDropdownValue,
                      child: Row(
                        children: [
                          Text(defaultDropdownValue, style: AppTextStyles.label,),
                        ],
                      ),
                    )
                  ),
                ),
                SizedBox(
                  height: SizeConfig.safeBlockVertical * 2,
                ),
                AppLabelText("Filter", fontSize: 18,),
                SizedBox(
                  height: SizeConfig.safeBlockVertical * 2,
                ),
                AppTextFormField(
                  controller: filterController,
                  hintText: 'Filter by Symbol or Name',
                ),
                SizedBox(
                  height: SizeConfig.safeBlockVertical * 4,
                ),
                AppButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    applyFilters();
                  },
                  text: "APPLY"
                ),
                SizedBox(
                  height: SizeConfig.safeBlockVertical * 2,
                ),
                AppButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                  text: "CANCEL"
                ),
              ],
            ),
          ]
        );
      })
    );
  }

  Widget introduction()
  {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth / 6),
                child: Text(
                  "You haven't added any NFT Token Contract...",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: SizeConfig.safeBlockVertical * 3,),
              AppButton(
                expanded: false,
                onPressed: () => newNFTToken(setState),
                text: "ADD NFT CONTRACT",
              )
            ],
          ),
        ),
      ],
    );
  }

  void applyFilters()
  {
    String selectedToken = tokenDropdownValue == defaultDropdownValue
      ? ""
      : tokenDropdownValue;

    String filterText = filterController.text.trim();
    if(selectedToken.length == 0 && filterText.length == 0)
    {
      setState(() {
        galleryData = _galleryData;
      });
      return;
    }
    NFTData filtered = _galleryData.applyFilter(selectedToken, filterText);

    setState(() {
      galleryData = filtered;
    });

    NotificationBar().show(context, text: "applying filters");
  }

  void newNFTToken(StateSetter nftState)
  {
    bool validAddress = false;
    TextEditingController contractAddress = TextEditingController();
    showDialog(context: context, builder: (_) =>
      StatefulBuilder(builder: (context,setState) {
        return AppPopupWidget(
          title: "Add NFT Token",
          cancelable: false,
          canClose: true,
          padding: EdgeInsets.zero,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppLabelText("Token Address", fontSize: 18,),
                SizedBox(
                  height: SizeConfig.safeBlockVertical * 2,
                ),
                AppTextFormField(
                  maxLength: 42,
                  controller: contractAddress,
                  hintText: 'e.g. 0x123456789ABCDEF...',
                  onChanged: (String value) {
                    if(value.length == 42)
                      setState((){
                        validAddress = true;
                      });
                    else if(validAddress)
                      setState((){
                        validAddress = !validAddress;
                      });
                  },
                ),
                SizedBox(
                  height: SizeConfig.safeBlockVertical * 2,
                ),
                AppButton(
                  enabled: validAddress,
                  onPressed: () async {
                    ValueNotifier<int> percentage = ValueNotifier(0);
                    ValueNotifier<String> label = ValueNotifier("Loading...");
                    List<ValueNotifier> loadingNotifier = [
                      percentage,
                      label
                    ];
                    String exists = await nftTable.exists(contractAddress.text);
                    if(exists.length > 0){
                      Navigator.pop(context);
                      NotificationBar().show(context, text: "You can't add the same NFT Contract twice.");
                      return null;
                    }
                    await showDialog(context: context, builder: (_) =>
                      StatefulBuilder(
                        builder: (builder, setState){
                          return ProgressPopup(
                            showIndicator: false,
                            listNotifier: loadingNotifier,
                            future: nftContracts
                                .addTokenFromAddress(
                              accountAddress: wi.wallet.currentAccount.address,
                              contractAddress: contractAddress.text,
                            )
                            .then((Map map) async {
                              if(map.length == 0)
                                return [
                                  Text("Sorry, but no Contracts was found.")
                                ];
                              else
                              {
                                Navigator.of(context).pop();
                                await Future.delayed(Duration(milliseconds: 250));
                                Navigator.of(context).pop();
                                _initialize = initialize();
                                nftState((){});
                              }
                            }
                            ),
                            title: "Warning",
                          );
                        },
                      )
                    );
                  },
                  text: "ADD TOKEN"),
                SizedBox(
                  height: SizeConfig.safeBlockVertical * 2,
                ),
                AppButton(onPressed: () {
                  Navigator.of(context).pop();
                }, text: "CANCEL"),
              ]
            )
          ]
        );
      })
    );
  }

  Widget gallery(NFTData nftData)
  {
    List<Map> _nfts = [];
    nftData.collection.forEach((String key, List list){
      list.forEach((element) => _nfts.add(element));
    });
    return Padding(
      padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 3.33),
      child: Row(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: SizeConfig.safeBlockHorizontal * 3.33,
                mainAxisSpacing: SizeConfig.safeBlockHorizontal * 3.33,
                crossAxisCount: 2,
                childAspectRatio: 3/4
              ),
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: _nfts.length,
              itemBuilder: (_, index) {
                return NFTCard(
                  nftData: _nfts[index],
                );
              }),
          ),
        ],
      ),
    );
  }
}

class NFTBigPicture extends StatefulWidget {

  final NFTData nftData;
  final Function filter;
  final Function addContract;
  final Function toggleSelection;
  final Function updateSelectedTokens;
  final Function sendTokens;
  final StateSetter pageState;
  final String mode;
  final bool selectMode;
  final List<int> selectedTokens;

  const NFTBigPicture({
    Key key,
    @required this.nftData,
    @required this.filter,
    @required this.addContract,
    @required this.pageState,
    @required this.mode,
    @required this.toggleSelection,
    @required this.selectMode,
    @required this.updateSelectedTokens,
    @required this.selectedTokens,
    @required this.sendTokens,
  }) : super(key: key);

  @override
  _NFTBigPictureState createState() => _NFTBigPictureState();
}

class _NFTBigPictureState extends State<NFTBigPicture>
  with TickerProviderStateMixin {

  int selectedGallery = 0;
  Map bigPicture = {};

  bool visible = true;
  AnimationController bigPictureController;
  Animation<double> bigPictureTween;

  ///Token Selection
  BorderRadius cardRadius = const BorderRadius.all(Radius.circular(12));

  ///List of token images/logo
  Map<String, String> images = {};
  Map<String, String> symbol = {};
  ///List of NFTs
  List<Map> nfts = [];

  @override
  void initState() {
    bigPictureController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds:250)
    );
    bigPictureTween = CurvedAnimation(parent: bigPictureController, curve: Curves.ease);
    prepareNFTData();
    super.initState();
  }

  @override
  void didUpdateWidget(NFTBigPicture oldWidget) {
    if(widget.mode != oldWidget.mode) {
      switch(widget.mode.toUpperCase())
      {
        case "AUTO":
          if(this.visible)
            bigPictureController.forward(from: bigPictureTween.value);
          else
            bigPictureController.reverse(from: bigPictureTween.value);
          break;
        case "SHOWN":
          bigPictureController.forward();
          break;
        case "HIDDEN":
          bigPictureController.reverse();
      }
    }

    ///Updating NFTs listing

    if(widget.nftData != oldWidget.nftData)
      prepareNFTData();

    super.didUpdateWidget(oldWidget);
  }

  void prepareNFTData()
  {
    nfts = [];
    widget.nftData.collection.forEach((String key, List list){
      list.forEach((element) => nfts.add(element));
      images[key] = widget.nftData.contracts[key]["logo"];
      symbol[key] = widget.nftData.contracts[key]["symbol"];
    });
  }

  @override
  Widget build(BuildContext context) {
    ///Checking visibility at every build method a.k.a setState calls too
    if(widget.mode.toUpperCase() == "AUTO")
      if(visible)
        bigPictureController.forward();
      else
        bigPictureController.reverse();

    if(widget.selectMode && widget.mode.toUpperCase() == "AUTO")
    {
      visible = false;
      bigPictureController.reverse();
    }
    return Column(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: SizeConfig.safeBlockVertical * 32,
          ),
          child: SizeTransition(
            axis: Axis.vertical,
            sizeFactor: bigPictureTween,
            axisAlignment: -1,
            child: Stack(
              fit: StackFit.expand,
              children: [
                FadeBigPicture(
                  data: this.bigPicture.length > 0
                    ? this.bigPicture
                    : widget.nftData.lastSelected,
                ),
              ],
            )
          ),
        ),
        Expanded(
          flex: 8,
          child: FadeIndexedStack(
            index: selectedGallery,
            children: [
              GridGallery(
                images: images,
                symbol: symbol,
                nfts: nfts,
                selectedTokens: widget.selectedTokens,
                updateVisibility: updateVisibility,
                scrollVisibility: scrollVisibility,
              ),
              ListGallery(
                images: images,
                symbol: symbol,
                nfts: nfts,
                selectedTokens: widget.selectedTokens,
                updateVisibility: updateVisibility,
                scrollVisibility: scrollVisibility,
              ),
            ],
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: widget.selectMode ? transferTokens() : viewport(),
          switchInCurve: Curves.ease,
          switchOutCurve: Curves.ease,
          transitionBuilder: (Widget child, Animation<double> animation)
          {
            return SizeTransition(
              axis: Axis.vertical,
              axisAlignment: -1,
              sizeFactor: animation,
              child: child,
            );
          },
        ),
      ],
    );
  }

  void updateVisibility(int index)
  {
    if(widget.selectMode)
    {
      widget.updateSelectedTokens(index);
      if(visible)
        visible = true;
    }
    else
    {
      if (widget.mode.toUpperCase() == "AUTO")
        visible = true;
      if (this.bigPicture != nfts[index])
        this.bigPicture = nfts[index];
      setState(() {});
    }
  }

  bool scrollVisibility(dynamic type)
  {
    if(type is ScrollStartNotification || type is ScrollEndNotification)
    {
      print("THE ELDER SCROLLS");
      if(widget.mode.toUpperCase() == "AUTO")
        if(visible)
          setState(() {
            visible = false;
          });
    }
    return true;
  }

  Widget viewport()
  {
    return Row(
      children: [
        Expanded(
          child: Container(
            child: AppIconButton(
              icon: Icon(Icons.grid_view),
              onPressed: () {
                if(this.selectedGallery != 0) {
                  setState((){
                    this.selectedGallery = 0;
                  });
                }
              },
            ),
          )
        ),
        SizedBox(
          height: 20,
          width: 2,
          child: Container(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        Expanded(
          child: Container(
            child: AppIconButton(
              icon: Icon(Icons.list),
              onPressed: () {
                if(this.selectedGallery != 1) {
                  setState((){
                    this.selectedGallery = 1;
                  });
                }
              },
            ),
          )
        ),
      ],
    );
  }

  Widget transferTokens()
  {
    return ClipRRect(
      borderRadius: cardRadius,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: AppButton(
                  enabled: widget.selectedTokens.length > 0 ? true : false,
                  onPressed: () {
                    showDialog(context: context, builder: (_) =>
                      SendNFTs(
                        images: images,
                        symbol: symbol,
                        nfts: nfts,
                        selectedTokens: widget.selectedTokens,
                        updateSelectedTokens: widget.updateSelectedTokens,
                        sendTokens: widget.sendTokens)
                    );
                  }, text: "SEND TOKENS", square: true,
                )
              )
            ],
          ),
          SizedBox(
            height: SizeConfig.safeBlockHorizontal,
          ),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  onPressed: () {
                    if(widget.selectMode && widget.mode.toUpperCase() == "AUTO"){
                      visible = true;
                      bigPictureController.forward();
                    }
                    ///Unselecting the tokens
                    widget.updateSelectedTokens(null, list: widget.selectedTokens);

                    setState(() {
                      widget.toggleSelection(false);
                    });
                  },
                  text: "CANCEL",
                  square: true,
                )
              )
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    bigPictureController.dispose();
    super.dispose();
  }
}

Text textOutline(
  String text,
  {
    double fontSize = 18,
    Color color = Colors.white,
    Color outlineColor = AppColors.darkBlue
  }
)
{
  double positive = 1.5;
  double negative = (positive * 2) - positive;
  return Text(text,
    style: TextStyle(
        inherit: true,
        fontSize: fontSize,
        color: Colors.white,
        shadows: [
          Shadow( // bottomLeft
            offset: Offset(negative, negative),
            color: outlineColor
          ),
          Shadow( // bottomRight
            offset: Offset(positive, negative),
            color: outlineColor
          ),
          Shadow( // topRight
            offset: Offset(positive, positive),
            color: outlineColor
          ),
          Shadow( // topLeft
            offset: Offset(negative, positive),
            color: outlineColor
          ),
        ]
    ),
  );
}

class GridGallery extends StatefulWidget {

  final Map<String, String> images;
  final Map<String, String> symbol;
  final List<Map> nfts;
  final List<int> selectedTokens;
  final Function updateVisibility;
  final Function scrollVisibility;

  const GridGallery({
    Key key,
    @required this.images,
    @required this.symbol,
    @required this.nfts,
    @required this.selectedTokens,
    @required this.updateVisibility,
    @required this.scrollVisibility
  }) : super(key: key);

  @override
  _GridGalleryState createState() => _GridGalleryState();
}

class _GridGalleryState extends State<GridGallery> {
  int gridSize = 4;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 3.33).copyWith(
          bottom: 0
      ),
      child: Row(
        children: [
          Expanded(
            child: NotificationListener(
              onNotification: (type) => widget.scrollVisibility(type),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: SizeConfig.safeBlockHorizontal * 3.33,
                  mainAxisSpacing: SizeConfig.safeBlockHorizontal * 3.33,
                  crossAxisCount: gridSize,
                  childAspectRatio: (gridSize % 2 == 0 ? 1 : 3 / 4)
                ),
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: widget.nfts.length,
                itemBuilder: (_, index) =>
                  gridBuilder(
                    index,
                    widget.selectedTokens.contains(index)
                  )
              )
            ),
          ),
        ],
      ),
    );
  }

  Widget gridBuilder(int index, bool isSelected)
  {
    double horizontal4 = SizeConfig.blockSizeHorizontal * 4;
    return ClipRRect(
      borderRadius: cardRadius,
      child: Container(
        color: isSelected
          ? AppColors.purple
          : null,
        child: Padding(
          padding: isSelected
            ? const EdgeInsets.all(4)
            : EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: isSelected
              ? const BorderRadius.all(Radius.circular(8))
              : cardRadius,
            child: Stack(
              fit: StackFit.expand,
              children: [
                GestureDetector(
                  onTap: () => widget.updateVisibility(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          color: Colors.white60,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              cachedImage(
                                widget.nfts[index]['imageUrl'],
                                fit: BoxFit.cover),
                              Padding(
                                padding: EdgeInsets.all(
                                  SizeConfig.safeBlockHorizontal * 1.33),
                                child: Column(
                                  children: [
                                    Flexible(
                                      child: Align(
                                        alignment: Alignment.topRight,
                                        child: textOutline(
                                          "#${widget.nfts[index]["tokenId"]}",
                                          fontSize: 12
                                        )
                                      )
                                    ),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Flexible(
                                            child: textOutline(
                                              widget.nfts[index]["tokenName"],
                                              fontSize: 12
                                            ),
                                          ),
                                          SizedBox(
                                            width: horizontal4,
                                            height: horizontal4,
                                            child: resolveImage(
                                              widget.images[widget.nfts[index]["tokenName"]],
                                              width: horizontal4,
                                              height: horizontal4,
                                            )
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          )
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ListGallery extends StatefulWidget {
  final Map<String, String> images;
  final Map<String, String> symbol;
  final List<Map> nfts;
  final List<int> selectedTokens;
  final Function updateVisibility;
  final Function scrollVisibility;

  const ListGallery({
    Key key,
    @required this.images,
    @required this.symbol,
    @required this.nfts,
    @required this.selectedTokens,
    @required this.updateVisibility,
    @required this.scrollVisibility
  }) : super(key: key);
  @override
  _ListGalleryState createState() => _ListGalleryState();
}

class _ListGalleryState extends State<ListGallery> {
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: (type) => widget.scrollVisibility(type),
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: widget.nfts.length,
        itemBuilder: (_, index) =>
          itemBuilder(
            index,
            widget.selectedTokens.contains(index)
          )
      ),
    );
  }

  Widget itemBuilder(int index, bool isSelected)
  {
    double horizontal4 = SizeConfig.blockSizeHorizontal * 4;
    return Column(
      children: [
        GestureDetector(
          onTap: () => widget.updateVisibility(index),
          child: Padding(
            padding: EdgeInsets.all(SizeConfig.safeBlockVertical * 0.66),
            child: Container(
              color: AppColors.darkBlue,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: SizeConfig.safeBlockVertical * 10,
                      child: Padding(
                        padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 1.33),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          child: Container(
                            color: isSelected
                              ? AppColors.purple
                              : null,
                            child: Padding(
                              padding: isSelected
                                ? const EdgeInsets.all(4)
                                : EdgeInsets.zero,
                              child: ClipRRect(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    cachedImage(
                                      widget.nfts[index]['imageUrl'],
                                      fit: BoxFit.cover
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.topRight,
                                              child: textOutline(
                                                "#${widget.nfts[index]["tokenId"]}",
                                                fontSize: 12
                                              )
                                            )
                                          ),
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.bottomRight,
                                              child: SizedBox(
                                                width: horizontal4,
                                                height: horizontal4,
                                                child: resolveImage(
                                                  widget.images[widget.nfts[index]["tokenName"]],
                                                  width: horizontal4,
                                                  height: horizontal4,
                                                )
                                              )
                                            )
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 1.33),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ///Title
                          Text(
                            widget.nfts[index]["title"].replaceAll("", "\u{200B}"),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          ///Subtitle
                          Text(
                            widget.nfts[index]["properties"]["description"]["description"].replaceAll("", "\u{200B}"),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.labelDefaultColor
                            ),
                          ),
                          ///Contract Symbol
                          Text(
                            widget.symbol[widget.nfts[index]["tokenName"]].replaceAll("", "\u{200B}"),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        index == (widget.nfts.length - 1)
          ? Container()
          : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Divider(color: Colors.white,height: 0,)
          )
      ],
    );
  }
}

class SendNFTs extends StatefulWidget {

  final Map<String, String> images;
  final Map<String, String> symbol;
  final List<Map> nfts;
  final List<int> selectedTokens;
  final Function updateSelectedTokens;
  final Function sendTokens;
  const SendNFTs({
    Key key,
    @required this.images,
    @required this.symbol,
    @required this.nfts,
    @required this.selectedTokens,
    @required this.updateSelectedTokens,
    @required this.sendTokens,
  }) : super(key: key);

  @override
  _SendNFTsState createState() => _SendNFTsState();
}

class _SendNFTsState extends State<SendNFTs> {

  double horizontal4 = SizeConfig.blockSizeHorizontal * 4;

  @override
  Widget build(BuildContext context) {
    ScrollController controller = ScrollController();
    TextEditingController addressController = TextEditingController();
    return StatefulBuilder(builder: (context, setState) {
      return AppPopupWidget(
        title: 'SEND NFTS',
        canClose: true,
        cancelable: false,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                EdgeInsets.only(bottom: SizeConfig.safeBlockVertical),
                child: AppLabelText(
                  "Address",
                  textStyle: TextStyle(color: AppColors.labelDefaultColor),
                  fontSize: SizeConfig.fontSizeLarge,
                ),
              ),
              AppTextFormField(
                controller: addressController,
                hintText: 'e.g. 0x123456789ABCDEF...',
                validator: (value) {
                  if (value.length != 42 || !isHex(value)) {
                    return 'This is not a valid address';
                  }
                  return null;
                },
                icon: new Icon(
                  Icons.qr_code_scanner,
                  color: AppColors.labelDefaultColor,
                  size: 32,
                ),
                iconOnTap: () async {
                  String response = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => QRScanner())
                  );
                  NotificationBar()
                    .show(context, text: "Scanned: \"$response\"");
                  setState(() {
                    addressController.text = response;
                  });
                },
              ),
              SizedBox(
                height: SizeConfig.safeBlockVertical * 2,
              ),
              Padding(
                padding: EdgeInsets.only(
                  bottom: SizeConfig.safeBlockVertical
                ),
                child: AppLabelText(
                  "Selected NFTs",
                  textStyle: TextStyle(color: AppColors.labelDefaultColor),
                  fontSize: SizeConfig.fontSizeLarge,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.darkBlue
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: SizeConfig.safeBlockVertical,
                    top: SizeConfig.safeBlockVertical,
                    bottom: SizeConfig.safeBlockVertical,
                    right: SizeConfig.safeBlockVertical / 2
                  ),
                  child: Column(
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: SizeConfig.safeBlockVertical * 30,
                        ),
                        child: Scrollbar(
                          controller: controller,
                          child: ListView.builder(
                            controller: controller,
                            shrinkWrap: true,
                            itemCount: widget.selectedTokens.length,
                            itemBuilder: (BuildContext context, int index) {
                              return itemBuilder(index);
                            },
                          )
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: SizeConfig.safeBlockVertical * 2,
          ),
          AppButton(
            onPressed: () async {
              List<Map> nftList = [];
              widget.selectedTokens.forEach((key) {
                nftList.add(widget.nfts[key]);
              });
              ValueNotifier<int> percentage = ValueNotifier(0);
              ValueNotifier<String> label = ValueNotifier(
                "0/${nftList.length} Preparing");

              List<ValueNotifier> loadingNotifier = [
                percentage,
                label
              ];
              await showDialog(context: context, builder: (_) =>
                StatefulBuilder(
                  builder: (builder, setState) {
                    return ProgressPopup(
                      listNotifier: loadingNotifier,
                      future: widget.sendTokens(
                        receiver: addressController.text,
                        tokens: nftList,
                        notifier: loadingNotifier
                      ).then((Map hash) async
                      {
                        await Future.delayed(Duration(milliseconds: 150));
                        Navigator.of(context).pop();
                      }),
                      title: "Warning",
                    );
                  },
                )
              );
            },
            text: "CONFIRM"
          ),
          SizedBox(
            height: SizeConfig.safeBlockVertical * 2,
          ),
          AppButton(onPressed: () {
            Navigator.of(context).pop();
          }, text: "CANCEL"),
        ],
      );
    });
  }

  Widget itemBuilder(int index)
  {
    return Column(
      children: [
        Container(
          color: AppColors.darkBlue,
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  height: SizeConfig.safeBlockVertical * 10,
                  child: Padding(
                    padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 1.33),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          cachedImage(
                            widget.nfts[widget.selectedTokens[index]]['imageUrl'],
                            fit: BoxFit.fitWidth
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: textOutline(
                                      "#${widget.nfts[widget.selectedTokens[index]]["tokenId"]}",
                                      fontSize: 12
                                    )
                                  )
                                ),
                                tokenSymbol(index),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              tokenInfo(index),
              removeSelected(index),
            ],
          ),
        ),
        index == (widget.selectedTokens.length - 1)
          ? Container()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Divider(
                color: Colors.white, height: 0,
              ),
            )
      ],
    );
  }

  Widget removeSelected(int index)
  {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          widget.updateSelectedTokens(
            widget.selectedTokens[index]);
          if (widget.selectedTokens.length == 0)
            Navigator.pop(context);
          else
            setState(() {});
        },
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(Icons.close_rounded,
                color: Colors.red,
                size: 32,
              ),
            ),
          )
        )
      ),
    );
  }

  Widget tokenInfo(int index)
  {
    int selectedId = widget.selectedTokens[index];
    return Expanded(
      flex: 2,
      child: Padding(
        padding: EdgeInsets.all(
            SizeConfig.safeBlockHorizontal * 1.33),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///Title
            Text(
              "${widget.nfts[selectedId]["title"]} #${widget.nfts[selectedId]["tokenId"]}"
                .replaceAll("", "\u{200B}"),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            ///Subtitle
            Text(
              widget.nfts[selectedId]["properties"]["description"]["description"]
                .replaceAll("", "\u{200B}"),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight
                  .bold,
                fontSize: 16,
                color: AppColors
                  .labelDefaultColor
              ),
            ),
            ///Contract Symbol
            Text(
              "${widget.nfts[selectedId]["tokenName"]} - ${
                widget.symbol[widget.nfts[selectedId]["tokenName"]]
              }".replaceAll("", "\u{200B}"),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget tokenSymbol(int index)
  {
    return Expanded(
      child: Align(
        alignment: Alignment.bottomRight,
        child: SizedBox(
          width: horizontal4,
          height: horizontal4,
          child: resolveImage(widget.images[widget.nfts[widget.selectedTokens[index]]["tokenName"]],
            width: horizontal4,
            height: horizontal4
          )
        )
      )
    );
  }
}


class FadeBigPicture extends StatefulWidget {

  final Map data;
  final Duration duration;
  final bool showDetails;

  const FadeBigPicture({
    Key key,
    this.showDetails = false,
    @required this.data,
    this.duration = const Duration(
      milliseconds: 650,
    ),
  }) : super(key: key);

  @override
  _FadeBigPictureState createState() => _FadeBigPictureState();
}

class _FadeBigPictureState extends State<FadeBigPicture>
    with TickerProviderStateMixin{

  AnimationController _controller;
  AnimationController cardController;

  bool _showDetails;

  @override
  void didUpdateWidget(FadeBigPicture oldWidget) {
    if(widget.data != oldWidget.data) {
      _controller.forward(from: 0.0);
      _showDetails = oldWidget.showDetails;
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _controller.forward();
    cardController = AnimationController(vsync: this, duration: Duration(
      milliseconds: 100
    ));
    _showDetails = _showDetails ?? false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showDetails = !_showDetails;
        if(_showDetails)
          cardController.forward();
        else
          cardController.reverse();
      },
      child: FadeTransition(
        opacity: _controller,
        child: Stack(
          fit: StackFit.expand,
          children:
          [
            Container(
            child: Hero(
              tag: "${widget.data['tokenId']}_bigPicture",
              child: cachedImage(
                widget.data["imageUrl"],
                height: double.maxFinite,
                width: double.maxFinite,
                fit: BoxFit.cover),
              )
            ),
            FadeTransition(
              opacity: cardController,
              child: Container(
                color: Colors.black.withOpacity(0.4),
                child: Column(
                  children: [
                    Expanded(
                      flex: 10,
                      child: Padding(
                        padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 3.33),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                LabelText(
                                    "Title"
                                ),
                                Text(
                                    widget.data["title"]
                                ),
                                SizedBox(
                                  height: SizeConfig.safeBlockHorizontal * 1.33,
                                ),
                                LabelText(
                                    "Name"
                                ),
                                Text(
                                    widget.data["name"]
                                ),
                                SizedBox(
                                  height: SizeConfig.safeBlockHorizontal * 1.33,
                                ),
                                LabelText(
                                    "Description"
                                ),
                                Text(
                                  widget.data["properties"]["description"]["description"].replaceAll("", "\u{200B}"),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            AppButton(
                              expanded: false,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) {
                                    return NFTDetails(
                                      nftData: widget.data,
                                      heroTag: "${widget.data['tokenId']}_bigPicture",
                                    );
                                  })
                                );
                              },
                              text: "More"
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  @override
  void dispose() {
    _controller.dispose();
    cardController.dispose();
    super.dispose();
  }
}

class NFTData {
  ///{"TokenName": {"address"}}
  Map<String,Map> contracts;
  ///{"TokenName": [nft1, nft2, ...]}
  Map<String,List> collection;
  Map lastSelected;

  NFTData({
    @required this.contracts,
    @required this.collection,
    @required this.lastSelected,
  });

  NFTData applyFilter(String tokenName, String text)
  {
    ///Filtering every entry of NFT Collection
    Map<String, List> filteredCollection = {};

    if(tokenName.length > 0)
      this.collection.entries.forEach((collection) {
        if(collection.key == tokenName)
          filteredCollection[collection.key] = collection.value;
      });
    else
      filteredCollection = this.collection;

    ///Filtering by text
    if(text.length > 0)
    {
      Map<String, List> collections = filteredCollection;
      // print("collections");
      // print(this.collection);
      collections.entries.forEach((tokenCollection) {
        List metadata = tokenCollection.value;
        List filtered = [];
        metadata.forEach((data) {
          String rejectHumanity = jsonEncode(data);
          if(rejectHumanity.contains(text))
            filtered.add(data);
        });
        filteredCollection[tokenCollection.key] = filtered;
      });
    }

    return new NFTData(
      contracts: this.contracts,
      collection: filteredCollection,
      lastSelected: this.lastSelected
    );
  }

  int get length
  {
    int total = 0;
    this.collection.entries.forEach((MapEntry<String, List> _collection) {
      total += _collection.value.length;
    });
    return total;
  }
}