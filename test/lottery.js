const Web3 = require('web3');
const LotteryTicket = artifacts.require("LotteryTicket");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("LotteryTicket", async (accounts) => {
  it("should have no lotteries when deployed", async () => {
    const lotteryContract = await LotteryTicket.deployed();
    const lotteries = await lotteryContract.getLotteries();
    return assert.equal(0, lotteries.length);
  })

  it("should create a new lottery", async () => {
    const lotteryContract = await LotteryTicket.deployed();
    await lotteryContract.createLottery("test", 2, Web3.utils.toWei('1', 'ether'), 10);
    const lotteries = await lotteryContract.getLotteries();
    return assert.equal(1, lotteries.length);
  })

  it("should be able to create 2 lottery", async () => {
    const lotteryContract = await LotteryTicket.deployed();
    await lotteryContract.createLottery("test 2", 2, Web3.utils.toWei('1', 'ether'), 10);
    const lotteries = await lotteryContract.getLotteries();
    return assert.equal(2, lotteries.length);
  })

  it("should be get the correct lottery", async () => {
    const lotteryContract = await LotteryTicket.deployed();
    const lottery = await lotteryContract.getLottery(1);
    assert.equal(lottery.id, 1);
    assert.equal(lottery.name, "test 2");
    assert.equal(lottery.size, 2);
    assert.equal(Web3.utils.fromWei(lottery.ticketPrice, 'ether'), 1);
    assert.equal(lottery.ownerCommission, 10);
    assert.equal(lottery.completed, false);
    })

    it("should increase the ticketHolderCount", async () => {
      const lotteryContract = await LotteryTicket.deployed();
      const result = await lotteryContract.buyTicket(1, {value: Web3.utils.toWei('1', 'ether'), from: accounts[0] });
      const lottery = await lotteryContract.getLottery(1);
      console.log(lottery);
      assert.equal(lottery.ticketHolderCount, 1);
      })
});
