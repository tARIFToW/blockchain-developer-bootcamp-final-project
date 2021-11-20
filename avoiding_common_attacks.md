# Common Attack Protection Measures

# [CWE-330: Weak Sources of Randomness from Chain Attributes](https://swcregistry.io/docs/SWC-120)

Through integration with Chainlink's **VRFConsumerBase** `requestRandomness` feature we have averted the risk of insufficiently random numbers when electing a lottery winner. 

# [SWC-107: Reentrancy](https://swcregistry.io/docs/SWC-107)

By setting the completed field of a lottery immediately after a critical size has been reached, the contract protects itself from bad actors wanting to increase their chances of winning the lottery by triggering multiple requestRandomness functions and thereby electing a new winner for the lottery.

# [SWC-101: Integer Overflow and Underflow](https://swcregistry.io/docs/SWC-101)

By using the SafeMath library when working with numbers in the contract we remediate the risk of integer over- and/or under-flow