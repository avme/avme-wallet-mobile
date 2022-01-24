// Generated code, do not modify. Run `build_runner build` to re-generate!
// @dart=2.12
import 'package:web3dart/web3dart.dart' as web3dart;
import 'dart:typed_data' as typedData;

class ERC721 extends web3dart.GeneratedContract {

  final web3dart.ContractAbi contractAbi;

  ERC721(this.contractAbi,
      {required web3dart.EthereumAddress address,
      required web3dart.Web3Client client,
      int? chainId})
      : super(web3dart.DeployedContract(contractAbi, address), client, chainId);

  /// See {IERC721-approve}.
  ///
  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> approve(web3dart.EthereumAddress to, BigInt tokenId,
      {required web3dart.Credentials credentials,
      web3dart.Transaction? transaction}) async {
    final function = self.abi.functions[1];
    assert(checkSignature(function, '095ea7b3'));
    final params = [to, tokenId];
    return write(credentials, transaction, function, params);
  }

  /// See {IERC721-balanceOf}.
  ///
  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> balanceOf(web3dart.EthereumAddress owner,
      {web3dart.BlockNum? atBlock}) async {
    final function = self.abi.functions[2];
    assert(checkSignature(function, '70a08231'));
    final params = [owner];
    final response = await read(function, params, atBlock);
    return (response[0] as BigInt);
  }

  /// See {IERC721-getApproved}.
  ///
  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<web3dart.EthereumAddress> getApproved(BigInt tokenId,
      {web3dart.BlockNum? atBlock}) async {
    final function = self.abi.functions[3];
    assert(checkSignature(function, '081812fc'));
    final params = [tokenId];
    final response = await read(function, params, atBlock);
    return (response[0] as web3dart.EthereumAddress);
  }

  /// See {IERC721-isApprovedForAll}.
  ///
  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<bool> isApprovedForAll(
      web3dart.EthereumAddress owner, web3dart.EthereumAddress operator,
      {web3dart.BlockNum? atBlock}) async {
    final function = self.abi.functions[4];
    assert(checkSignature(function, 'e985e9c5'));
    final params = [owner, operator];
    final response = await read(function, params, atBlock);
    return (response[0] as bool);
  }

  /// See {IERC721Metadata-name}.
  ///
  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<String> name({web3dart.BlockNum? atBlock}) async {
    final function = self.abi.functions[5];
    assert(checkSignature(function, '06fdde03'));
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as String);
  }

  /// See {IERC721-ownerOf}.
  ///
  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<web3dart.EthereumAddress> ownerOf(BigInt tokenId,
      {web3dart.BlockNum? atBlock}) async {
    final function = self.abi.functions[6];
    assert(checkSignature(function, '6352211e'));
    final params = [tokenId];
    final response = await read(function, params, atBlock);
    return (response[0] as web3dart.EthereumAddress);
  }

  /// See {IERC721-safeTransferFrom}.
  ///
  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> safeTransferFrom(
      web3dart.EthereumAddress from, web3dart.EthereumAddress to, BigInt tokenId,
      {required web3dart.Credentials credentials,
      web3dart.Transaction? transaction}) async {
    final function = self.abi.functions[7];
    assert(checkSignature(function, '42842e0e'));
    final params = [from, to, tokenId];
    return write(credentials, transaction, function, params);
  }

  /// See {IERC721-safeTransferFrom}.
  ///
  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> safeTransferFrom$2(web3dart.EthereumAddress from,
      web3dart.EthereumAddress to, BigInt tokenId, typedData.Uint8List _data,
      {required web3dart.Credentials credentials,
      web3dart.Transaction? transaction}) async {
    final function = self.abi.functions[8];
    assert(checkSignature(function, 'b88d4fde'));
    final params = [from, to, tokenId, _data];
    return write(credentials, transaction, function, params);
  }

  /// See {IERC721-setApprovalForAll}.
  ///
  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> setApprovalForAll(web3dart.EthereumAddress operator, bool approved,
      {required web3dart.Credentials credentials,
      web3dart.Transaction? transaction}) async {
    final function = self.abi.functions[9];
    assert(checkSignature(function, 'a22cb465'));
    final params = [operator, approved];
    return write(credentials, transaction, function, params);
  }

  /// See {IERC721Metadata-symbol}.
  ///
  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<String> symbol({web3dart.BlockNum? atBlock}) async {
    final function = self.abi.functions[10];
    assert(checkSignature(function, '95d89b41'));
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as String);
  }

  /// See {IERC721Enumerable-tokenByIndex}.
  ///
  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> tokenByIndex(BigInt index, {web3dart.BlockNum? atBlock}) async {
    final function = self.abi.functions[11];
    assert(checkSignature(function, '4f6ccce7'));
    final params = [index];
    final response = await read(function, params, atBlock);
    return (response[0] as BigInt);
  }

  /// See {IERC721Enumerable-tokenOfOwnerByIndex}.
  ///
  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> tokenOfOwnerByIndex(web3dart.EthereumAddress owner, BigInt index,
      {web3dart.BlockNum? atBlock}) async {
    final function = self.abi.functions[12];
    assert(checkSignature(function, '2f745c59'));
    final params = [owner, index];
    final response = await read(function, params, atBlock);
    return (response[0] as BigInt);
  }

  /// See {IERC721Enumerable-totalSupply}.
  ///
  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> totalSupply({web3dart.BlockNum? atBlock}) async {
    final function = self.abi.functions[13];
    assert(checkSignature(function, '18160ddd'));
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as BigInt);
  }

  /// See {IERC721-transferFrom}.
  ///
  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> transferFrom(
      web3dart.EthereumAddress from, web3dart.EthereumAddress to, BigInt tokenId,
      {required web3dart.Credentials credentials,
      web3dart.Transaction? transaction}) async {
    final function = self.abi.functions[14];
    assert(checkSignature(function, '23b872dd'));
    final params = [from, to, tokenId];
    return write(credentials, transaction, function, params);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> mint(String _color,
      {required web3dart.Credentials credentials,
      web3dart.Transaction? transaction}) async {
    final function = self.abi.functions[15];
    assert(checkSignature(function, 'd85d3d27'));
    final params = [_color];
    return write(credentials, transaction, function, params);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<bool> supportsInterface(typedData.Uint8List interfaceId,
      {web3dart.BlockNum? atBlock}) async {
    final function = self.abi.functions[16];
    assert(checkSignature(function, '01ffc9a7'));
    final params = [interfaceId];
    final response = await read(function, params, atBlock);
    return (response[0] as bool);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<String> tokenURI(BigInt tokenId, {web3dart.BlockNum? atBlock}) async {
    final function = self.abi.functions[17];
    assert(checkSignature(function, 'c87b56dd'));
    final params = [tokenId];
    final response = await read(function, params, atBlock);
    return (response[0] as String);
  }

  /// Returns a live stream of all Approval events emitted by this contract.
  Stream<Approval> approvalEvents(
      {web3dart.BlockNum? fromBlock, web3dart.BlockNum? toBlock}) {
    final event = self.event('Approval');
    final filter = web3dart.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((web3dart.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return Approval(decoded);
    });
  }

  /// Returns a live stream of all ApprovalForAll events emitted by this contract.
  Stream<ApprovalForAll> approvalForAllEvents(
      {web3dart.BlockNum? fromBlock, web3dart.BlockNum? toBlock}) {
    final event = self.event('ApprovalForAll');
    final filter = web3dart.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((web3dart.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return ApprovalForAll(decoded);
    });
  }

  /// Returns a live stream of all Transfer events emitted by this contract.
  Stream<Transfer> transferEvents(
      {web3dart.BlockNum? fromBlock, web3dart.BlockNum? toBlock}) {
    final event = self.event('Transfer');
    final filter = web3dart.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((web3dart.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return Transfer(decoded);
    });
  }
}

class Approval {
  Approval(List<dynamic> response)
      : owner = (response[0] as web3dart.EthereumAddress),
        approved = (response[1] as web3dart.EthereumAddress),
        tokenId = (response[2] as BigInt);

  final web3dart.EthereumAddress owner;

  final web3dart.EthereumAddress approved;

  final BigInt tokenId;
}

class ApprovalForAll {
  ApprovalForAll(List<dynamic> response)
      : owner = (response[0] as web3dart.EthereumAddress),
        operator = (response[1] as web3dart.EthereumAddress),
        approved = (response[2] as bool);

  final web3dart.EthereumAddress owner;

  final web3dart.EthereumAddress operator;

  final bool approved;
}

class Transfer {
  Transfer(List<dynamic> response)
      : from = (response[0] as web3dart.EthereumAddress),
        to = (response[1] as web3dart.EthereumAddress),
        tokenId = (response[2] as BigInt);

  final web3dart.EthereumAddress from;

  final web3dart.EthereumAddress to;

  final BigInt tokenId;
}
