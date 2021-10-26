// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract LotteryFactory {

  using SafeMath for uint;

  event NewLottery(uint lotteryId, string name);

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

  function _getWinner(uint _lotteryId, uint _ticketId) internal view returns (address payable) {
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

  function _electWinner(Lottery memory _lottery) internal pure returns (uint) {
    uint winnerId = 0; // use chainlink to generate random id between 0 and lotterySize
    return winnerId;
  }

  function _transferFundsToWinner(Lottery memory _lottery, uint _winnerId) internal {
    address payable winner = _getWinner(_lottery.id, _winnerId);
    uint share = _getShare(_lottery.id, SafeMath.sub(100, _lottery.ownerCommission));
    (bool success, ) = winner.call { value: share }("");
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
    require(!lottery.completed);
    ticketHolders[_lotteryId].push(payable(msg.sender));
    lottery.ticketHolderCount++;
    if (lottery.ticketHolderCount == lottery.size) {
      uint winnerId = _electWinner(lottery);
      _transferFundsToWinner(lottery, winnerId);
      _transferFundsToOwner(lottery);
      lottery.completed = true;
    }
  }
}