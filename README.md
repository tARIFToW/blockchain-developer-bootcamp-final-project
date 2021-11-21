# blockchain-developer-bootcamp-final-project

## What does the project do?
The project lets users create lotteries for a provided number of participants and ticket price. The creators of a lottery will earn a share of the lottery proceeds as an incentive to create and market further lotteries. Participating users have the option of buying lottery tickets for a given price. Once the required number of participants for a given lottery is reached a ticket holder will be selected at random and will receive the funds paid into the lottery.

The randomness for electing a lottery winner is achieved using the Chainlink VRFConsumerBase oracle.

The contract has been deployed to the Rinkeby testnet.

## Workflow
1. Create Lottery
2. Buy Lottery ticket
3. Get a certain number of participants to join your lottery

## Accessing the frontend
You can access the frontend [here](https://tariftow.github.io/blockchain-developer-bootcamp-final-project/). To view a screencast [visit](https://drive.google.com/file/d/1bNsSN-SJnogjmFn4Rdxc0Ffk-mtSWdpP/view?usp=sharing)

:warning:  **Make sure you are connecting a rinkeby wallet**: Be very careful here!

## Getting started
To install the local dependencies run `npm install` in both the `root` and `frontend` directory of the project. To run the frontend, call `npm run start` in the `frontend` directory.

To run the contract tests, run `ganache-cli` (host: `127.0.0.1` port: `8545`) and `truffle test` in the root directory.

## Directory Structure
The contract code and the associated infrastructure can be found in the `root` of the repo. The frontend source code can be in the `frontend` directory.
# My Ethereum address is 0xBFdDB0906E960c1B3D965B6bd291208E8C5bbaD1
