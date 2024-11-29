const HDWalletProvider = require("@truffle/hdwallet-provider");
const Web3 = require("web3");
const { mnemonic, infuraKey } = require("./secrets.json");

const provider = new HDWalletProvider(mnemonic, `https://sepolia.infura.io/v3/${infuraKey}`);
const web3 = new Web3(provider);

(async () => {
  const accounts = await web3.eth.getAccounts();
  const balance = await web3.eth.getBalance(accounts[0]);
  console.log("Balance for", accounts[0], "is", web3.utils.fromWei(balance, "ether"), "ETH");
  provider.engine.stop();
})();
