// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;


contract InsuranceData {
    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/

    address private contractOwner;                                      // Account used to deploy contract
    bool private operational = true;                                    // Blocks all state changes throughout the contract if false
    mapping (address => bool) private registeredInsuranceProvider;
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
    mapping(address => uint) public accountBalance;
    mapping(address => mapping(uint256 => bool)) private clientinsured;
    mapping(uint256 =>address[]) private insuranceProviderInsurees;
    mapping(address =>mapping(uint256 => uint)) insuredamount;
    mapping(address => uint) private fundedinsurance;
    mapping(uint256 =>mapping(address => uint)) insuredpayout;
    address[] multiAddress = new address[](0);
    mapping (address => bool) private multiCalls;
    uint8 public counter;
    address private f;
    uint256 public insuranceId;

    event ContractAuthorized(address contractAddress);
    event ContractDeauthorized(address contractAddress);
    event InsuranceBought(address insuree, uint256 insuranceid);
    event InsuranceAdded(address provider);
    event InsuranceClaimed(address insuree, uint256 payout);
    uint256 public constant REGISTRATION_FUND = 10 ether;
    uint256 public constant MIN_FUNDING_AMOUNT = 10 ether;
    /********************************************************************************************/
    /*                                       EVENT DEFINITIONS                                  */
    /********************************************************************************************/


    /**
    * @dev Constructor
    *      initialize global variable for insurance ids
    */
    constructor()
    {
        contractOwner = msg.sender;
        insuranceId = 0;
    }
    /**
    * @dev Modifier that requires the "operational" boolean variable to be "true"
    *      This is used on all state changing functions to pause the contract in
    *      the event there is an issue that needs to be fixed
    */
    modifier requireIsOperational()
    {
        require(operational, "Contract is currently not operational");
        _; 
    }

    /**
    * @dev Modifier that requires the "ContractOwner" account to be the function caller
    */
    modifier requireContractOwner()
    {
        require(msg.sender == contractOwner, "Caller is not contract owner");
        _;
    }

     modifier requireIsCallerInsuranceRegistered(address caller)
    {
        require( registeredInsuranceProvider[caller] == true, "Caller not registered");
        _;
    }
    modifier requireIsCallerAuthorized()
    {
        require(authorizedContracts[msg.sender] == true, "Caller is not contract owner");
        _;
    }

    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/

    function isNotInsured(uint256 insuranceid)
                    external
                    view
                    returns(bool)
    {
        uint amount = insuredamount[msg.sender][insuranceid];
        return(amount == 0);
    }

    function isInsuranceProviderRegistered(address registeredInsuranceProviderAddress)
                            public
                            view
                            returns (bool)
    {
        return registeredInsuranceProvider[registeredInsuranceProviderAddress];
    }

    /**
    * @dev Get operating status of contract
    *
    * @return A bool that is the current operating status
    */
    function isOperational() public view returns(bool){
            return operational;
    }

    function numOfInsuranceProviders() public view returns(uint count){
            return providers.length;
    }
    function getCounter() public view returns(uint8){
      return counter;
    }
        /**
        * @dev Sets contract operations on/off
        *
        * When operational mode is disabled, all write transactions except for this one will fail
        */

    function setOperatingStatus
                              (
                                bool mode
                              )
                              external
                              requireIsCallerInsuranceRegistered(msg.sender)
        {
            require(mode != operational, "New mode must be different from existing mode");

            bool isDuplicate = false;
            if (multiCalls[msg.sender] == true) {
                  isDuplicate = true;
            }

            require(!isDuplicate, "Caller has already called this function.");

            multiAddress.push(msg.sender);
            counter++;
            multiCalls[msg.sender] = true;
            if (counter >= providers.length/2) {
                operational = mode;
                for(uint i=0;i<multiAddress.length; i++){
                  f = multiAddress[i];
                  delete multiCalls[f];
                }
                multiAddress = new address[](0);
                counter = 0;
            }
        }
    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/
   /**
    * @dev Add an insurance to the registration queue
    *      Can only be called from InsuranceApp contract
    *
    */
    function registerInsuranceProvider
                            (
                                address _provider
                            )
                            external
                            requireIsOperational
                            requireIsCallerAuthorized
                            returns(bool successfulRegistration)
    {
        registeredInsuranceProvider[_provider] = true;
        successfulRegistration = true;
        providers.push(_provider);
        return successfulRegistration;
    }


    function registerInsurance
                                (
                                    address _insuranceProvider,
                                    string calldata _insuranceName,
                                    uint256 _start,
                                    uint256 _end,
                                    TypeOfInsurance _typeOfIns,
                                    string calldata _description,
                                    uint256 _riskNumerator,
                                    uint256 _riskDenominator
                                )
                                external
                                payable
                                requireIsOperational
                                requireIsCallerAuthorized
                                returns(uint256)
    {
        require(availableInsurances[_insuranceName], "Insurance is already registered");
        require(msg.value>0, "The insurance provider should fund the insurance");
        insuranceId++;
        insurances[insuranceId] = Insurance({
            isRegistered: true,
            start: _start, 
            end: _end, 
            provider: _insuranceProvider,
            typeOfIns: _typeOfIns,
            name: _insuranceName, 
            description: _description, 
            riskNumerator: _riskNumerator,
            riskDenominator: _riskDenominator});
        availableInsurances[_insuranceName] = true;
        insurancelps[insuranceId].push(_insuranceProvider);
        insuranceliquidity[insuranceId] = msg.value;
        liquidityperlp[insuranceId][msg.sender] = msg.value;
        emit InsuranceAdded(_insuranceProvider);
        return insuranceId;
    }

    function getInsuranceProviders()
                external
                view
                returns(address[] memory)


    {
        return providers;
    }

    function getFundedInsuranceProviders()
                external
                view
                returns(address[] memory)
    {
      return alreadyFundedInsuranceProviders;
    }

    function getInsureeFunds(address insuree)
                external
                view
                returns(uint)
    {

        return accountBalance[insuree];
    }

     /**
     * @dev liquidity providers can deposit funds in any amount to support any insurance
     */
     function fundInsurance(uint256 insuranceid) public
                             payable
                             requireIsOperational
                             requireIsCallerAuthorized
                             returns(uint)
     {
        require(hasProvidedLiquidity[insuranceid][msg.sender], "The liquidity provider has already provisioned liquidity for this insurance");
        numliquidityproviders[insuranceid]++;
        insuranceliquidity[insuranceid] = insuranceliquidity[insuranceid] + msg.value; 
        insurancelps[insuranceid].push(msg.sender);
        liquidityperlp[insuranceid][msg.sender] = msg.value;
        return insuranceid;
     }

    /**
     * @dev to see how much fund an insurance is supported with
     */
    function getInsuranceFunds
                            (
                                uint256 insuranceid
                            )
                            external
                            view
                            requireIsOperational
                            requireIsCallerAuthorized
                            returns(uint256)

    {
        return insuranceliquidity[insuranceid];
    }
    /**
    * @dev Buy weather insurance.
    *
    */

     function buy (uint256 insuranceid)
                            external
                            payable
                            requireIsOperational
                            requireIsCallerAuthorized
    {

        require(!clientinsured[msg.sender][insuranceid], "The client has already taken this type of insurance");
        require(msg.value>0, "The client should send ETH to buy insurance");
        uint256 temppayout = msg.value * insurances[insuranceid].riskDenominator;
        require(temppayout<insuranceliquidity[insuranceid], "You should buy with less ETH");
        claimablePayout[msg.sender][insuranceid] = temppayout;
        clientinsured[msg.sender][insuranceid]=true;
        insuranceProviderInsurees[insuranceid].push(msg.sender);
        insuredamount[msg.sender][insuranceid]= msg.value;
        for (uint256 i = 0; i < insurancelps[insuranceid].length; i++) {
            uint lpperc = (liquidityperlp[insuranceid][insurancelps[insuranceid][i]]/insuranceliquidity[insuranceId])*100;
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
    function payout( uint256 insuranceid, address insuree) external
    returns(uint)
    {
        require(insuredpayout[insuranceid][insuree]==0, "The client has already claimed payout");
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