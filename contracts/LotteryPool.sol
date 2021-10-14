// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;

contract LotteryFactory {

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
  mapping(uint => mapping(uint => address payable)) ticketHolders;
  uint lotteryCount;

  function createLottery(string memory _name, uint _size, uint _ticketPrice, uint _ownerCommission) public {
    lotteries[lotteryCount] = Lottery(lotteryCount, _name, _size, _ticketPrice, 0, false, payable(msg.sender), _ownerCommission, address(0));
  }
}

contract LotteryTicket is LotteryFactory {

  function _electWinner(Lottery memory _lottery) internal pure returns (uint) {
    uint winnerId = 1; // use chainlink to generate random id between 0 and lotterySize
    return winnerId;
  }

  function _transferFundsToWinner(Lottery memory _lottery, uint _winnerId) internal {
    uint prize = (_lottery.size * _lottery.ticketPrice) * (100 - _lottery.ownerCommission);
    (bool success, ) = ticketHolders[_lottery.id][_winnerId].call { value: prize }("");
    require (success, "Failed to send ether");
  }

  function _transferFundsToOwner(Lottery memory _lottery) internal {
    uint commission = _lottery.size * _lottery.ticketPrice * _lottery.ownerCommission;
    (bool success, ) = _lottery.owner.call{ value: commission }("");
    require(success, "Failed to send ether");
  }

  function buyTicket(uint _lotteryId) public payable {
    Lottery storage lottery = lotteries[_lotteryId];
    require(msg.value == lottery.ticketPrice);
    require(!lottery.completed);
    lottery.ticketHolderCount++;
    if (lottery.ticketHolderCount == lottery.size) {
      uint winnerId = _electWinner(lottery);
      _transferFundsToWinner(lottery, winnerId);
      _transferFundsToOwner(lottery);
      lottery.completed = true;
    }
  }
}