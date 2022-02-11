// scripts/run.js

const { vrfCoordinatorRinkeby, linkTokenRinkeby, keyHashRinkeby, linkFee, names, cardImages, numbers, suits, setImages, deckImage } = require("./constants")

async function main () {
    const House = await ethers.getContractFactory("House");
    // const house = await House.attach("");
    console.log("deploying...")
    const house = await House.deploy(vrfCoordinatorRinkeby, linkTokenRinkeby, keyHashRinkeby, names, cardImages, numbers, suits, setImages, deckImage);
    console.log("....")
    console.log(house.deployTransaction.hash)
    await house.deployed();
    console.log("Contract deployed to:", house.address);

    let arr = [];
    for(let i = 0; i < 52; i++) {
      let txn = await house.mint(i);
      await txn.wait();
      arr.push(i+1);
      console.log(`minting card: ${i+1}`)
    }

    const [spades, diamonds, clubs, hearts] = splitIntoChunk(arr, 13);

    let txn = await house.mintSet(spades);
    await txn.wait();
    console.log("Minting set: spades")

    txn = await house.mintSet(diamonds);
    await txn.wait();
    console.log("Minting set: diamonds")

    txn = await house.mintSet(clubs);
    await txn.wait();
    console.log("Minting set: clubs")

    txn = await house.mintSet(hearts);
    await txn.wait();
    console.log("Minting set: hearts")

    txn = await house.mintDeck([53,54,55,56]);
    await txn.wait();
    console.log("Minting deck")
    for(let i = 0; i < 60; i++) {
        let txn = await house.mintCard();
        await txn.wait();
        console.log(`minting random card: ${i+1}`)
    }

    // txn = await house.requestNewRandomCard();
    // await txn.wait();

}

function splitIntoChunk(array, chunk) {
    let arr = [];
    for (i=0; i < array.length; i += chunk) {

        let tempArray;
        tempArray = array.slice(i, i + chunk);
        // console.log(tempArray);
        arr.push(tempArray)
    }
    return arr;
}
  
main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

