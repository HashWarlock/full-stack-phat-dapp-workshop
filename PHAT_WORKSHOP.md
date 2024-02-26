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

Now let's take a look at what happens in the `yarn phat:watch" terminal when we execute `setGreeting()` and then execute `request(address target)`.
```shell
Listening for YourContract MessageQueued events...
Received event [MessageQueued]: {
  tail: 1n,
  data: '0x0000000000000000000000000000000000000000000000000000000000000002000000000000000000000000af7344c69c1e288221eae307ac66bf232447be1a'
}
handle req: 0x0000000000000000000000000000000000000000000000000000000000000002000000000000000000000000af7344c69c1e288221eae307ac66bf232447be1a
[2]: 0xaf7344C69C1e288221Eae307AC66Bf232447Be1A
Request received for profile 0xaf7344C69C1e288221Eae307AC66Bf232447Be1A
hi
{
  statusCode: 200,
  reasonPhrase: '200',
  body: `{"data":{"greetings":[{"id":"0x1e277797760923a4b7026180215d0aeabafcd6bebd5f9f80ebf6ee75ecc06dcf-0","greeting":"What's good?","premium":false,"value":"0","createdAt":"1708977594","sender":{"address":"0xaf7344c69c1e288221eae307ac66bf232447be1a","greetingCount":"3"}},{"id":"0x3a6fb4d22e7c4bf1845b45b9bca3414410bf2f9ccf4be2dca34f371cf7082c85-0","greeting":"Help Me!","premium":false,"value":"0","createdAt":"1708977610","sender":{"address":"0xaf7344c69c1e288221eae307ac66bf232447be1a","greetingCount":"3"}},{"id":"0xd2eff0b9935b1fa2618a6494acc28fc230e433a2f43f1ec6af896fe4cebfe2ba-0","greeting":"How how are ya?","premium":false,"value":"0","createdAt":"1708977602","sender":{"address":"0xaf7344c69c1e288221eae307ac66bf232447be1a","greetingCount":"3"}}]}}`,
  headers: {
    'access-control-allow-origin': '*',
    'access-control-allow-headers': 'Content-Type, User-Agent',
    'access-control-allow-methods': 'GET, OPTIONS, POST',
    'content-type': 'application/json',
    'graph-attestable': 'true',
    'content-length': '752',
    date: 'Mon, 26 Feb 2024 20:01:39 GMT'
  }
}
{"data":{"greetings":[{"id":"0x1e277797760923a4b7026180215d0aeabafcd6bebd5f9f80ebf6ee75ecc06dcf-0","greeting":"What's good?","premium":false,"value":"0","createdAt":"1708977594","sender":{"address":"0xaf7344c69c1e288221eae307ac66bf232447be1a","greetingCount":"3"}},{"id":"0x3a6fb4d22e7c4bf1845b45b9bca3414410bf2f9ccf4be2dca34f371cf7082c85-0","greeting":"Help Me!","premium":false,"value":"0","createdAt":"1708977610","sender":{"address":"0xaf7344c69c1e288221eae307ac66bf232447be1a","greetingCount":"3"}},{"id":"0xd2eff0b9935b1fa2618a6494acc28fc230e433a2f43f1ec6af896fe4cebfe2ba-0","greeting":"How how are ya?","premium":false,"value":"0","createdAt":"1708977602","sender":{"address":"0xaf7344c69c1e288221eae307ac66bf232447be1a","greetingCount":"3"}}]}}
[1]: What's good?
[1]: Help Me!
[1]: How how are ya?
response: 0,2,What's good?,Help Me!,How how are ya?
JS Execution output: 0x0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000000c57686174277320676f6f643f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000848656c70204d6521000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f486f7720686f77206172652079613f0000000000000000000000000000000000
```

Awesome! We can now know that we are able to bring indexed data from The Graph on-chain. You can see that the `address target` changed the greeting a few times with `What's good?`, `Help Me!`, and `How how are ya?`.

### Let's Do Something With This Data!
You may notice in your SE2 Debug page, that there is another Smart Contract called `YourCollectible.sol`. How about we try something fun?! 

Let's take the data returned from our HTTP request about the history of greeting changes for a target address, and check for a special greeting `Help Me!`. If the greeting is detected then we will mint a special on-chain NFT Buoy to help our poor stranded target address with a special color based on some on-chain randomness.

#### Update Your Phat Contract
First we will need to update some logic in our Phat Contract located in [phat-contract](./packages/phat/src/index.ts)
[TODO]

#### Update YourContract.sol `_onMessageReceived(bytes calldata action)`
We will update the business logic of our Smart Contract to call the `YourCollectible.sol` `mintItem(address to)` function if the target address was detected to have said `Help Me!` at any point of the indexed history.
[TODO]

### Prove That It Works Locally
Let's start testing locally and spin up a new SE2 local setup like we did previously in `Getting Started`.

[TODO]

## Taking Our Talents to Testnet
Now that we have proved out the implementation, we can take our project to testnet. Since Phat Contract's support any EVM compatible chain, we can choose a testnet that fits our development needs best. We will stick to what you already know from the previous workshop and deploy to ETH Sepolia.

### Create Your Phala Dashboard Profile
You will notice that when you created your burner deployer account with `yarn generate`, a `.env` file was created under the `./packages/phat/` folder. We will use this account to import into Metamask. We will then go to https://dashboard.phala.network to get some Test Tokens.

#### Create Profile
We have funds in our account now, so lets create our dashboard profile with the following command.
```shell
yarn phat:create-profile
```
You should see a similar output to below:
```shell
✓ Connected to the endpoint: wss://poc6.phala.network/ws

You are connecting to a testnet.

Your address is 3zyngU9q5ksUp3dJoJCiHqhZ8Up89wND3DyHj8hynr6iv9zD

✓ Your Dashboard Profile does not exist
✓ Account balance: 5000 PHA
✓ Profile Created.

Your profile is ready to use.

You can continuing with CLI or Web UI: https://dashboard.phala.network/
```

#### Deploy Your Smart Contracts
[TODO]

#### Deploy Your Subgraph
[TODO]

#### Deploy to Phala's PoC6 Testnet
We are to deploy our Phat Contract to PoC6 Testnet now.
> **NOTE** 
> 
> Make sure to: 
> - `CONSUMER_CONTRACT_ADDRESS` to your deployed `YourContract.sol`
> - `RPC_URL` to your testnet RPC. You can get one from https://alchemy.com
> - Add gas funds to your gas account located in https://dashboard.phala.network/user-profile

```shell
yarn phat:test-deploy --coreSettings='{"apiUrl": "https://<your-subgraph-http-endpoint>"}'
```

You will see an `ATTESTOR_ADDRESS` in the output. You will copy this address and set the address to `PHALA_ORACLE_ATTESTOR` in your [./packages/hardhat/.env](./packages/hardhat/.env) file.

#### Set Your Attestor To Enable Smart Contract Connection
[TODO]
