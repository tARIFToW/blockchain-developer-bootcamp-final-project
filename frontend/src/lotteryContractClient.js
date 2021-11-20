import Web3 from 'web3';
import {abi} from './abi.js';

export class LotteryContractClient {
  constructor (account){
    this.web3 = new Web3(window.ethereum)
    this.contract = new this.web3.eth.Contract(abi, '0x8e56F69c9f3fE4Eb30b6A62c01Ab4E947E831E3F') 
    this.account = account;
  }

  async getLotteries() {
    const lotteries = await this.contract.methods.getLotteries().call();
    const parsedLotteries = [];
    lotteries.forEach(lottery => {
      parsedLotteries.push({
        id: lottery.id,
        name: lottery.name,
        size: Number(lottery.size),
        ticketHolderCount: Number(lottery.ticketHolderCount),
        ticketPrice: Number(lottery.ticketPrice),
        owner: lottery.owner,
        ownerCommission: lottery.ownerCommission,
        completed: lottery.completed,
        winner: lottery.winner,
      })
    });
    return parsedLotteries;
  }

  async buyTicket(lotteryId, value) {
    await this.contract.methods.buyTicket(lotteryId).send({ from: this.account, value: value });
  }

  async createLottery(name, size, price, commission) {
    await this.contract.methods.createLottery(name, size, Web3.utils.toWei(price.toString(), 'ether'), commission).send({from: this.account });
  }
}