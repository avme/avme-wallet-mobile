// Generated code, do not modify. Run `build_runner build` to re-generate!
// @dart=2.12
import 'package:web3dart/web3dart.dart' as _i1;final _contractAbi = _i1.ContractAbi.fromJson('[{"type":"constructor","stateMutability":"nonpayable","inputs":[]},{"type":"event","name":"Approval","inputs":[{"type":"address","name":"_owner","internalType":"address","indexed":true},{"type":"address","name":"_spender","internalType":"address","indexed":true},{"type":"uint256","name":"_value","internalType":"uint256","indexed":false}],"anonymous":false},{"type":"event","name":"Burned","inputs":[{"type":"address","name":"_from","internalType":"address","indexed":true},{"type":"uint256","name":"_value","internalType":"uint256","indexed":false}],"anonymous":false},{"type":"event","name":"Minted","inputs":[{"type":"address","name":"_to","internalType":"address","indexed":true},{"type":"uint256","name":"_value","internalType":"uint256","indexed":false}],"anonymous":false},{"type":"event","name":"SwitchedDevfee","inputs":[{"type":"address","name":"oldaddress","internalType":"address","indexed":true},{"type":"address","name":"newaddress","internalType":"address","indexed":true}],"anonymous":false},{"type":"event","name":"SwitchedMinter","inputs":[{"type":"address","name":"_old","internalType":"address","indexed":true},{"type":"address","name":"_new","internalType":"address","indexed":true}],"anonymous":false},{"type":"event","name":"ToggledDevFee","inputs":[{"type":"bool","name":"_devfeeStatus","internalType":"bool","indexed":false}],"anonymous":false},{"type":"event","name":"Transfer","inputs":[{"type":"address","name":"_from","internalType":"address","indexed":true},{"type":"address","name":"_to","internalType":"address","indexed":true},{"type":"uint256","name":"_value","internalType":"uint256","indexed":false}],"anonymous":false},{"type":"function","stateMutability":"view","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"_devFeeEnabled","inputs":[]},{"type":"function","stateMutability":"view","outputs":[{"type":"address","name":"","internalType":"address"}],"name":"_dev_fee_address","inputs":[]},{"type":"function","stateMutability":"view","outputs":[{"type":"uint256","name":"","internalType":"uint256"}],"name":"_initialSupply","inputs":[]},{"type":"function","stateMutability":"view","outputs":[{"type":"uint256","name":"","internalType":"uint256"}],"name":"_maxSupply","inputs":[]},{"type":"function","stateMutability":"view","outputs":[{"type":"address","name":"","internalType":"address"}],"name":"_minter","inputs":[]},{"type":"function","stateMutability":"view","outputs":[{"type":"uint256","name":"","internalType":"uint256"}],"name":"allowance","inputs":[{"type":"address","name":"_owner","internalType":"address"},{"type":"address","name":"_spender","internalType":"address"}]},{"type":"function","stateMutability":"nonpayable","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"approve","inputs":[{"type":"address","name":"_spender","internalType":"address"},{"type":"uint256","name":"_value","internalType":"uint256"}]},{"type":"function","stateMutability":"view","outputs":[{"type":"uint256","name":"","internalType":"uint256"}],"name":"balanceOf","inputs":[{"type":"address","name":"_owner","internalType":"address"}]},{"type":"function","stateMutability":"nonpayable","outputs":[{"type":"bool","name":"","internalType":"bool"}],"name":"burn","inputs":[{"type":"uint256","name":"_amount","internalType":"uint256"}]},{"type":"function","stateMutability":"view","outputs":[{"type":"uint8","name":"","internalType":"uint8"}],"name":"decimals","inputs":[]}]', 'Avme');class Avme extends _i1.GeneratedContract {Avme({required _i1.EthereumAddress address, required _i1.Web3Client client, int? chainId}) : super(_i1.DeployedContract(_contractAbi, address), client, chainId);

/// The optional [atBlock] parameter can be used to view historical data. When
/// set, the function will be evaluated in the specified block. By default, the
/// latest on-chain block will be used.
Future<bool> _devFeeEnabled({_i1.BlockNum? atBlock}) async  { final function = self.abi.functions  [
1
];
assert(checkSignature(function, '9eeb25b1'));
final params = [];
final response =  await read(function, params, atBlock);
return  (response  [
0
] as bool); } 
/// The optional [atBlock] parameter can be used to view historical data. When
/// set, the function will be evaluated in the specified block. By default, the
/// latest on-chain block will be used.
Future<_i1.EthereumAddress> _dev_fee_address({_i1.BlockNum? atBlock}) async  { final function = self.abi.functions  [
2
];
assert(checkSignature(function, '8041a129'));
final params = [];
final response =  await read(function, params, atBlock);
return  (response  [
0
] as _i1.EthereumAddress); } 
/// The optional [atBlock] parameter can be used to view historical data. When
/// set, the function will be evaluated in the specified block. By default, the
/// latest on-chain block will be used.
Future<BigInt> _initialSupply({_i1.BlockNum? atBlock}) async  { final function = self.abi.functions  [
3
];
assert(checkSignature(function, 'c3b2d337'));
final params = [];
final response =  await read(function, params, atBlock);
return  (response  [
0
] as BigInt); } 
/// The optional [atBlock] parameter can be used to view historical data. When
/// set, the function will be evaluated in the specified block. By default, the
/// latest on-chain block will be used.
Future<BigInt> _maxSupply({_i1.BlockNum? atBlock}) async  { final function = self.abi.functions  [
4
];
assert(checkSignature(function, '22f4596f'));
final params = [];
final response =  await read(function, params, atBlock);
return  (response  [
0
] as BigInt); } 
/// The optional [atBlock] parameter can be used to view historical data. When
/// set, the function will be evaluated in the specified block. By default, the
/// latest on-chain block will be used.
Future<_i1.EthereumAddress> _minter({_i1.BlockNum? atBlock}) async  { final function = self.abi.functions  [
5
];
assert(checkSignature(function, '578ec33f'));
final params = [];
final response =  await read(function, params, atBlock);
return  (response  [
0
] as _i1.EthereumAddress); } 
/// The optional [atBlock] parameter can be used to view historical data. When
/// set, the function will be evaluated in the specified block. By default, the
/// latest on-chain block will be used.
Future<BigInt> allowance(_i1.EthereumAddress _owner, _i1.EthereumAddress _spender, {_i1.BlockNum? atBlock}) async  { final function = self.abi.functions  [
6
];
assert(checkSignature(function, 'dd62ed3e'));
final params = [_owner, _spender];
final response =  await read(function, params, atBlock);
return  (response  [
0
] as BigInt); } 
/// The optional [transaction] parameter can be used to override parameters
/// like the gas price, nonce and max gas. The `data` and `to` fields will be
/// set by the contract.
Future<String> approve(_i1.EthereumAddress _spender, BigInt _value, {required _i1.Credentials credentials, _i1.Transaction? transaction}) async  { final function = self.abi.functions  [
7
];
assert(checkSignature(function, '095ea7b3'));
final params = [_spender, _value];
return  write(credentials, transaction, function, params); } 
/// The optional [atBlock] parameter can be used to view historical data. When
/// set, the function will be evaluated in the specified block. By default, the
/// latest on-chain block will be used.
Future<BigInt> balanceOf(_i1.EthereumAddress _owner, {_i1.BlockNum? atBlock}) async  { final function = self.abi.functions  [
8
];
assert(checkSignature(function, '70a08231'));
final params = [_owner];
final response =  await read(function, params, atBlock);
return  (response  [
0
] as BigInt); } 
/// The optional [transaction] parameter can be used to override parameters
/// like the gas price, nonce and max gas. The `data` and `to` fields will be
/// set by the contract.
Future<String> burn(BigInt _amount, {required _i1.Credentials credentials, _i1.Transaction? transaction}) async  { final function = self.abi.functions  [
9
];
assert(checkSignature(function, '42966c68'));
final params = [_amount];
return  write(credentials, transaction, function, params); } 
/// The optional [atBlock] parameter can be used to view historical data. When
/// set, the function will be evaluated in the specified block. By default, the
/// latest on-chain block will be used.
Future<BigInt> decimals({_i1.BlockNum? atBlock}) async  { final function = self.abi.functions  [
10
];
assert(checkSignature(function, '313ce567'));
final params = [];
final response =  await read(function, params, atBlock);
return  (response  [
0
] as BigInt); } 
/// Returns a live stream of all Approval events emitted by this contract.
Stream<Approval> approvalEvents({_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) { final event = self.event('Approval');
final filter = _i1.FilterOptions.events(contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
return  client.events(filter).map((_i1.FilterEvent result) { final decoded = event.decodeResults(result.topics!, result.data!);
return  Approval(decoded); } ); } 
/// Returns a live stream of all Burned events emitted by this contract.
Stream<Burned> burnedEvents({_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) { final event = self.event('Burned');
final filter = _i1.FilterOptions.events(contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
return  client.events(filter).map((_i1.FilterEvent result) { final decoded = event.decodeResults(result.topics!, result.data!);
return  Burned(decoded); } ); } 
/// Returns a live stream of all Minted events emitted by this contract.
Stream<Minted> mintedEvents({_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) { final event = self.event('Minted');
final filter = _i1.FilterOptions.events(contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
return  client.events(filter).map((_i1.FilterEvent result) { final decoded = event.decodeResults(result.topics!, result.data!);
return  Minted(decoded); } ); } 
/// Returns a live stream of all SwitchedDevfee events emitted by this contract.
Stream<SwitchedDevfee> switchedDevfeeEvents({_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) { final event = self.event('SwitchedDevfee');
final filter = _i1.FilterOptions.events(contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
return  client.events(filter).map((_i1.FilterEvent result) { final decoded = event.decodeResults(result.topics!, result.data!);
return  SwitchedDevfee(decoded); } ); } 
/// Returns a live stream of all SwitchedMinter events emitted by this contract.
Stream<SwitchedMinter> switchedMinterEvents({_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) { final event = self.event('SwitchedMinter');
final filter = _i1.FilterOptions.events(contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
return  client.events(filter).map((_i1.FilterEvent result) { final decoded = event.decodeResults(result.topics!, result.data!);
return  SwitchedMinter(decoded); } ); } 
/// Returns a live stream of all ToggledDevFee events emitted by this contract.
Stream<ToggledDevFee> toggledDevFeeEvents({_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) { final event = self.event('ToggledDevFee');
final filter = _i1.FilterOptions.events(contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
return  client.events(filter).map((_i1.FilterEvent result) { final decoded = event.decodeResults(result.topics!, result.data!);
return  ToggledDevFee(decoded); } ); } 
/// Returns a live stream of all Transfer events emitted by this contract.
Stream<Transfer> transferEvents({_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) { final event = self.event('Transfer');
final filter = _i1.FilterOptions.events(contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
return  client.events(filter).map((_i1.FilterEvent result) { final decoded = event.decodeResults(result.topics!, result.data!);
return  Transfer(decoded); } ); } 
 }
class Approval {Approval(List<dynamic> response) : owner = (response[0] as _i1.EthereumAddress), spender = (response[1] as _i1.EthereumAddress), value = (response[2] as BigInt);

final _i1.EthereumAddress owner;

final _i1.EthereumAddress spender;

final BigInt value;

 }
class Burned {Burned(List<dynamic> response) : from = (response[0] as _i1.EthereumAddress), value = (response[1] as BigInt);

final _i1.EthereumAddress from;

final BigInt value;

 }
class Minted {Minted(List<dynamic> response) : to = (response[0] as _i1.EthereumAddress), value = (response[1] as BigInt);

final _i1.EthereumAddress to;

final BigInt value;

 }
class SwitchedDevfee {SwitchedDevfee(List<dynamic> response) : oldaddress = (response[0] as _i1.EthereumAddress), newaddress = (response[1] as _i1.EthereumAddress);

final _i1.EthereumAddress oldaddress;

final _i1.EthereumAddress newaddress;

 }
class SwitchedMinter {SwitchedMinter(List<dynamic> response) : old = (response[0] as _i1.EthereumAddress), new = (response[1] as _i1.EthereumAddress);

final _i1.EthereumAddress old;

final _i1.EthereumAddress new;

 }
class ToggledDevFee {ToggledDevFee(List<dynamic> response) : devfeeStatus = (response[0] as bool);

final bool devfeeStatus;

 }
class Transfer {Transfer(List<dynamic> response) : from = (response[0] as _i1.EthereumAddress), to = (response[1] as _i1.EthereumAddress), value = (response[2] as BigInt);

final _i1.EthereumAddress from;

final _i1.EthereumAddress to;

final BigInt value;

 }
