const HDWalletProvider = require('@truffle/hdwallet-provider');
const { mnemonic, infuraKey } = require('./secrets.json');

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*",
    },
    sepolia: {
      provider: () => new HDWalletProvider(mnemonic, `https://sepolia.infura.io/v3/${infuraKey}`),
      network_id: 11155111,
      gas: 7000000, // Higher gas limit (adjust based on contract size)
      gasPrice: 30000000000, // 30 Gwei
    },
  },
  compilers: {
    solc: {
      version: "0.4.17",
    },
  },
};
