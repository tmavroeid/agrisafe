// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import { FunctionsClient } from "@chainlink/contracts/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import { ConfirmedOwner } from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import { FunctionsRequest } from "@chainlink/contracts/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";
import { ByteHasher } from "./helpers/ByteHasher.sol";
import { IWorldID } from "./interfaces/IWorldID.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

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
  address[] public providers;
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
    string lat;
    string lon;
    string name;
    string description;
    uint256 riskNumerator;
    uint256 riskDenominator;
  }
  struct Validator {
    address addr;
    string url;
  }
  struct ValidatorResult {
    string jobid;
    bool result;
  }
  mapping(uint256 => Insurance) public insurances;
  mapping(uint256 => mapping(address => uint256)) public liquidityperlp;
  mapping(address => mapping(uint256 => bool)) private clientinsured;
  mapping(uint256 => address[]) private insuranceProviderInsurees;
  mapping(address => mapping(uint256 => uint)) insuredamount;
  mapping(uint256 => mapping(address => uint)) insuredpayout;
  mapping(uint256 => bytes32[]) requestsperclaim;
  mapping(uint256 => ValidatorResult[]) resultsperclaim;
  uint256 public insuranceId;
  Validator[] private validators;
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
  // uint256 insuranceid, address insuree, address validator,
  event Response(bytes32 indexed requestId, bytes response, bytes err);

  // Router address - Hardcoded for Sepolia
  // Check to get the router address for your supported network https://docs.chain.link/chainlink-functions/supported-networks
  address router = 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0;

  // JavaScript source code
  // Fetch character name from the Star Wars API.
  // Documentation: https://swapi.info/people
  string source =
    "const insuranceId = args[0];"
    "const insuranceType = args[1];"
    "const lat = args[2];"
    "const lon = args[3];"
    "const afterTs = args[4];"
    "const beforeTs = args[5];"
    "const validatorURL = args[6];"
    "const apiResponse = await Functions.makeHttpRequest({"
    "url: `${validatorURL}/insurance/${insuranceId}?type=${insuranceType}&lat=${lat}&lon=${lon}&after=${afterTs}&before=${beforeTs}`"
    "});"
    "if (apiResponse.error) {"
    "throw Error('Request failed');"
    "}"
    "const { data } = apiResponse;"
    "return Functions.encodeString(data.result+data.job_id+data.address+data.insurance_id);";

  //Callback gas limit
  uint32 gasLimit = 300000;

  // donID - Hardcoded for Sepolia
  // Check to get the donID for your supported network https://docs.chain.link/chainlink-functions/supported-networks
  bytes32 donID = 0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000;

  /// @dev This allows us to use our hashToField function on bytes
  using ByteHasher for bytes;

  /// @notice Thrown when attempting to reuse a nullifier
  error InvalidNullifier();

  /// @dev The address of the World ID Router contract that will be used for verifying proofs
  IWorldID internal immutable worldId;

  /// @dev The keccak256 hash of the externalNullifier (unique identifier of the action performed), combination of appId and action
  uint256 internal immutable externalNullifierHash;

  /// @dev The World ID group ID (1 for Orb-verified)
  uint256 internal immutable groupId;

  /// @dev Whether a nullifier hash has been used already. Used to guarantee an action is only performed once by a single person
  mapping(uint256 => bool) internal nullifierHashes;
  /********************************************************************************************/
  /*                                       EVENT DEFINITIONS                                  */
  /********************************************************************************************/

  /**
   * @dev Constructor
   *      initialize global variable for insurance ids
   */

  constructor(
    IWorldID _worldId,
    string memory _appId,
    string memory _action
  ) FunctionsClient(router) ConfirmedOwner(msg.sender) {
    contractOwner = msg.sender;
    insuranceId = 0;
    worldId = _worldId;
    groupId = 1;
    externalNullifierHash = abi.encodePacked(abi.encodePacked(_appId).hashToField(), _action).hashToField();
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
    string calldata _lat,
    string calldata _lon,
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
      lat: _lat,
      lon: _lon,
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
  function registerValidator(string calldata _url) external {
    require(!validatorAlreadyExists[msg.sender], "Validator is already registered");
    validators.push(Validator({ addr: msg.sender, url: _url }));
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

  function buy(uint256 insuranceid, uint256 root, uint256 nullifierHash, uint256[8] calldata proof) external payable {
    if (nullifierHashes[nullifierHash]) revert InvalidNullifier();
    worldId.verifyProof(
      root,
      groupId, // set to "1" in the constructor
      abi.encodePacked(msg.sender).hashToField(),
      nullifierHash,
      externalNullifierHash,
      proof
    );
    nullifierHashes[nullifierHash] = true;
    require(!clientinsured[msg.sender][insuranceid], "The client has already taken this type of insurance");
    require(msg.value > 0, "The client should send ETH to buy insurance");
    uint256 temppayout = msg.value * insurances[insuranceid].riskDenominator;
    require(temppayout < insuranceliquidity[insuranceid], "You should buy with less ETH");
    require(insuranceliquidity[insuranceid] > 0, "Liquidity does not exist for this insurance");
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
  function claimInsurancePayout(uint256 insuranceid) external returns (bytes32) {
    Insurance memory instance = insurances[insuranceid];
    require(clientinsured[msg.sender][insuranceid], "Client does not have insurance");
    string[] memory args = new string[](6);
    args[0] = Strings.toString(insuranceid);
    args[1] = Strings.toString(uint256(instance.typeOfIns));
    args[2] = instance.lat;
    args[3] = instance.lon;
    args[4] = Strings.toString(instance.start);
    args[5] = Strings.toString(instance.end);
    FunctionsRequest.Request memory req;
    req.initializeRequestForInlineJavaScript(source); // Initialize the request with JS code
    for (uint256 i = 0; i < validators.length; i++) {
      args[6] = validators[i].url;
      req.setArgs(args);
      s_lastRequestId = _sendRequest(req.encodeCBOR(), uint64(3217), gasLimit, donID);
      requestsperclaim[insuranceid].push(s_lastRequestId);
    }
    return s_lastRequestId;
  }
  /**
   * @notice Sends an HTTP request for character information
   * @param subscriptionId The ID for the Chainlink subscription
   * @param args The arguments to pass to the HTTP request
   * @return requestId The ID of the request
   */
  function sendRequest(uint64 subscriptionId, string[] calldata args) internal returns (bytes32 requestId) {}

  /**
   * @notice Callback function for fulfilling a request
   * @param requestId The ID of the request to fulfill
   * @param response The HTTP response data
   * @param err Any errors from the Functions request
   */
  function fulfillRequest(bytes32 requestId, bytes memory response, bytes memory err) internal override {
    if (s_lastRequestId != requestId) {
      revert UnexpectedRequestID(requestId); // Check if request IDs match
    }
    // Update the contract's state variables with the response and any errors
    s_lastResponse = response;
    s_lastError = err;

    // Emit an event to log the response
    emit Response(requestId, s_lastResponse, s_lastError);
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
