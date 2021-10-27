const Web3 = require('web3');
const LotteryTicket = artifacts.require("LotteryTicket");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("LotteryTicket", async (accounts) => {
  const web3 = new Web3("http://127.0.0.1:8545");
  LotteryTicket.defaults({ gasPrice: 0 });
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

  it("should be able to create 2 lotteries", async () => {
    const lotteryContract = await LotteryTicket.deployed();
    await lotteryContract.createLottery("test 2", 3, Web3.utils.toWei('1', 'ether'), 10, {from: accounts[1]});
    const lotteries = await lotteryContract.getLotteries();
    return assert.equal(2, lotteries.length);
  })

  it("should get the correct lottery", async () => {
    const lotteryContract = await LotteryTicket.deployed();
    const lottery = await lotteryContract.getLottery(1);
    assert.equal(lottery.id, 1);
    assert.equal(lottery.name, "test 2");
    assert.equal(lottery.size, 3);
    assert.equal(Web3.utils.fromWei(lottery.ticketPrice, 'ether'), 1);
    assert.equal(lottery.ownerCommission, 10);
    assert.equal(lottery.completed, false);
    })

    it("should increase the ticketHolderCount and balance", async () => {
      const lotteryContract = await LotteryTicket.deployed();
      await lotteryContract.buyTicket(1, {value: Web3.utils.toWei('1', 'ether'), from: accounts[2] });
      await lotteryContract.buyTicket(1, {value: Web3.utils.toWei('1', 'ether'), from: accounts[3] });
      const lottery2 = await lotteryContract.getLottery(1);
      assert.equal(lottery2.ticketHolderCount, 2);
      const balance2 = await lotteryContract.getBalance();
      assert.equal(balance2, Web3.utils.toWei('2', 'ether'));
    })

    it("should complete lottery when size is reached", async () => {
      const lotteryContract = await LotteryTicket.deployed();
      await lotteryContract.buyTicket(1, {value: Web3.utils.toWei('1', 'ether'), from: accounts[4] });
      const lottery = await lotteryContract.getLottery(1);
      assert.equal(lottery.completed, true);
    })

    it("should transfer the correct amounts to the winner", async () => {
      const winningAddressBalance = await web3.eth.getBalance(accounts[2]);
      assert.equal(winningAddressBalance, Web3.utils.toWei('101.7', 'ether'));
    })

    it("should transfer the correct amounts to the owner", async () => {
      const ownerAddressBalance = await web3.eth.getBalance(accounts[1]);
      assert.equal(ownerAddressBalance, Web3.utils.toWei('100.3', 'ether'));
    })
});
