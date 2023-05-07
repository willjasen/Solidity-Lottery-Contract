# Lottery Smart Contract

This is a simple Ethereum lottery smart contract built using Solidity. Participants can enter the lottery by sending a specified amount of Ether to the contract. Once enough participants have entered, the contract owner (manager) can choose a random winner who will receive the entire pool of Ether.

## Repository Structure

```
.
├── contracts
│   └── Lottery.sol
├── test
│   └── lottery.test.js
├── deploy.js
├── package.json
└── README.md
```

## Prerequisites

- Node.js v10 or later
- npm or yarn
- Truffle
- Ganache

## Getting Started

1. Install Truffle globally:

```bash
npm install -g truffle
```

2. Clone the repository and navigate to the project directory:

```bash
git clone https://github.com/yourusername/lottery-smart-contract.git
cd lottery-smart-contract
```

3. Install the required dependencies:

```bash
npm install
```

4. Run Ganache to start a local Ethereum network:

```bash
ganache-cli
```

5. Compile the smart contracts:

```bash
truffle compile
```

6. Deploy the smart contracts:

```bash
truffle migrate
```

## Testing

Run the test suite by executing:

```bash
truffle test
```

## Deploying to a live network

To deploy the smart contract to a live network, update the `deploy.js` file with the appropriate configuration for your target network. For example, to deploy to the Ropsten test network:

```javascript
const HDWalletProvider = require('@truffle/hdwallet-provider');
const { mnemonic, infuraKey } = require('./secrets.json');

module.exports = {
  networks: {
    ropsten: {
      provider: () => new HDWalletProvider(mnemonic, `https://ropsten.infura.io/v3/${infuraKey}`),
      network_id: 3,
      gas: 5500000,
    },
  },
};
```

You will need to create a `secrets.json` file in the project root directory containing your mnemonic and Infura key:

```json
{
  "mnemonic": "YOUR_MNEMONIC_HERE",
  "infuraKey": "YOUR_INFURA_KEY_HERE"
}
```

After updating the configuration, run the following command to deploy to the live network:

```bash
truffle migrate --network ropsten
```

