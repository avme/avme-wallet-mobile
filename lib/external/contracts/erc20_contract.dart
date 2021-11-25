// @dart=2.12
import 'package:web3dart/web3dart.dart' as web3dart;

class ERC20 extends web3dart.GeneratedContract {

  final web3dart.ContractAbi contractAbi;

  ERC20(this.contractAbi, {
    required web3dart.EthereumAddress address,
    required web3dart.Web3Client client,
    int? chainId}
    ) : super(web3dart.DeployedContract(contractAbi, address), client, chainId);

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> allowance(
      web3dart.EthereumAddress _owner, web3dart.EthereumAddress _spender,
      {web3dart.BlockNum? atBlock}) async {
    final function = self.abi.functions.where((element) => element.name == "allowance").first;
    assert(checkSignature(function, 'dd62ed3e'));
    final params = [_owner, _spender];
    final response = await read(function, params, atBlock);
    return (response[0] as BigInt);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> approve(web3dart.EthereumAddress _spender, BigInt _value,
      {required web3dart.Credentials credentials,
        web3dart.Transaction? transaction}) async {
    final function = self.abi.functions.where((element) => element.name == "approve").first;
    assert(checkSignature(function, '095ea7b3'));
    final params = [_spender, _value];
    return write(credentials, transaction, function, params);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> balanceOf(web3dart.EthereumAddress _owner,
      {web3dart.BlockNum? atBlock}) async {
    final function = self.abi.functions.where((element) => element.name == "balanceOf").first;
    assert(checkSignature(function, '70a08231'));
    final params = [_owner];
    final response = await read(function, params, atBlock);
    return (response[0] as BigInt);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> decimals({web3dart.BlockNum? atBlock}) async {
    final function = self.abi.functions.where((element) => element.name == "decimals").first;
    assert(checkSignature(function, '313ce567'));
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as BigInt);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<String> name({web3dart.BlockNum? atBlock}) async {
    final function = self.abi.functions.where((element) => element.name == "name").first;
    assert(checkSignature(function, '06fdde03'));
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as String);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<String> symbol({web3dart.BlockNum? atBlock}) async {
    final function = self.abi.functions.where((element) => element.name == "symbol").first;
    assert(checkSignature(function, '95d89b41'));
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as String);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> totalSupply({web3dart.BlockNum? atBlock}) async {
    final function = self.abi.functions.where((element) => element.name == "totalSupply").first;
    assert(checkSignature(function, '18160ddd'));
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as BigInt);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> transfer(web3dart.EthereumAddress _to, BigInt _value,
      {required web3dart.Credentials credentials,
        web3dart.Transaction? transaction}) async {
    final function = self.abi.functions.where((element) => element.name == "transfer").first;
    assert(checkSignature(function, 'a9059cbb'));
    final params = [_to, _value];
    return write(credentials, transaction, function, params);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> transferFrom(
      web3dart.EthereumAddress _from, web3dart.EthereumAddress _to, BigInt _value,
      {required web3dart.Credentials credentials,
        web3dart.Transaction? transaction}) async {
    final function = self.abi.functions.where((element) => element.name == "transferFrom").first;
    assert(checkSignature(function, '23b872dd'));
    final params = [_from, _to, _value];
    return write(credentials, transaction, function, params);
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
        spender = (response[1] as web3dart.EthereumAddress),
        value = (response[2] as BigInt);

  final web3dart.EthereumAddress owner;

  final web3dart.EthereumAddress spender;

  final BigInt value;
}

class Transfer {
  Transfer(List<dynamic> response)
      : from = (response[0] as web3dart.EthereumAddress),
        to = (response[1] as web3dart.EthereumAddress),
        value = (response[2] as BigInt);

  final web3dart.EthereumAddress from;

  final web3dart.EthereumAddress to;

  final BigInt value;
}
