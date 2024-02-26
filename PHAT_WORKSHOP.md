# Connecting Your Subgraph to Your On-chain Smart Contract w/ Phat Contract

## We Deployed a Subgraph, What Now?
Now that you are familiar with deploying a Full-stack dApp using The Graph, what else do you think you can build with the indexed data in your subgraph?

Here are some questions to think about:
- Can I bring this subgraph data on-chain?
- How would I connect this data on-chain without access to the Internet?
- If I had access to this data, what can I do with it?
- Can I drive business logic based on the data returned back to my Smart Contract?
- Can we access our indexed data in a decentralized way?

## How Can We Answer These Questions?
Many of these questions may be on top of every Web3 devs mind, but the answers here can vary. What we will dive into today will be how to access indexed data from your subgraph to build a data-driven dApp.

### What We Will Accomplish
We have already gone through The Graph demo, so we should be comfortable with the overall development flow. Now we will clone a new repository that has added an off-chain program called a Phat Contract, so we can connect our indexed data to our Smart Contract on-chain.

### Getting Started
#### Clone the repository
```shell
git clone git@github.com:HashWarlock/full-stack-phat-dapp-workshop.git
```

#### Set Up The Graph
You can follow the same steps described in the [WORKSHOP.md](./WORKSHOP.md) to get started familiar if you have not gone through the steps before.

#### Test Connecting Our Subgraph On-chain
Build your Phat Contract program
```shell
yarn phat:build
```
Watch for new `request(address target)` executed on-chain
```shell
yarn phat:watch
```
