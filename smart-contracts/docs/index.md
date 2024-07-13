# Solidity API

## InsuranceData

### providers

```solidity
address[] providers
```

### numFundedInsuranceProviders

```solidity
uint8 numFundedInsuranceProviders
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

### availableInsurances

```solidity
mapping(string => bool) availableInsurances
```

### liquidityperlp

```solidity
mapping(uint256 => mapping(address => uint256)) liquidityperlp
```

### accountBalance

```solidity
mapping(address => uint256) accountBalance
```

### insuredamount

```solidity
mapping(address => mapping(uint256 => uint256)) insuredamount
```

### insuredpayout

```solidity
mapping(uint256 => mapping(address => uint256)) insuredpayout
```

### multiAddress

```solidity
address[] multiAddress
```

### counter

```solidity
uint8 counter
```

### insuranceId

```solidity
uint256 insuranceId
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
event InsuranceAdded(address provider)
```

### InsuranceClaimed

```solidity
event InsuranceClaimed(address insuree, uint256 payout)
```

### REGISTRATION_FUND

```solidity
uint256 REGISTRATION_FUND
```

### MIN_FUNDING_AMOUNT

```solidity
uint256 MIN_FUNDING_AMOUNT
```

### constructor

```solidity
constructor() public
```

_Constructor
     initialize global variable for insurance ids_

### requireIsOperational

```solidity
modifier requireIsOperational()
```

_Modifier that requires the "operational" boolean variable to be "true"
     This is used on all state changing functions to pause the contract in
     the event there is an issue that needs to be fixed_

### requireContractOwner

```solidity
modifier requireContractOwner()
```

_Modifier that requires the "ContractOwner" account to be the function caller_

### requireIsCallerInsuranceRegistered

```solidity
modifier requireIsCallerInsuranceRegistered(address caller)
```

### requireIsCallerAuthorized

```solidity
modifier requireIsCallerAuthorized()
```

### isNotInsured

```solidity
function isNotInsured(uint256 insuranceid) external view returns (bool)
```

### isInsuranceProviderRegistered

```solidity
function isInsuranceProviderRegistered(address registeredInsuranceProviderAddress) public view returns (bool)
```

### isOperational

```solidity
function isOperational() public view returns (bool)
```

_Get operating status of contract_

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | A bool that is the current operating status |

### numOfInsuranceProviders

```solidity
function numOfInsuranceProviders() public view returns (uint256 count)
```

### getCounter

```solidity
function getCounter() public view returns (uint8)
```

### setOperatingStatus

```solidity
function setOperatingStatus(bool mode) external
```

_Sets contract operations on/off

When operational mode is disabled, all write transactions except for this one will fail_

### registerInsuranceProvider

```solidity
function registerInsuranceProvider(address _provider) external returns (bool successfulRegistration)
```

_Add an insurance to the registration queue
     Can only be called from InsuranceApp contract_

### registerInsurance

```solidity
function registerInsurance(address _insuranceProvider, string _insuranceName, uint256 _start, uint256 _end, enum InsuranceData.TypeOfInsurance _typeOfIns, string _description, uint256 _riskNumerator, uint256 _riskDenominator) external payable returns (uint256)
```

### getInsuranceProviders

```solidity
function getInsuranceProviders() external view returns (address[])
```

### getFundedInsuranceProviders

```solidity
function getFundedInsuranceProviders() external view returns (address[])
```

### getInsureeFunds

```solidity
function getInsureeFunds(address insuree) external view returns (uint256)
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
function buy(uint256 insuranceid) external payable
```

_Buy weather insurance._

### payout

```solidity
function payout(uint256 insuranceid, address insuree) external returns (uint256)
```

@dev Transfers eligible payout funds to insuree

### receive

```solidity
receive() external payable
```

_Fallback functions when retrieving ether._

### fallback

```solidity
fallback() external payable
```

