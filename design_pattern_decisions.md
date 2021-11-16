# Design Patterns

# Inheritance and Interfaces

The LotteryTicket inherits from the LotteryFactory to separate concerns and make further development easier. Furthermore LotteryTicket makes use of the SafeMath Library to ensure safe calculations.

# Oracles

The LotteryTicket inherits Chainlink's VRFConsumerBase to make use of its requestRandomness function and retrieve access to a source of true randomness. Using ChanLink as source of randomness ensures that the elected winner has truly been picked at random in the lottery.
