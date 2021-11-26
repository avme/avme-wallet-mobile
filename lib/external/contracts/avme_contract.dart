
// @dart=2.12
import 'package:web3dart/web3dart.dart' as web3dart;


class Avme extends web3dart.GeneratedContract {
  final web3dart.ContractAbi contractAbi;
  Avme(this.contractAbi,
      {required web3dart.EthereumAddress address,
        required web3dart.Web3Client client,
        int? chainId})
      : super(web3dart.DeployedContract(contractAbi, address), client, chainId);

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<bool> _devFeeEnabled({web3dart.BlockNum? atBlock}) async {
    final function = self.abi.functions[1];
    assert(checkSignature(function, '9eeb25b1'));
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as bool);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<web3dart.EthereumAddress> _dev_fee_address({web3dart.BlockNum? atBlock}) async {
    final function = self.abi.functions[2];
    assert(checkSignature(function, '8041a129'));
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as web3dart.EthereumAddress);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> _initialSupply({web3dart.BlockNum? atBlock}) async {
    final function = self.abi.functions[3];
    assert(checkSignature(function, 'c3b2d337'));
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as BigInt);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> _maxSupply({web3dart.BlockNum? atBlock}) async {
    final function = self.abi.functions[4];
    assert(checkSignature(function, '22f4596f'));
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as BigInt);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<web3dart.EthereumAddress> _minter({web3dart.BlockNum? atBlock}) async {
    final function = self.abi.functions[5];
    assert(checkSignature(function, '578ec33f'));
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as web3dart.EthereumAddress);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> allowance(
      web3dart.EthereumAddress _owner, web3dart.EthereumAddress _spender,
      {web3dart.BlockNum? atBlock}) async {
    final function = self.abi.functions[6];
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
    final function = self.abi.functions[7];
    assert(checkSignature(function, '095ea7b3'));
    final params = [_spender, _value];
    return write(credentials, transaction, function, params);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> balanceOf(web3dart.EthereumAddress _owner,
      {web3dart.BlockNum? atBlock}) async {
    final function = self.abi.functions[8];
    assert(checkSignature(function, '70a08231'));
    final params = [_owner];
    final response = await read(function, params, atBlock);
    return (response[0] as BigInt);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> burn(BigInt _amount,
      {required web3dart.Credentials credentials,
        web3dart.Transaction? transaction}) async {
    final function = self.abi.functions[9];
    assert(checkSignature(function, '42966c68'));
    final params = [_amount];
    return write(credentials, transaction, function, params);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> decimals({web3dart.BlockNum? atBlock}) async {
    final function = self.abi.functions[10];
    assert(checkSignature(function, '313ce567'));
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as BigInt);
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

  /// Returns a live stream of all Burned events emitted by this contract.
  Stream<Burned> burnedEvents(
      {web3dart.BlockNum? fromBlock, web3dart.BlockNum? toBlock}) {
    final event = self.event('Burned');
    final filter = web3dart.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((web3dart.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return Burned(decoded);
    });
  }

  /// Returns a live stream of all Minted events emitted by this contract.
  Stream<Minted> mintedEvents(
      {web3dart.BlockNum? fromBlock, web3dart.BlockNum? toBlock}) {
    final event = self.event('Minted');
    final filter = web3dart.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((web3dart.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return Minted(decoded);
    });
  }

  /// Returns a live stream of all SwitchedDevfee events emitted by this contract.
  Stream<SwitchedDevfee> switchedDevfeeEvents(
      {web3dart.BlockNum? fromBlock, web3dart.BlockNum? toBlock}) {
    final event = self.event('SwitchedDevfee');
    final filter = web3dart.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((web3dart.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return SwitchedDevfee(decoded);
    });
  }

  /// Returns a live stream of all ToggledDevFee events emitted by this contract.
  Stream<ToggledDevFee> toggledDevFeeEvents(
      {web3dart.BlockNum? fromBlock, web3dart.BlockNum? toBlock}) {
    final event = self.event('ToggledDevFee');
    final filter = web3dart.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((web3dart.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return ToggledDevFee(decoded);
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

class Burned {
  Burned(List<dynamic> response)
      : from = (response[0] as web3dart.EthereumAddress),
        value = (response[1] as BigInt);

  final web3dart.EthereumAddress from;

  final BigInt value;
}

class Minted {
  Minted(List<dynamic> response)
      : to = (response[0] as web3dart.EthereumAddress),
        value = (response[1] as BigInt);

  final web3dart.EthereumAddress to;

  final BigInt value;
}

class SwitchedDevfee {
  SwitchedDevfee(List<dynamic> response)
      : oldaddress = (response[0] as web3dart.EthereumAddress),
        newaddress = (response[1] as web3dart.EthereumAddress);

  final web3dart.EthereumAddress oldaddress;

  final web3dart.EthereumAddress newaddress;
}

class ToggledDevFee {
  ToggledDevFee(List<dynamic> response) : devfeeStatus = (response[0] as bool);

  final bool devfeeStatus;
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
