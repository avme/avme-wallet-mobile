// @dart=2.12
import 'package:web3dart/web3dart.dart';

class AvmeContract extends GeneratedContract {
  AvmeContract(
      {required EthereumAddress address,
        required Web3Client client,
        int? chainId})
      : super(
      DeployedContract(
          ContractAbi.fromJson(
              '[{"type":"constructor","stateMutability":"nonpayable","inputs":[]},{"type":"event","name":"Approval","inputs":[{"type":"address","name":"_owner","internalType":"address","indexed":true},{"type":"address","name":"_spender","internalType":"address","indexed":true},{"type":"uint256","name":"_value","internalType":"uint256","indexed":false}],"anonymous":false},{"type":"event","name":"Burned","inputs":[{"type":"address","name":"_from","internalType":"address","indexed":true},{"type":"uint256","name":"_value","internalType":"uint256","indexed":false}],"anonymous":false},{"type":"event","name":"Minted","inputs":[{"type":"address","name":"_to","internalType":"address","indexed":true},{"type":"uint256","name":"_value","internalType":"uint256","indexed":false}],"anonymous":false},{"type":"event","name":"SwitchedDevfee","inputs":[{"type":"address","name":"_old","internalType":"address","indexed":true},{"type":"address","name":"novo","internalType":"address","indexed":true}],"anonymous":false},{"type":"event","name":"SwitchedMinter","inputs":[{"type":"address","name":"_old","internalType":"address","indexed":true},{"type":"address","name":"novo","internalType":"address","indexed":true}],"anonymous":false},{"type":"event","name":"ToggledDevFee","inputs":[{"type":"bool","name":"_devfeeStatus","internalType":"bool","indexed":false}],"anonymous":false},{"type":"event","name":"Transfer","inputs":[{"type":"address","name":"_from","internalType":"address","indexed":true},{"type":"address","name":"_to","internalType":"address","indexed":true},{"type":"uint256","name":"_value","internalType":"uint256","indexed":false}],"anonymous":false},{"type":"function","stateMutability":"view","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"_devFeeEnabled","inputs":[]},{"type":"function","stateMutability":"view","outputs":[{"type":"address","name":"","internalType":"address"}],"name":"_dev_fee_address","inputs":[]},{"type":"function","stateMutability":"view","outputs":[{"type":"uint256","name":"","internalType":"uint256"}],"name":"_initialSupply","inputs":[]},{"type":"function","stateMutability":"view","outputs":[{"type":"uint256","name":"","internalType":"uint256"}],"name":"_maxSupply","inputs":[]},{"type":"function","stateMutability":"view","outputs":[{"type":"address","name":"","internalType":"address"}],"name":"_minter","inputs":[]},{"type":"function","stateMutability":"view","outputs":[{"type":"uint256","name":"","internalType":"uint256"}],"name":"allowance","inputs":[{"type":"address","name":"_owner","internalType":"address"},{"type":"address","name":"_spender","internalType":"address"}]},{"type":"function","stateMutability":"nonpayable","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"approve","inputs":[{"type":"address","name":"_spender","internalType":"address"},{"type":"uint256","name":"_value","internalType":"uint256"}]},{"type":"function","stateMutability":"view","outputs":[{"type":"uint256","name":"","internalType":"uint256"}],"name":"balanceOf","inputs":[{"type":"address","name":"_owner","internalType":"address"}]},{"type":"function","stateMutability":"nonpayable","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"burn","inputs":[{"type":"uint256","name":"_amount","internalType":"uint256"}]},{"type":"function","stateMutability":"view","outputs":[{"type":"uint8","name":"","internalType":"uint8"}],"name":"decimals","inputs":[]},{"type":"function","stateMutability":"nonpayable","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"mint","inputs":[{"type":"address","name":"_to","internalType":"address"},{"type":"uint256","name":"_amount","internalType":"uint256"}]},{"type":"function","stateMutability":"view","outputs":[{"type":"string","name":"","internalType":"string"}],"name":"name","inputs":[]},{"type":"function","stateMutability":"nonpayable","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"switchDevfee","inputs":[{"type":"address","name":"_new_dev_fee_address","internalType":"address"}]},{"type":"function","stateMutability":"nonpayable","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"switchMinter","inputs":[{"type":"address","name":"_newMinter","internalType":"address"}]},{"type":"function","stateMutability":"view","outputs":[{"type":"string","name":"","internalType":"string"}],"name":"symbol","inputs":[]},{"type":"function","stateMutability":"nonpayable","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"toggleDevfee","inputs":[{"type":"bool","name":"_devfeeStatus","internalType":"bool"}]},{"type":"function","stateMutability":"view","outputs":[{"type":"uint256","name":"","internalType":"uint256"}],"name":"totalSupply","inputs":[]},{"type":"function","stateMutability":"nonpayable","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"transfer","inputs":[{"type":"address","name":"_to","internalType":"address"},{"type":"uint256","name":"_value","internalType":"uint256"}]},{"type":"function","stateMutability":"nonpayable","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"transferFrom","inputs":[{"type":"address","name":"_from","internalType":"address"},{"type":"address","name":"_to","internalType":"address"},{"type":"uint256","name":"_value","internalType":"uint256"}]}]',
              'Avme'),
          address),
      client,
      chainId);

  Future<bool> _devFeeEnabled() async {
    final function = self.function('_devFeeEnabled');
    final params = [];
    final response = await read(function, params);
    return (response[0] as bool);
  }

  Future<EthereumAddress> _dev_fee_address() async {
    final function = self.function('_dev_fee_address');
    final params = [];
    final response = await read(function, params);
    return (response[0] as EthereumAddress);
  }

  Future<BigInt> _initialSupply() async {
    final function = self.function('_initialSupply');
    final params = [];
    final response = await read(function, params);
    return (response[0] as BigInt);
  }

  Future<BigInt> _maxSupply() async {
    final function = self.function('_maxSupply');
    final params = [];
    final response = await read(function, params);
    return (response[0] as BigInt);
  }

  Future<EthereumAddress> _minter() async {
    final function = self.function('_minter');
    final params = [];
    final response = await read(function, params);
    return (response[0] as EthereumAddress);
  }

  Future<BigInt> allowance(
      EthereumAddress _owner, EthereumAddress _spender) async {
    final function = self.function('allowance');
    final params = [_owner, _spender];
    final response = await read(function, params);
    return (response[0] as BigInt);
  }

  Future<String> approve(EthereumAddress _spender, BigInt _value,
      {required Credentials credentials}) async {
    final function = self.function('approve');
    final params = [_spender, _value];
    final transaction = Transaction.callContract(
        contract: self, function: function, parameters: params);
    return write(credentials, transaction);
  }

  Future<BigInt> balanceOf(EthereumAddress _owner) async {
    final function = self.function('balanceOf');
    final params = [_owner];
    final response = await read(function, params);
    return (response[0] as BigInt);
  }

  Future<String> burn(BigInt _amount,
      {required Credentials credentials}) async {
    final function = self.function('burn');
    final params = [_amount];
    final transaction = Transaction.callContract(
        contract: self, function: function, parameters: params);
    return write(credentials, transaction);
  }

  Future<BigInt> decimals() async {
    final function = self.function('decimals');
    final params = [];
    final response = await read(function, params);
    return (response[0] as BigInt);
  }

  Future<String> mint(EthereumAddress _to, BigInt _amount,
      {required Credentials credentials}) async {
    final function = self.function('mint');
    final params = [_to, _amount];
    final transaction = Transaction.callContract(
        contract: self, function: function, parameters: params);
    return write(credentials, transaction);
  }

  Future<String> name() async {
    final function = self.function('name');
    final params = [];
    final response = await read(function, params);
    return (response[0] as String);
  }

  Future<String> switchDevfee(EthereumAddress _new_dev_fee_address,
      {required Credentials credentials}) async {
    final function = self.function('switchDevfee');
    final params = [_new_dev_fee_address];
    final transaction = Transaction.callContract(
        contract: self, function: function, parameters: params);
    return write(credentials, transaction);
  }

  Future<String> switchMinter(EthereumAddress _newMinter,
      {required Credentials credentials}) async {
    final function = self.function('switchMinter');
    final params = [_newMinter];
    final transaction = Transaction.callContract(
        contract: self, function: function, parameters: params);
    return write(credentials, transaction);
  }

  Future<String> symbol() async {
    final function = self.function('symbol');
    final params = [];
    final response = await read(function, params);
    return (response[0] as String);
  }

  Future<String> toggleDevfee(bool _devfeeStatus,
      {required Credentials credentials}) async {
    final function = self.function('toggleDevfee');
    final params = [_devfeeStatus];
    final transaction = Transaction.callContract(
        contract: self, function: function, parameters: params);
    return write(credentials, transaction);
  }

  Future<BigInt> totalSupply() async {
    final function = self.function('totalSupply');
    final params = [];
    final response = await read(function, params);
    return (response[0] as BigInt);
  }
  /// Returns a Web3 transaction object to be signed
  Future<Transaction> transfer({
    required EthereumAddress to,
    required BigInt value,
    required Credentials credentials,
    // required EtherAmount gasPrice,
    // required int maxGas
    }) async {
    final function = self.function('transfer');
    final params = [to, value];
    final transaction = Transaction.callContract(
        contract: self, function: function, parameters: params,
        // gasPrice: gasPrice, maxGas: maxGas
    );
    return transaction;

    // return write(credentials, transaction);
  }

  Future<String> transferFrom(
      EthereumAddress _from, EthereumAddress _to, BigInt _value,
      {required Credentials credentials}) async {
    final function = self.function('transferFrom');
    final params = [_from, _to, _value];
    final transaction = Transaction.callContract(
        contract: self, function: function, parameters: params);
    return write(credentials, transaction);
  }

  /// Returns a live stream of all Approval events emitted by this contract.
  Stream<Approval> approvalEvents(
      {BlockNum? fromBlock, BlockNum? toBlock}) {
    final event = self.event('Approval');
    final filter = FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return Approval(decoded);
    });
  }

  /// Returns a live stream of all Burned events emitted by this contract.
  Stream<Burned> burnedEvents(
      {BlockNum? fromBlock, BlockNum? toBlock}) {
    final event = self.event('Burned');
    final filter = FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return Burned(decoded);
    });
  }

  /// Returns a live stream of all Minted events emitted by this contract.
  Stream<Minted> mintedEvents(
      {BlockNum? fromBlock, BlockNum? toBlock}) {
    final event = self.event('Minted');
    final filter = FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return Minted(decoded);
    });
  }

  /// Returns a live stream of all SwitchedDevfee events emitted by this contract.
  Stream<SwitchedDevfee> switchedDevfeeEvents(
      {BlockNum? fromBlock, BlockNum? toBlock}) {
    final event = self.event('SwitchedDevfee');
    final filter = FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return SwitchedDevfee(decoded);
    });
  }

  /// Returns a live stream of all SwitchedMinter events emitted by this contract.
  Stream<SwitchedMinter> switchedMinterEvents(
      {BlockNum? fromBlock, BlockNum? toBlock}) {
    final event = self.event('SwitchedMinter');
    final filter = FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return SwitchedMinter(decoded);
    });
  }

  /// Returns a live stream of all ToggledDevFee events emitted by this contract.
  Stream<ToggledDevFee> toggledDevFeeEvents(
      {BlockNum? fromBlock, BlockNum? toBlock}) {
    final event = self.event('ToggledDevFee');
    final filter = FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return ToggledDevFee(decoded);
    });
  }

  /// Returns a live stream of all Transfer events emitted by this contract.
  Stream<Transfer> transferEvents(
      {BlockNum? fromBlock, BlockNum? toBlock}) {
    final event = self.event('Transfer');
    final filter = FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return Transfer(decoded);
    });
  }
}

class Approval {
  Approval(List<dynamic> response)
      : owner = (response[0] as EthereumAddress),
        spender = (response[1] as EthereumAddress),
        value = (response[2] as BigInt);

  final EthereumAddress owner;

  final EthereumAddress spender;

  final BigInt value;
}

class Burned {
  Burned(List<dynamic> response)
      : from = (response[0] as EthereumAddress),
        value = (response[1] as BigInt);

  final EthereumAddress from;

  final BigInt value;
}

class Minted {
  Minted(List<dynamic> response)
      : to = (response[0] as EthereumAddress),
        value = (response[1] as BigInt);

  final EthereumAddress to;

  final BigInt value;
}

class SwitchedDevfee {
  SwitchedDevfee(List<dynamic> response)
      : old = (response[0] as EthereumAddress),
        _new = (response[1] as EthereumAddress);

  final EthereumAddress old;

  final EthereumAddress _new;
}

class SwitchedMinter {
  SwitchedMinter(List<dynamic> response)
      : old = (response[0] as EthereumAddress),
        _new = (response[1] as EthereumAddress);

  final EthereumAddress old;

  final EthereumAddress _new;
}

class ToggledDevFee {
  ToggledDevFee(List<dynamic> response) : devfeeStatus = (response[0] as bool);

  final bool devfeeStatus;
}

class Transfer {
  Transfer(List<dynamic> response)
      : from = (response[0] as EthereumAddress),
        to = (response[1] as EthereumAddress),
        value = (response[2] as BigInt);

  final EthereumAddress from;

  final EthereumAddress to;

  final BigInt value;
}
