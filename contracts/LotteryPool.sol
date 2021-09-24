// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract LotteryPool {
  uint poolSize;
  uint ticketPrice;
  uint ticketHolderCount;
  uint lotteryId;
  mapping (uint=> mapping(uint => address payable)) ticketHolders;

  event LogNewTicket(uint _ticketHolderCount, address _lotteryMember, uint balance);
  event LogLotteryComplete();

  modifier poolFull {
    require(poolSize == ticketHolderCount);
    _;
  }

  constructor(uint _ticketPrice, uint _poolSize) {
    poolSize = _poolSize;
    ticketPrice = _ticketPrice;
    lotteryId = 0;
  }

  receive() external payable {
    require(msg.value == ticketPrice);
    ticketHolders[lotteryId][ticketHolderCount] = payable(msg.sender);
    ticketHolderCount += 1;
    emit LogNewTicket(ticketHolderCount, msg.sender, address(this).balance);
    if (ticketHolderCount == poolSize) {
      transfer(electWinner());
      emit LogLotteryComplete();
      clearLottery();
    }
  }

  function clearLottery() private poolFull {
      ticketHolderCount = 0;
      lotteryId += 1;
  }

  function electWinner() private poolFull view returns (address payable) {
    uint randomIndex = 1; // TODO: use safemath to pick random index
    return ticketHolders[lotteryId][randomIndex];
  }

  function transfer(address payable _winnerAddress) private poolFull {
    (bool success, ) = _winnerAddress.call{ value: address(this).balance }("");
    require(success, "Failed to send ether");
  }
}