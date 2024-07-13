// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import { FunctionsClient } from "@chainlink/contracts/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import { ConfirmedOwner } from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import { FunctionsRequest } from "@chainlink/contracts/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";

contract InsuranceData is FunctionsClient, ConfirmedOwner {
  /********************************************************************************************/
  /*                                       DATA VARIABLES                                     */
  /********************************************************************************************/
  using FunctionsRequest for FunctionsRequest.Request;
  bytes32 public s_lastRequestId;
  bytes public s_lastResponse;
  bytes public s_lastError;

  address private contractOwner; // Account used to deploy contract
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
  mapping(uint256 => mapping(address => uint256)) public liquidityperlp;
  mapping(address => mapping(uint256 => bool)) private clientinsured;
  mapping(uint256 => address[]) private insuranceProviderInsurees;
  mapping(address => mapping(uint256 => uint)) insuredamount;
  mapping(address => uint) private fundedinsurance;
  mapping(uint256 => mapping(address => uint)) insuredpayout;
  uint256 public insuranceId;
  address[] private validators;
  uint256[] public insuranceIds;
  mapping(address => bool) private validatorAlreadyExists;
  event ContractAuthorized(address contractAddress);
  event ContractDeauthorized(address contractAddress);
  event InsuranceBought(address insuree, uint256 insuranceid);
  event InsuranceAdded(uint256 insuranceid);
  event ValidatorAdded(address validator);
  event InsuranceClaimed(address insuree, uint256 payout);
  // Custom error type
  error UnexpectedRequestID(bytes32 requestId);

  // Event to log responses
  event Response(bytes32 indexed requestId, string character, bytes response, bytes err);

  // Router address - Hardcoded for Sepolia
  // Check to get the router address for your supported network https://docs.chain.link/chainlink-functions/supported-networks
  address router = 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0;

  // JavaScript source code
  // Fetch character name from the Star Wars API.
  // Documentation: https://swapi.info/people
  string source =
    "const characterId = args[0];"
    "const apiResponse = await Functions.makeHttpRequest({"
    "url: `https://swapi.info/api/people/${characterId}/`"
    "});"
    "if (apiResponse.error) {"
    "throw Error('Request failed');"
    "}"
    "const { data } = apiResponse;"
    "return Functions.encodeString(data.name);";

  //Callback gas limit
  uint32 gasLimit = 300000;

  // donID - Hardcoded for Sepolia
  // Check to get the donID for your supported network https://docs.chain.link/chainlink-functions/supported-networks
  bytes32 donID = 0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000;

  // State variable to store the returned character information
  string public character;

  /********************************************************************************************/
  /*                                       EVENT DEFINITIONS                                  */
  /********************************************************************************************/

  /**
   * @dev Constructor
   *      initialize global variable for insurance ids
   */
  constructor() FunctionsClient(router) ConfirmedOwner(msg.sender) {
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
    insurancelps[insuranceId].push(msg.sender);
    insuranceIds.push(insuranceId);
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
   *  @dev Claim insurance
   *
   */
  function claimInsurancePayout(
    uint256 insuranceid,
    string calldata lat,
    string calldata lon
  ) external returns (bool) {}

  function fulfillRequest(bytes32 requestId, bytes memory response, bytes memory err) internal override {
    if (s_lastRequestId != requestId) {
      revert UnexpectedRequestID(requestId); // Check if request IDs match
    }
    // Update the contract's state variables with the response and any errors
    s_lastResponse = response;
    character = string(response);
    s_lastError = err;

    // Emit an event to log the response
    emit Response(requestId, character, s_lastResponse, s_lastError);
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
