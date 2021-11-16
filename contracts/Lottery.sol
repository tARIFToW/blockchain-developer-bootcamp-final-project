// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

/// @title A Factory of Lotteries (to be inherited by the LotteryTicket contract)
/// @author Alexander Wiederin
/// @notice this contract has not been throughly tested and may contain security issues if used on mainnet
abstract contract LotteryFactory is VRFConsumerBase {

  /// @notice the following three state variables are used for the VRFConsumerBase contract
  bytes32 internal keyHash;
  uint256 internal fee;
  uint256 public randomResult;

  using SafeMath for uint;

  /// @notice NewLottery is emitted when a new lottery is created
  event NewLottery(uint lotteryId, string name);
  /// @notice NewTicketPurchase is emitted when a new lotteryTicket is purchased
  event NewTicketPurchase(uint lotteryId);
  /// @notice NewWinner is emitted when a lottery has completed and a new winner has been elected
  event NewWinner(uint lotteryId, address winner);

     /**
     * Constructor inherits VRFConsumerBase
     * 
     * Network: Rinkeby
     * Chainlink VRF Coordinator address: 0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B
     * LINK token address:                0x01BE23585060835E02B77ef475b0Cc51aA1e0709
     * Key Hash: 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311
     */

  constructor()
    VRFConsumerBase(
      0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B,
      0x01BE23585060835E02B77ef475b0Cc51aA1e0709
      )
    {
        keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311;
        fee = 0.1 * 10 ** 18; // @dev Chainlink fee in rinkeby
    }

    
    /// @notice Struct used for the lottery entity
  struct Lottery {
    uint id;
    string name;
    uint size;
    uint ticketPrice;
    uint ticketHolderCount;
    bool completed;
    address payable owner;
    uint ownerCommission;
    address winner;
  }

  /// @notice List of all lotteries created 
  Lottery[] lotteries;
  /// @dev used to find the address of winning ticketholders
  mapping(uint => address payable[]) ticketHolders;
  /// @dev used to define an id for a new lottery 
  uint lotteryCount;
  /// @dev used in the Chainlink fullfillRandomness callback
  mapping(bytes32 => uint256) requestIdToLotteryId;

  /// @param _name given name of contract
  /// @param _size required possible seats on contract
  /// @param _ticketPrice price for each ticket in the lottery
  /// @param _ownerCommission commission to the lottery creator once lottery has been completed
  function createLottery(string memory _name, uint _size, uint _ticketPrice, uint _ownerCommission) public {
    lotteries.push(Lottery(lotteryCount, _name, _size, _ticketPrice, 0, false, payable(msg.sender), _ownerCommission, address(0)));
    lotteryCount++;
    emit NewLottery(lotteryCount, _name);
  }

  /// @dev returns all lotteries ever created
  function getLotteries() view public returns (Lottery[] memory) {
    return lotteries;
  }

  /// @dev a lottery for a provided id
  /// @param _id id of requested lottery
  function getLottery(uint _id) view public returns (Lottery memory) {
    return lotteries[_id];
  }
  
  /// @dev returns contract balance
  function getBalance() public view returns (uint) { 
    return address(this).balance;
  }

  /// @dev returns array of ticketHolders for a specific lottery
  /// @param _lotteryId of requested lotteryTicketHolders
  function getTicketHolders(uint _lotteryId) public view returns (address payable[] memory) { 
    return ticketHolders[_lotteryId];
  }

  /// @dev returns the address payable for a provided lotteryId and ticketId
  /// @param _lotteryId id of completed lottery
  /// @param _ticketId id of winneing ticketHolder
  function _getWinnerAddress(uint _lotteryId, uint _ticketId) internal view returns (address payable) {
    address payable[] memory lotteryTicketHolders = getTicketHolders(_lotteryId);
    require(lotteryTicketHolders[_ticketId] != address(0), "winner must exist");
    return lotteryTicketHolders[_ticketId];
  }

  /// @dev returns the total funds paid for tickets of a specific lottery
  /// @param _lotteryId id of lottery
  function _getTotalPrize(uint _lotteryId) public view returns (uint) {
    Lottery memory lottery = lotteries[_lotteryId];
    return SafeMath.mul(lottery.size, lottery.ticketPrice);
  }

  /// @dev returns the calculated share of a lotteries total prize for a provided percentage value
  /// @param _lotteryId id of lottery
  /// @param _percentage percentage, example: 70% = 70
  function _getShare(uint _lotteryId, uint _percentage) internal view returns (uint) {
    Lottery memory lottery = lotteries[_lotteryId];
    uint totalPrize = SafeMath.mul(lottery.size, lottery.ticketPrice);
    return SafeMath.div(SafeMath.mul(totalPrize, _percentage), 100);
  }
}

contract LotteryTicket is LotteryFactory {

  /// @notice triggers the request for a random number using chainlink's requestRandomness
  /// @dev triggers the request for a random number using chainlink's requestRandomness
  /// @dev returns a requestId
  function _electWinner() internal returns (bytes32 requestId) {
    require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
    return requestRandomness(keyHash, fee);
  }

  /// @notice callback function called by chainlink when a random number is provided
  /// @notice this will trigger all subsequent functions to transfer the funds to winners and owners
  /// @param requestId id of request triggered in _electWinner
  /// @param randomness random uint256 to be used as random input
  function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
    uint256 lotteryId = requestIdToLotteryId[requestId];
    Lottery storage lottery = lotteries[lotteryId];
    uint winnerId = SafeMath.add(SafeMath.mod(randomness, lottery.size), 1);
    address payable winnerAddress = _getWinnerAddress(lottery.id, winnerId);
    lottery.winner = winnerAddress;
    _transferFundsToWinner(lottery, winnerAddress);
    _transferFundsToOwner(lottery);
    emit NewWinner(lotteryId, winnerAddress);
  }

  /// @notice calculates a winner's share of the lottery funds and makes necessary transfer
  /// @param _lottery lottery that is completed
  /// @param _winnerAddress address payable of winner
  function _transferFundsToWinner(Lottery memory _lottery, address payable _winnerAddress) internal {
    uint share = _getShare(_lottery.id, SafeMath.sub(100, _lottery.ownerCommission));
    (bool success, ) = _winnerAddress.call { value: share }("");
    require (success, "Failed to send ether to winner");
  }

  /// @notice calculates an owner's share of the lottery funds and makes necessary transfer
  /// @param _lottery lottery that is completed
  function _transferFundsToOwner(Lottery memory _lottery) internal {
    uint share = _getShare(_lottery.id, _lottery.ownerCommission);
    (bool success, ) = _lottery.owner.call{ value: share }("");
    require(success, "Failed to send ether to owner");
  }

  /// @notice allocates a ticket to a buyer and triggers subsequent function calls if the lottery size has been reached
  /// @param _lotteryId Id of lottery that a ticket should be purchased for
  function buyTicket(uint _lotteryId) public payable {
    Lottery storage lottery = lotteries[_lotteryId];
    require(msg.value == lottery.ticketPrice);
    require(!lottery.completed);
    ticketHolders[_lotteryId].push(payable(msg.sender));
    lottery.ticketHolderCount++;
    emit NewTicketPurchase(lottery.id);
    if (lottery.ticketHolderCount == lottery.size) {
      lottery.completed = true;
      bytes32 requestId = _electWinner();
      requestIdToLotteryId[requestId] = lottery.id;
    }
  }
}