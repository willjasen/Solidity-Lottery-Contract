const HDWalletProvider = require(`@truffle/hdwallet-provider`);
const Web3 = require(`web3`);
const {interface, bytecode} = require(`./compile`)


const provider = new HDWalletProvider(
    `special foot slide leisure please talent bulb hazard advance crisp carry battle`,
    `https://goerli.infura.io/v3/11c493cddb9a48eea2e2351d58ab0657`
);

const web3 = new Web3(provider);

const deploy = async () => {
    const accounts = await web3.eth.getAccounts();

    console.log(`Attempting to deploy fom account`, accounts[0])
    const result = await new web3.eth.Contract(JSON.parse(interface)).deploy({
        data: bytecode,
    }).send({gas: 1000000, from: accounts[0]})

    console.log(`Contract Deployed to `, result.options.address);
    provider.engine.stop();
}

deploy();