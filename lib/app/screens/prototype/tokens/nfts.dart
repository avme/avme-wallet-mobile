import 'dart:convert';
import 'dart:math';

import 'package:avme_wallet/app/controller/database/nfts.dart';
import 'package:avme_wallet/app/controller/services/nft_contract.dart';
import 'package:avme_wallet/app/controller/size_config.dart';
import 'package:avme_wallet/app/lib/utils.dart';
import 'package:avme_wallet/app/model/account_item.dart';
import 'package:avme_wallet/app/model/app.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/button.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/card.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/external/fade_indexed_stack.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/labeltext.dart';
import 'package:avme_wallet/app/screens/prototype/widgets/neon_button.dart';
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
  Future<Map> pending;

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

  StateSetter nftManagementState;

  @override
  void initState() {
    super.initState();
    nftContracts = NFTContracts.getInstance();
    wi = WalletInterface(listen: false);
    pending = nftContracts.initialize();
    _initialize = initialize();
  }

  Future<NFTData> initialize() async
  {
    print("\x1B[31m${"INITIALIZE STARTED"}\x1B[0m");
    Map contracts = await nftContracts.initialize();

    if(contracts.length == 0)
      return NFTData(lastSelected: {}, contracts: {}, collection: {});
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

      int totalSupply = (await erc721.totalSupply()).toInt();
      print("\x1B[34m${"Total Supply [$tokenName]: $totalSupply"}\x1B[0m");
      if(totalSupply == 0) {
        print("\x1B[33m${"[Warning]: The NFT contract $tokenName returned 0 at Total Supply."}\x1B[0m");
        continue;
      }

      //Requesting the NFT catalog
      List _tokenNfts = [];

      //Generating placeholders
      int generate = 5;
      for(var i = 0; i < generate; i++)
      {
        String dim = "";
        if(i < 10)
          dim = "30$i";
        else if (i < 99)
          dim = "3$i";
        else
          dim = i.toString();
        int rndToken = (Random().nextInt(100000) + i);
        _tokenNfts.add(
          {
            "name" : "Generic Image from API #$i",
            "title" : "Generic Image from API #$i",
            "tokenId" : "$rndToken",
            "tokenName" : tokenName,
            "imageUrl" : 'https://picsum.photos/$dim/$dim',
            "properties" : {
              "description" : {
                "type" : "string",
                "description" : "lorem ipsum quia da la si ad met, lorem ipsum quia daaaa la si ad met, looooooorem ipsuuuum quia DAAAAAAAAAAAAAAAAAAAAA... album [USA] from anamanaguchi song's name 'lorem ipsum'... I don't know, i just want to be happy or have a beautiful girlfriend or something to be proud of, but i guess life is cock and ball torture, but without cock and ball... all i do is try to speak to you, but time moves me forward separating me fr-, all i do is try to speak to-..."
              }
            }
          }
        );
      }

      for(int l = 0; l < totalSupply; l++)
      {
        BigInt _id = await erc721.tokenByIndex(BigInt.from(l));
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
      lastSelected: _metadata.entries.first.value[0]
    );
    this._galleryData = NFTData(
      contracts: contracts,
      collection: _metadata,
      lastSelected: _metadata.entries.first.value[0]
    );

    return this.galleryData;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    nftManagementState = setState;
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      child: Container(
        color: AppColors.darkBlue,
        child: Column(
          children: [
            Expanded(
              flex: 10,
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

                    return NFTBigPicture(
                      nftData: galleryData,
                      filter: showFilters,
                      addContract: newNFTToken,
                      pageState: setState,
                    );
                    // else
                    // {
                    //   return FadeIndexedStack(
                    //     index: selectedGallery,
                    //     children: [
                    //       NFTBigPicture(
                    //         nftData: galleryData,
                    //         filter: showFilters,
                    //         addContract: newNFTToken,
                    //         pageState: setState,
                    //       ),
                    //       gallery(galleryData)
                    //     ],
                    //   );
                    // }
                  },
                )
              ),
            ),
            ///Old grid selection
            // Expanded(
            //   flex: 1,
            //   child: Row(
            //     children: [
            //       Expanded(
            //         child: Container(
            //           child: AppIconButton(
            //             icon: Icon(Icons.list),
            //             onPressed: () {
            //               if(this.selectedGallery != 0) {
            //                 setState((){
            //                   this.selectedGallery = 0;
            //                 });
            //               }
            //             },
            //           ),
            //         )
            //       ),
            //       SizedBox(
            //         height: 20,
            //         width: 2,
            //         child: Container(
            //           color: Colors.white.withOpacity(0.2),
            //         ),
            //       ),
            //       Expanded(
            //           child: Container(
            //             child: AppIconButton(
            //               icon: Icon(Icons.grid_view),
            //               onPressed: () {
            //                 if(this.selectedGallery != 1) {
            //                   setState((){
            //                     this.selectedGallery = 1;
            //                   });
            //                 }
            //               },
            //             ),
            //           )
            //       ),
            //     ],
            //   ),
            // ),
            // AppButton(onPressed: () => setState((){}), text: "force update")
          ],
        ),
      )
    );
  }

  Widget introduction()
  {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            LabelText("You haven't added any NFT Token Contract..."),
            SizedBox(height: SizeConfig.safeBlockVertical * 2,),
            AppButton(
              expanded: false,
              onPressed: () => newNFTToken(setState),
              text: "Add NFT Contract",
            )
          ],
        ),
      ],
    );
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

  void applyFilters()
  {
    String selectedToken = tokenDropdownValue == defaultDropdownValue
      ? ""
      : tokenDropdownValue;

    String filterText = filterController.text.trim();
    print("TAMANHO ${filterText.length}");
    print("ORIGINAL: ${_galleryData.collection}");
    if(selectedToken.length == 0 && filterText.length == 0)
    {
      setState(() {
        galleryData = _galleryData;
      });
      return;
    }

    NFTData filtered = _galleryData.applyFilter(selectedToken, filterText);

    print(filtered.collection.keys);

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
                children:
                [
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
  final StateSetter pageState;
  const NFTBigPicture({
    Key key,
    @required this.nftData,
    @required this.filter,
    @required this.addContract,
    @required this.pageState,
  }) : super(key: key);

  @override
  _NFTBigPictureState createState() => _NFTBigPictureState();
}

class _NFTBigPictureState extends State<NFTBigPicture> {

  int selectedGallery = 0;
  Map bigPicture = {};
  int gridSize = 4;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    ///List of token images/logo
    Map<String, String> images = {};
    Map<String, String> symbol = {};
    ///List of NFTs
    List<Map> nfts = [];
    widget.nftData.collection.forEach((String key, List list){
      list.forEach((element) => nfts.add(element));
      images[key] = widget.nftData.contracts[key]["logo"];
      symbol[key] = widget.nftData.contracts[key]["symbol"];
    });

    return Column(
      children: [
        nftDisplay(),
        Expanded(
          flex: 0,
          child: Container(
            color: Colors.red,
          ),
        ),
        nftSelection(
          nfts: nfts,
          symbol: symbol,
          images: images,
        ),
        viewport()
      ],
    );
  }

  Widget nftDisplay()
  {
    return Expanded(
      flex: 12,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FadeBigPicture(
            data: this.bigPicture.length > 0
              ? this.bigPicture
              : widget.nftData.lastSelected,
          ),
          Column(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  color: AppColors.darkBlue.withOpacity(0.4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AppIconButton(onPressed: () => widget.filter(),
                          icon: Icon(Icons.search)),
                      SizedBox(
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
                                    widget.addContract(widget.pageState);
                                    break;
                                }
                              },
                              itemBuilder: (context) =>
                              [
                                PopupMenuItem(
                                  child: Text("Add Contract"),
                                  value: 0,
                                ),
                              ]
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 10,
                child: Container(),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget nftSelection(
    {
      @required List<Map> nfts,
      @required Map symbol,
      @required Map images,
    }
  )
  {
    return Expanded(
      flex: 8,
      child: Container(
        // color: Colors.red,
        child: FadeIndexedStack(
          index: selectedGallery,
          children: [
            gridGallery(
              nfts: nfts,
              symbol: symbol,
              images: images,
              gridSize: gridSize
            ),
            listGallery(
              nfts: nfts,
              symbol: symbol,
              images: images,
            ),
          ],
        ),
      ),
    );
  }

  Widget viewport()
  {
    return Expanded(
      flex: 2,
      child: Row(
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
      ),
    );
  }


  Widget gridGallery({
    @required Map<String, String> images,
    @required Map<String, String> symbol,
    @required List<Map> nfts,
    gridSize = 1
  })
  {
    return Padding(
      padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 3.33).copyWith(
        bottom: 0
      ),
      child: Row(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: SizeConfig.safeBlockHorizontal * 3.33,
                mainAxisSpacing: SizeConfig.safeBlockHorizontal * 3.33,
                crossAxisCount: gridSize,
                childAspectRatio: (gridSize % 2 == 0 ? 1 : 3/4)
              ),
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: nfts.length,
              itemBuilder: (_, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if(this.bigPicture !=nfts[index])
                            setState(() {
                              this.bigPicture = nfts[index];
                            });
                        },
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
                                    cachedImage(nfts[index]['imageUrl'], fit: BoxFit.cover),
                                    Padding(
                                      padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 1.33),
                                      child: Column(
                                        children: [
                                          Flexible(
                                            child: Align(
                                              alignment: Alignment.topRight,
                                              child: textOutline(
                                                  "#${nfts[index]["tokenId"]}",
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
                                                    nfts[index]["tokenName"],
                                                    fontSize: 12
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: SizeConfig.blockSizeHorizontal * 4,
                                                  height: SizeConfig.blockSizeHorizontal * 4,
                                                  child: resolveImage(
                                                    images[nfts[index]["tokenName"]],
                                                    width: SizeConfig.blockSizeHorizontal * 4,
                                                    height: SizeConfig.blockSizeHorizontal * 4,
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
                );
              }),
          ),
        ],
      ),
    );
  }


  ///Render list as rows
  Widget listGallery({
    @required Map<String, String> images,
    @required Map<String, String> symbol,
    @required List<Map> nfts
  })
  {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: nfts.length,
      itemBuilder: (_, index) =>
        Column(
          children: [
            GestureDetector(
              onTap: () {
                if(this.bigPicture !=nfts[index])
                  setState(() {
                    this.bigPicture = nfts[index];
                  });
              },
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
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  cachedImage(
                                    nfts[index]['imageUrl'],
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
                                              "#${nfts[index]["tokenId"]}",
                                              fontSize: 12
                                            )
                                          )
                                        ),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.bottomRight,
                                            child: SizedBox(
                                              width: SizeConfig.blockSizeHorizontal * 4,
                                              height: SizeConfig.blockSizeHorizontal * 4,
                                              child: resolveImage(
                                                images[nfts[index]["tokenName"]],
                                                width: SizeConfig.blockSizeHorizontal * 4,
                                                height: SizeConfig.blockSizeHorizontal * 4,
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
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 1.33),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ///Title
                              Text(
                                nfts[index]["title"].replaceAll("", "\u{200B}"),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              ///Subtitle
                              Text(
                                nfts[index]["properties"]["description"]["description"].replaceAll("", "\u{200B}"),
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
                                symbol[nfts[index]["tokenName"]].replaceAll("", "\u{200B}"),
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
            index == (nfts.length - 1)
                ? Container()
                : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Divider(color: Colors.white,height: 0,),
            )
          ],
        )
    );
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

class FadeBigPicture extends StatefulWidget {

  final Map data;
  final Duration duration;
  final bool showDetails;
  const FadeBigPicture({
    Key key,
    this.showDetails = false,
    @required this.data,
    this.duration = const Duration(
      milliseconds: 750,
    )
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
                      flex: 2,
                      child: Container(),
                    ),
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
      print("collections");
      print(this.collection);
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
}