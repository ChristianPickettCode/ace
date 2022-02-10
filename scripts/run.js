// scripts/run.js

const { vrfCoordinator, linkToken, keyHash, linkFee, names, cardImages, numbers, suits, setImages } = require("./constants")

async function main () {
    const House = await ethers.getContractFactory("House");

    const house = await House.deploy(vrfCoordinator, linkToken, keyHash, names, cardImages, numbers, suits);
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

