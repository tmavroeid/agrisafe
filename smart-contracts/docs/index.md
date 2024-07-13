# Solidity API

## InsuranceData

### s_lastRequestId

```solidity
bytes32 s_lastRequestId
```

### s_lastResponse

```solidity
bytes s_lastResponse
```

### s_lastError

```solidity
bytes s_lastError
```

### providers

```solidity
address[] providers
```

### alreadyFundedInsuranceProviders

```solidity
address[] alreadyFundedInsuranceProviders
```

### numliquidityproviders

```solidity
mapping(uint256 => uint256) numliquidityproviders
```

### insurancelps

```solidity
mapping(uint256 => address[]) insurancelps
```

### insuranceliquidity

```solidity
mapping(uint256 => uint256) insuranceliquidity
```

### hasProvidedLiquidity

```solidity
mapping(uint256 => mapping(address => bool)) hasProvidedLiquidity
```

### claimablePayout

```solidity
mapping(address => mapping(uint256 => uint256)) claimablePayout
```

### TypeOfInsurance

```solidity
enum TypeOfInsurance {
  Rain,
  Heat,
  ExtremeConditions
}
```

### Insurance

```solidity
struct Insurance {
  bool isRegistered;
  uint256 start;
  uint256 end;
  enum InsuranceData.TypeOfInsurance typeOfIns;
  address provider;
  string lat;
  string lon;
  string name;
  string description;
  uint256 riskNumerator;
  uint256 riskDenominator;
}
```

### insurances

```solidity
mapping(uint256 => struct InsuranceData.Insurance) insurances
```

### liquidityperlp

```solidity
mapping(uint256 => mapping(address => uint256)) liquidityperlp
```

### insuredamount

```solidity
mapping(address => mapping(uint256 => uint256)) insuredamount
```

### insuredpayout

```solidity
mapping(uint256 => mapping(address => uint256)) insuredpayout
```

### insuranceId

```solidity
uint256 insuranceId
```

### insuranceIds

```solidity
uint256[] insuranceIds
```

### ContractAuthorized

```solidity
event ContractAuthorized(address contractAddress)
```

### ContractDeauthorized

```solidity
event ContractDeauthorized(address contractAddress)
```

### InsuranceBought

```solidity
event InsuranceBought(address insuree, uint256 insuranceid)
```

### InsuranceAdded

```solidity
event InsuranceAdded(uint256 insuranceid)
```

### ValidatorAdded

```solidity
event ValidatorAdded(address validator)
```

### InsuranceClaimed

```solidity
event InsuranceClaimed(address insuree, uint256 payout)
```

### UnexpectedRequestID

```solidity
error UnexpectedRequestID(bytes32 requestId)
```

### Response

```solidity
event Response(bytes32 requestId, string character, bytes response, bytes err)
```

### router

```solidity
address router
```

### source

```solidity
string source
```

### gasLimit

```solidity
uint32 gasLimit
```

### donID

```solidity
bytes32 donID
```

### character

```solidity
string character
```

### InvalidNullifier

```solidity
error InvalidNullifier()
```

Thrown when attempting to reuse a nullifier

### worldId

```solidity
contract IWorldID worldId
```

_The address of the World ID Router contract that will be used for verifying proofs_

### externalNullifierHash

```solidity
uint256 externalNullifierHash
```

_The keccak256 hash of the externalNullifier (unique identifier of the action performed), combination of appId and action_

### groupId

```solidity
uint256 groupId
```

_The World ID group ID (1 for Orb-verified)_

### nullifierHashes

```solidity
mapping(uint256 => bool) nullifierHashes
```

_Whether a nullifier hash has been used already. Used to guarantee an action is only performed once by a single person_

### constructor

```solidity
constructor(contract IWorldID _worldId, string _appId, string _action) public
```

_Constructor
     initialize global variable for insurance ids_

### requireContractOwner

```solidity
modifier requireContractOwner()
```

_Modifier that requires the "ContractOwner" account to be the function caller_

### requireIsCallerInsuranceRegistered

```solidity
modifier requireIsCallerInsuranceRegistered(address caller)
```

### isNotInsured

```solidity
function isNotInsured(uint256 insuranceid) external view returns (bool)
```

### isInsuranceProviderRegistered

```solidity
function isInsuranceProviderRegistered(address registeredInsuranceProviderAddress) public view returns (bool)
```

### numOfInsuranceProviders

```solidity
function numOfInsuranceProviders() public view returns (uint256 count)
```

### registerInsuranceProvider

```solidity
function registerInsuranceProvider(address _provider) external returns (bool successfulRegistration)
```

_Add an insurance to the registration queue
     Can only be called from InsuranceApp contract_

### registerInsurance

```solidity
function registerInsurance(string _insuranceName, uint256 _start, uint256 _end, enum InsuranceData.TypeOfInsurance _typeOfIns, string _lat, string _lon, string _description, uint256 _riskNumerator, uint256 _riskDenominator) external payable returns (uint256)
```

_Register insurance by provising all required fields. The caller should be an insurance provider_

### registerValidator

```solidity
function registerValidator() external
```

_to register a validator._

### getInsuranceProviders

```solidity
function getInsuranceProviders() external view returns (address[])
```

### getFundedInsuranceProviders

```solidity
function getFundedInsuranceProviders() external view returns (address[])
```

### fundInsurance

```solidity
function fundInsurance(uint256 insuranceid) public payable returns (uint256)
```

_liquidity providers can deposit funds in any amount to support any insurance_

### getInsuranceFunds

```solidity
function getInsuranceFunds(uint256 insuranceid) external view returns (uint256)
```

_to see how much fund an insurance is supported with_

### buy

```solidity
function buy(uint256 insuranceid, uint256 nullifierHash, uint256[8] proof) external payable
```

_Buy weather insurance._

### payout

```solidity
function payout(uint256 insuranceid, address insuree) external returns (uint256)
```

@dev Transfers eligible payout funds to insuree

### claimInsurancePayout

```solidity
function claimInsurancePayout(uint256 insuranceid) external returns (bytes32)
```

@dev Claim insurance

### sendRequest

```solidity
function sendRequest(uint64 subscriptionId, string[] args) internal returns (bytes32 requestId)
```

Sends an HTTP request for character information

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| subscriptionId | uint64 | The ID for the Chainlink subscription |
| args | string[] | The arguments to pass to the HTTP request |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| requestId | bytes32 | The ID of the request |

### fulfillRequest

```solidity
function fulfillRequest(bytes32 requestId, bytes response, bytes err) internal
```

Callback function for fulfilling a request

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| requestId | bytes32 | The ID of the request to fulfill |
| response | bytes | The HTTP response data |
| err | bytes | Any errors from the Functions request |

### receive

```solidity
receive() external payable
```

_Fallback functions when retrieving ether._

### fallback

```solidity
fallback() external payable
```

## ByteHasher

### hashToField

```solidity
function hashToField(bytes value) internal pure returns (uint256)
```

_Creates a keccak256 hash of a bytestring.
`>> 8` makes sure that the result is included in our field_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| value | bytes | The bytestring to hash |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The hash of the specified value |

## IWorldID

### verifyProof

```solidity
function verifyProof(uint256 root, uint256 groupId, uint256 signalHash, uint256 nullifierHash, uint256 externalNullifierHash, uint256[8] proof) external view
```

Reverts if the zero-knowledge proof is invalid.

_Note that a double-signaling check is not included here, and should be carried by the caller._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| root | uint256 | The of the Merkle tree |
| groupId | uint256 | The id of the Semaphore group |
| signalHash | uint256 | A keccak256 hash of the Semaphore signal |
| nullifierHash | uint256 | The nullifier hash |
| externalNullifierHash | uint256 | A keccak256 hash of the external nullifier |
| proof | uint256[8] | The zero-knowledge proof |

