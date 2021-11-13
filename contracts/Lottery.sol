// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

abstract contract LotteryFactory is VRFConsumerBase {

  bytes32 internal keyHash;
  uint256 internal fee;
  uint256 public randomResult;

  using SafeMath for uint;

  event NewLottery(uint lotteryId, string name);

  constructor()
    VRFConsumerBase(
      0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B,
      0x01BE23585060835E02B77ef475b0Cc51aA1e0709
      )
    {
        keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311;
        fee = 0.1 * 10 ** 18;
    }

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

  Lottery[] lotteries;
  mapping(uint => address payable[]) ticketHolders;
  uint lotteryCount;
  mapping(bytes32 => uint256) requestIdToLotteryId;

  function createLottery(string memory _name, uint _size, uint _ticketPrice, uint _ownerCommission) public {
    lotteries.push(Lottery(lotteryCount, _name, _size, _ticketPrice, 0, false, payable(msg.sender), _ownerCommission, address(0)));
    lotteryCount++;
    emit NewLottery(lotteryCount, _name);
  }

  function getLotteries() view public returns (Lottery[] memory) {
    return lotteries;
  }

  function getLottery(uint _id) view public returns (Lottery memory) {
    return lotteries[_id];
  }
  
  function getBalance() public view returns (uint) { 
    return address(this).balance;
  }

  function getTicketHolders(uint _lotteryId) public view returns (address payable[] memory) { 
    return ticketHolders[_lotteryId];
  }

  function _getWinnerAddress(uint _lotteryId, uint _ticketId) internal view returns (address payable) {
    address payable[] memory lotteryTicketHolders = getTicketHolders(_lotteryId);
    require(lotteryTicketHolders[_ticketId] != address(0), "winner must exist");
    return lotteryTicketHolders[_ticketId];
  }

  function _getTotalPrize(uint _lotteryId) public view returns (uint) {
    Lottery memory lottery = lotteries[_lotteryId];
    return SafeMath.mul(lottery.size, lottery.ticketPrice);
  }

  function _getShare(uint _lotteryId, uint _percentage) internal view returns (uint) {
    Lottery memory lottery = lotteries[_lotteryId];
    uint totalPrize = SafeMath.mul(lottery.size, lottery.ticketPrice);
    return SafeMath.div(SafeMath.mul(totalPrize, _percentage), 100);
  }
}

contract LotteryTicket is LotteryFactory {

  function _electWinner() internal returns (bytes32 requestId) {
    return requestRandomness(keyHash, fee);
  }

  function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
    uint256 lotteryId = requestIdToLotteryId[requestId];
    Lottery storage lottery = lotteries[lotteryId];
    uint winnerId = SafeMath.add(SafeMath.mod(randomness, lottery.size), 1);
    address payable winnerAddress = _getWinnerAddress(lottery.id, winnerId);
    lottery.winner = winnerAddress;
    _transferFundsToWinner(lottery, winnerAddress);
    _transferFundsToOwner(lottery);
  }

  function _transferFundsToWinner(Lottery memory _lottery, address payable _winnerAddress) internal {
    uint share = _getShare(_lottery.id, SafeMath.sub(100, _lottery.ownerCommission));
    (bool success, ) = _winnerAddress.call { value: share }("");
    require (success, "Failed to send ether to winner");
  }

  function _transferFundsToOwner(Lottery memory _lottery) internal {
    uint share = _getShare(_lottery.id, _lottery.ownerCommission);
    (bool success, ) = _lottery.owner.call{ value: share }("");
    require(success, "Failed to send ether to owner");
  }

  function buyTicket(uint _lotteryId) public payable {
    Lottery storage lottery = lotteries[_lotteryId];
    require(msg.value == lottery.ticketPrice);
    require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
    require(!lottery.completed);
    ticketHolders[_lotteryId].push(payable(msg.sender));
    lottery.ticketHolderCount++;
    if (lottery.ticketHolderCount == lottery.size) {
      lottery.completed = true;
      bytes32 requestId = _electWinner();
      requestIdToLotteryId[requestId] = lottery.id;
    }
  }
}