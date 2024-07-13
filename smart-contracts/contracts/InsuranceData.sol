// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

contract InsuranceData {
  /********************************************************************************************/
  /*                                       DATA VARIABLES                                     */
  /********************************************************************************************/

  address private contractOwner; // Account used to deploy contract
  bool private operational = true; // Blocks all state changes throughout the contract if false
  mapping(address => bool) private registeredInsuranceProvider;
  mapping(address => bool) private authorizedContracts;
  address[] public providers;

  uint8 public numFundedInsuranceProviders;
  address[] public alreadyFundedInsuranceProviders;
  mapping(uint256 => uint256) public numliquidityproviders;
  mapping(uint256 => address[]) public insurancelps;
  mapping(uint256 => uint256) public insuranceliquidity;
  mapping(uint256 => mapping(address => bool)) public hasProvidedLiquidity;
  mapping(address => mapping(uint256 => uint256)) public claimablePayout;
  enum TypeOfInsurance {
    Rain,
    Heat,
    ExtremeConditions
  }
  struct Insurance {
    bool isRegistered;
    uint256 start;
    uint256 end;
    TypeOfInsurance typeOfIns;
    address provider;
    string name;
    string description;
    uint256 riskNumerator;
    uint256 riskDenominator;
  }
  mapping(uint256 => Insurance) public insurances;
  mapping(string => bool) public availableInsurances;
  mapping(uint256 => mapping(address => uint256)) public liquidityperlp;
  mapping(address => mapping(uint256 => bool)) private clientinsured;
  mapping(uint256 => address[]) private insuranceProviderInsurees;
  mapping(address => mapping(uint256 => uint)) insuredamount;
  mapping(address => uint) private fundedinsurance;
  mapping(uint256 => mapping(address => uint)) insuredpayout;
  uint256 public insuranceId;
  uint256[] private validators;
  mapping(address => bool) private validatorAlreadyExists;
  event ContractAuthorized(address contractAddress);
  event ContractDeauthorized(address contractAddress);
  event InsuranceBought(address insuree, uint256 insuranceid);
  event InsuranceAdded(uint256 insuranceid);
  event ValidatorAdded(address validator);
  event InsuranceClaimed(address insuree, uint256 payout);
  /********************************************************************************************/
  /*                                       EVENT DEFINITIONS                                  */
  /********************************************************************************************/

  /**
   * @dev Constructor
   *      initialize global variable for insurance ids
   */
  constructor() {
    contractOwner = msg.sender;
    insuranceId = 0;
  }

  /**
   * @dev Modifier that requires the "ContractOwner" account to be the function caller
   */
  modifier requireContractOwner() {
    require(msg.sender == contractOwner, "Caller is not contract owner");
    _;
  }

  modifier requireIsCallerInsuranceRegistered(address caller) {
    require(registeredInsuranceProvider[caller] == true, "Caller not registered");
    _;
  }

  /********************************************************************************************/
  /*                                       UTILITY FUNCTIONS                                  */
  /********************************************************************************************/

  function isNotInsured(uint256 insuranceid) external view returns (bool) {
    uint amount = insuredamount[msg.sender][insuranceid];
    return (amount == 0);
  }

  function isInsuranceProviderRegistered(address registeredInsuranceProviderAddress) public view returns (bool) {
    return registeredInsuranceProvider[registeredInsuranceProviderAddress];
  }
  function numOfInsuranceProviders() public view returns (uint count) {
    return providers.length;
  }

  /********************************************************************************************/
  /*                                     SMART CONTRACT FUNCTIONS                             */
  /********************************************************************************************/
  /**
   * @dev Add an insurance to the registration queue
   *      Can only be called from InsuranceApp contract
   *
   */
  function registerInsuranceProvider(address _provider) external returns (bool successfulRegistration) {
    registeredInsuranceProvider[_provider] = true;
    successfulRegistration = true;
    providers.push(_provider);
    return successfulRegistration;
  }
    /**
     * @dev Register insurance by provising all required fields. The caller should be an insurance provider
     */
  function registerInsurance(
    string calldata _insuranceName,
    uint256 _start,
    uint256 _end,
    TypeOfInsurance _typeOfIns,
    string calldata _description,
    uint256 _riskNumerator,
    uint256 _riskDenominator
  ) external payable returns (uint256) {
    require(msg.value > 0, "The insurance provider should fund the insurance");
    insurances[insuranceId] = Insurance({
      isRegistered: true,
      start: _start,
      end: _end,
      provider: msg.sender,
      typeOfIns: _typeOfIns,
      name: _insuranceName,
      description: _description,
      riskNumerator: _riskNumerator,
      riskDenominator: _riskDenominator
    });
    availableInsurances[_insuranceName] = true;
    insurancelps[insuranceId].push(msg.sender);
    insuranceliquidity[insuranceId] = msg.value;
    liquidityperlp[insuranceId][msg.sender] = msg.value;
    emit InsuranceAdded(insuranceId);
    insuranceId++;
    return insuranceId;
  }
/**
 * @dev to register a validator.
 */
  function registerValidator() external {
    require(!validatorAlreadyExists[msg.sender], "Validator is already registered");
    validators.push(msg.sender);
    emit ValidatorAdded(msg.sender);
  }
  function getInsuranceProviders() external view returns (address[] memory) {
    return providers;
  }

  function getFundedInsuranceProviders() external view returns (address[] memory) {
    return alreadyFundedInsuranceProviders;
  }

  /**
   * @dev liquidity providers can deposit funds in any amount to support any insurance
   */
  function fundInsurance(uint256 insuranceid) public payable returns (uint) {
    require(
      hasProvidedLiquidity[insuranceid][msg.sender],
      "The liquidity provider has already provisioned liquidity for this insurance"
    );
    numliquidityproviders[insuranceid]++;
    insuranceliquidity[insuranceid] = insuranceliquidity[insuranceid] + msg.value;
    insurancelps[insuranceid].push(msg.sender);
    liquidityperlp[insuranceid][msg.sender] = msg.value;
    return insuranceid;
  }

  /**
   * @dev to see how much fund an insurance is supported with
   */
  function getInsuranceFunds(uint256 insuranceid) external view returns (uint256) {
    return insuranceliquidity[insuranceid];
  }
  /**
   * @dev Buy weather insurance.
   *
   */

  function buy(uint256 insuranceid) external payable {
    require(!clientinsured[msg.sender][insuranceid], "The client has already taken this type of insurance");
    require(msg.value > 0, "The client should send ETH to buy insurance");
    uint256 temppayout = msg.value * insurances[insuranceid].riskDenominator;
    require(temppayout < insuranceliquidity[insuranceid], "You should buy with less ETH");
    claimablePayout[msg.sender][insuranceid] = temppayout;
    clientinsured[msg.sender][insuranceid] = true;
    insuranceProviderInsurees[insuranceid].push(msg.sender);
    insuredamount[msg.sender][insuranceid] = msg.value;
    for (uint256 i = 0; i < insurancelps[insuranceid].length; i++) {
      uint lpperc = (liquidityperlp[insuranceid][insurancelps[insuranceid][i]] / insuranceliquidity[insuranceId]) * 100;
      uint lpamount = lpperc * msg.value;
      payable(insurancelps[insuranceid][i]).transfer(lpamount);
    }
    emit InsuranceBought(msg.sender, insuranceid);
    insuredpayout[insuranceid][msg.sender] = 0;
  }

  /**
   *  @dev Transfers eligible payout funds to insuree
   *
   */
  function payout(uint256 insuranceid, address insuree) external returns (uint) {
    require(insuredpayout[insuranceid][insuree] == 0, "The client has already claimed payout");
    uint insureepayout = claimablePayout[insuree][insuranceid];
    payable(insuree).transfer(insureepayout);
    insuredpayout[insuranceid][insuree] = insureepayout;
    emit InsuranceClaimed(insuree, insureepayout);
    return insureepayout;
  }

  /**
   * @dev Fallback functions when retrieving ether.
   *
   */
  // Function to receive Ether. msg.data must be empty
  receive() external payable {}

  // Fallback function is called when msg.data is not empty
  fallback() external payable {}
}
