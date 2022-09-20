![](cover.png)

**A set of challenges to learn offensive security of smart contracts in Ethereum.**

Featuring flash loans, price oracles, governance, NFTs, lending pools, smart contract wallets, timelocks, and more!

## Play

Visit [damnvulnerabledefi.xyz](https://damnvulnerabledefi.xyz)

## Disclaimer

All Solidity code, practices and patterns in this repository are DAMN VULNERABLE and for educational purposes only.

DO NOT USE IN PRODUCTION.

## Solutions

### Unstoppable
Since the `UnstoppableLender` contract contains the assertion `assert(poolBalance == balanceBefore);`, DVT can be transferred dirtectly to the contract causing this assertion to fail, breaking the contract.

### Naive Receiver
Since there is a fee of 1 ETH paid each time a flash loan is taken, and anyone can call the flashloan function, the contact can be drained of all ETH by calling the flashloan function 10 times.

### Truster
Since the `flashLoan` allows for calling any function, the `approve` function can be called on the DVT token allowing the attacker to withdraw any amount of DVT from the contract by using the ERC-20 `transferFrom` function.

### Side Entrance
This challenge can be solved by taking a flash loan from the pool and depositing the loan back into the pool using the `deposit` function. This gives the contract that made the flashloan the ability to later withdraw this ETH. The flashloan will succeed as the ETH balance of the flashloan pool will be the same.
