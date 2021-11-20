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
You can access the frontend [here](https://tariftow.github.io/blockchain-developer-bootcamp-final-project/).

:warning:  **Make sure you are connecting a rinkeby wallet**: Be very careful here!

## Getting started
To install the local dependencies run `npm install` in both the `root` and `frontend` directory of the project. To run the frontend, call `npm run start` in the `frontend` directory.

To run the contract tests, run `ganache-cli` and `truffle test` in the root directory.
