// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract LetzBet {
    //just bet testeth
    //players
    // withdraw before the game start
    // put money
    // then distribute to winners and earn commission
    // 0.5% of the wins will be distribute to me
    // the cap of commission is 0.1 eth for me

    //data structure
    //players, capital amount, and side
    //up pools
    //down pools
    //
    error LetzBet__BetAmountHaveToBeLargerThanZero();
    error LetzBet__FailToSendToOwner();
    error LetzBet__NeedToClearPreviousBetBeforePlacingNewBet();
    error LetzBet__FailToClearPreviousBet();


    struct BetDetails {
        bool upside;
        uint256 betAmount;
    }

    address public owner;
    uint256 public platformFeePercentage;
    uint256 public platformFeeMaxCap;
    uint256 public platformFeeMinCap;
    uint256 public prizePool;
    uint256 public upsidePool;
    uint256 public numberOfUpsidePlayers;
    uint256 public numberOfDownsidePlayers; 
    uint256 public downsidePool;
    mapping (address=> BetDetails) public bets; 

    constructor(address _owner, uint256 _platformFeePercentage, uint256 _platformFeeMaximumCap, uint256 _platformFeeMinimumCap){
        owner = _owner;
        platformFeePercentage = _platformFeePercentage;
        platformFeeMaxCap = _platformFeeMaximumCap;
        platformFeeMinCap = _platformFeeMinimumCap;
    }

    function placeBet(bool _upside) external payable {
        if (msg.value <= 0) {
            revert LetzBet__BetAmountHaveToBeLargerThanZero();
        }
        if(checkIfPlayerAlreadyHasBet(msg.sender)){
            revert LetzBet__NeedToClearPreviousBetBeforePlacingNewBet();
        }
        bets[msg.sender] = BetDetails({
            upside: _upside,
            betAmount: msg.value
        });
        if (_upside) {
            upsidePool += msg.value;
            numberOfUpsidePlayers++;
        } else {
            downsidePool += msg.value;
            numberOfDownsidePlayers++;
        }
    }

    function clearPreviousBet() external {
        uint256 betAmount = bets[msg.sender].betAmount;
        bool isUpside = bets[msg.sender].upside;
        (bool sent,) = msg.sender.call{value: betAmount}("");
        if(!sent){
            revert LetzBet__FailToClearPreviousBet();
        }
        if(isUpside){
            numberOfUpsidePlayers--;
        }else{
            numberOfDownsidePlayers--;
        }
    }

    function checkIfPlayerAlreadyHasBet(address player) private view returns (bool) {
        if(bets[player].betAmount <=0){
            return false;
        }else{
            return true;
        }
    }

    function getBetDetails(address _address) public view returns (bool, uint256) {
        BetDetails memory bet = bets[_address];
        return (bet.upside, bet.betAmount);
    }

    function sendMoneyToWinners(bool _upside) private {
        uint256 totalPool = upsidePool+downsidePool;
        uint256 platformFee = calculatePercentage(totalPool, platformFeePercentage);
        (bool sent,) = owner.call{value: platformFee}("");
        if (!sent) {
            revert LetzBet__FailToSendToOwner();
        }
        uint256 totalPoolAfterDeductingFee = totalPool - platformFee;

        if(upsidePool>downsidePool){
            for (uint256 i = 0; i <numberOfUpsidePlayers; i++){
                
            }
        }
        
    }

    function sendMoneyToOwner(uint256 totalPool) private {
    }

    function calculatePercentage(uint256 number, uint256 percentage) private pure returns (uint256) {
        return (number * percentage) / 100;
    }
}
