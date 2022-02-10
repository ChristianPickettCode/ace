// scripts/run.js

const { vrfCoordinatorRinkeby, linkTokenRinkeby, keyHashRinkeby, linkFee, names, cardImages, numbers, suits, setImages } = require("./constants")

async function main () {
    const House = await ethers.getContractFactory("House");
    console.log("deploying...")
    const house = await House.deploy(vrfCoordinatorRinkeby, linkTokenRinkeby, keyHashRinkeby, names, cardImages, numbers, suits);
    console.log("....")
    console.log(house.deployTransaction.hash)
    await house.deployed();
    console.log("Contract deployed to:", house.address);

    // let txn = await house.mintCard();
    // await txn.wait();

    // txn = await house.mintCard();
    // await txn.wait();

    // txn = await house.requestNewRandomCard();
    // await txn.wait();

}
  
main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

