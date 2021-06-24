// Generated code, do not modify. Run `build_runner build` to re-generate!
// @dart=2.12
import 'package:web3dart/web3dart.dart' as _i1;

class AvmeContract extends _i1.GeneratedContract {
  AvmeContract(
      {required _i1.EthereumAddress address,
      required _i1.Web3Client client,
      int? chainId})
      : super(
            _i1.DeployedContract(
                _i1.ContractAbi.fromJson(
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

  Future<_i1.EthereumAddress> _dev_fee_address() async {
    final function = self.function('_dev_fee_address');
    final params = [];
    final response = await read(function, params);
    return (response[0] as _i1.EthereumAddress);
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

  Future<_i1.EthereumAddress> _minter() async {
    final function = self.function('_minter');
    final params = [];
    final response = await read(function, params);
    return (response[0] as _i1.EthereumAddress);
  }

  Future<BigInt> allowance(
      _i1.EthereumAddress _owner, _i1.EthereumAddress _spender) async {
    final function = self.function('allowance');
    final params = [_owner, _spender];
    final response = await read(function, params);
    return (response[0] as BigInt);
  }

  Future<String> approve(_i1.EthereumAddress _spender, BigInt _value,
      {required _i1.Credentials credentials}) async {
    final function = self.function('approve');
    final params = [_spender, _value];
    final transaction = _i1.Transaction.callContract(
        contract: self, function: function, parameters: params);
    return write(credentials, transaction);
  }

  Future<BigInt> balanceOf(_i1.EthereumAddress _owner) async {
    final function = self.function('balanceOf');
    final params = [_owner];
    final response = await read(function, params);
    return (response[0] as BigInt);
  }

  Future<String> burn(BigInt _amount,
      {required _i1.Credentials credentials}) async {
    final function = self.function('burn');
    final params = [_amount];
    final transaction = _i1.Transaction.callContract(
        contract: self, function: function, parameters: params);
    return write(credentials, transaction);
  }

  Future<BigInt> decimals() async {
    final function = self.function('decimals');
    final params = [];
    final response = await read(function, params);
    return (response[0] as BigInt);
  }

  Future<String> mint(_i1.EthereumAddress _to, BigInt _amount,
      {required _i1.Credentials credentials}) async {
    final function = self.function('mint');
    final params = [_to, _amount];
    final transaction = _i1.Transaction.callContract(
        contract: self, function: function, parameters: params);
    return write(credentials, transaction);
  }

  Future<String> name() async {
    final function = self.function('name');
    final params = [];
    final response = await read(function, params);
    return (response[0] as String);
  }

  Future<String> switchDevfee(_i1.EthereumAddress _new_dev_fee_address,
      {required _i1.Credentials credentials}) async {
    final function = self.function('switchDevfee');
    final params = [_new_dev_fee_address];
    final transaction = _i1.Transaction.callContract(
        contract: self, function: function, parameters: params);
    return write(credentials, transaction);
  }

  Future<String> switchMinter(_i1.EthereumAddress _newMinter,
      {required _i1.Credentials credentials}) async {
    final function = self.function('switchMinter');
    final params = [_newMinter];
    final transaction = _i1.Transaction.callContract(
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
      {required _i1.Credentials credentials}) async {
    final function = self.function('toggleDevfee');
    final params = [_devfeeStatus];
    final transaction = _i1.Transaction.callContract(
        contract: self, function: function, parameters: params);
    return write(credentials, transaction);
  }

  Future<BigInt> totalSupply() async {
    final function = self.function('totalSupply');
    final params = [];
    final response = await read(function, params);
    return (response[0] as BigInt);
  }

  Future<String> transfer(_i1.EthereumAddress _to, BigInt _value,
      {required _i1.Credentials credentials}) async {
    final function = self.function('transfer');
    final params = [_to, _value];
    final transaction = _i1.Transaction.callContract(
        contract: self, function: function, parameters: params);
    return write(credentials, transaction);
  }

  Future<String> transferFrom(
      _i1.EthereumAddress _from, _i1.EthereumAddress _to, BigInt _value,
      {required _i1.Credentials credentials}) async {
    final function = self.function('transferFrom');
    final params = [_from, _to, _value];
    final transaction = _i1.Transaction.callContract(
        contract: self, function: function, parameters: params);
    return write(credentials, transaction);
  }

  /// Returns a live stream of all Approval events emitted by this contract.
  Stream<Approval> approvalEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('Approval');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return Approval(decoded);
    });
  }

  /// Returns a live stream of all Burned events emitted by this contract.
  Stream<Burned> burnedEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('Burned');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return Burned(decoded);
    });
  }

  /// Returns a live stream of all Minted events emitted by this contract.
  Stream<Minted> mintedEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('Minted');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return Minted(decoded);
    });
  }

  /// Returns a live stream of all SwitchedDevfee events emitted by this contract.
  Stream<SwitchedDevfee> switchedDevfeeEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('SwitchedDevfee');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return SwitchedDevfee(decoded);
    });
  }

  /// Returns a live stream of all SwitchedMinter events emitted by this contract.
  Stream<SwitchedMinter> switchedMinterEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('SwitchedMinter');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return SwitchedMinter(decoded);
    });
  }

  /// Returns a live stream of all ToggledDevFee events emitted by this contract.
  Stream<ToggledDevFee> toggledDevFeeEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('ToggledDevFee');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return ToggledDevFee(decoded);
    });
  }

  /// Returns a live stream of all Transfer events emitted by this contract.
  Stream<Transfer> transferEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('Transfer');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return Transfer(decoded);
    });
  }
}

class Approval {
  Approval(List<dynamic> response)
      : owner = (response[0] as _i1.EthereumAddress),
        spender = (response[1] as _i1.EthereumAddress),
        value = (response[2] as BigInt);

  final _i1.EthereumAddress owner;

  final _i1.EthereumAddress spender;

  final BigInt value;
}

class Burned {
  Burned(List<dynamic> response)
      : from = (response[0] as _i1.EthereumAddress),
        value = (response[1] as BigInt);

  final _i1.EthereumAddress from;

  final BigInt value;
}

class Minted {
  Minted(List<dynamic> response)
      : to = (response[0] as _i1.EthereumAddress),
        value = (response[1] as BigInt);

  final _i1.EthereumAddress to;

  final BigInt value;
}

class SwitchedDevfee {
  SwitchedDevfee(List<dynamic> response)
      : old = (response[0] as _i1.EthereumAddress),
        novo = (response[1] as _i1.EthereumAddress);

  final _i1.EthereumAddress old;

  final _i1.EthereumAddress novo;
}

class SwitchedMinter {
  SwitchedMinter(List<dynamic> response)
      : old = (response[0] as _i1.EthereumAddress),
        novo = (response[1] as _i1.EthereumAddress);

  final _i1.EthereumAddress old;

  final _i1.EthereumAddress novo;
}

class ToggledDevFee {
  ToggledDevFee(List<dynamic> response) : devfeeStatus = (response[0] as bool);

  final bool devfeeStatus;
}

class Transfer {
  Transfer(List<dynamic> response)
      : from = (response[0] as _i1.EthereumAddress),
        to = (response[1] as _i1.EthereumAddress),
        value = (response[2] as BigInt);

  final _i1.EthereumAddress from;

  final _i1.EthereumAddress to;

  final BigInt value;
}
