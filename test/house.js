const { expect } = require("chai");
const { ethers } = require("hardhat");

const { vrfCoordinatorRinkeby, linkTokenRinkeby, keyHashRinkeby, linkFee, names, cardImages, numbers, suits, setImages, deckImage } = require("../scripts/constants")

describe("House", function () {

  let House;
  let houseContract;
  let owner;
  let addr1;
  let addr2;
  let addrs;

  beforeEach(async function() {
    House = await ethers.getContractFactory("House");
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
    houseContract = await House.deploy(vrfCoordinatorRinkeby, linkTokenRinkeby, keyHashRinkeby, names, cardImages, numbers, suits, setImages, deckImage);
    await houseContract.deployed();
  })

  it("balance should be zero", async function () {
    const ownerBalance = await houseContract.balanceOf(owner.address);
    expect(ownerBalance).to.equal(0);
  });

  it("successfully mint card", async function () {
    let cardIndex = 0;
    let tokenID = 1;
    let txn = await houseContract.mint(cardIndex);
    await txn.wait();
    const ownerBalance = await houseContract.balanceOf(owner.address);
    expect(ownerBalance).to.equal(1);
    const cardAttributes = await houseContract.nftHolderAttributes(tokenID)
    expect(cardAttributes.cardIndex).to.equal(0);
    expect(cardAttributes.number).to.equal("Ace");
    expect(cardAttributes.suit).to.equal("Spades");
    expect(cardAttributes.name).to.equal("Ace of Spades");
  });

  it("successfully mint set", async function () {
    for(let i = 0; i < 13; i++) {
      let txn = await houseContract.mint(i);
      await txn.wait();
    }

    let ownerBalance = await houseContract.balanceOf(owner.address);
    expect(ownerBalance).to.equal(13);

    let txn = await houseContract.mintSet([1,2,3,4,5,6,7,8,9,10,11,12,13]);
    await txn.wait();

    ownerBalance = await houseContract.balanceOf(owner.address);
    expect(ownerBalance).to.equal(1);
    const cardAttributes = await houseContract.nftHolderAttributes(14)
    expect(cardAttributes.cardIndex).to.equal(0);
    expect(cardAttributes.number).to.equal("");
    expect(cardAttributes.suit).to.equal("Spades");
    expect(cardAttributes.name).to.equal("Spades");
  });

  it("successfully mint deck", async function () {
    let arr = [];
    for(let i = 0; i < 52; i++) {
      let txn = await houseContract.mint(i);
      await txn.wait();
      arr.push(i+1);
    }

    let ownerBalance = await houseContract.balanceOf(owner.address);
    expect(ownerBalance).to.equal(52);

    const [spades, diamonds, clubs, hearts] = splitIntoChunk(arr, 13);

    let txn = await houseContract.mintSet(spades);
    await txn.wait();

    txn = await houseContract.mintSet(diamonds);
    await txn.wait();

    txn = await houseContract.mintSet(clubs);
    await txn.wait();

    txn = await houseContract.mintSet(hearts);
    await txn.wait();

    ownerBalance = await houseContract.balanceOf(owner.address);
    expect(ownerBalance).to.equal(4);

    txn = await houseContract.mintDeck([53,54,55,56]);
    await txn.wait();

    const cardAttributes = await houseContract.nftHolderAttributes(57)
    expect(cardAttributes.cardIndex).to.equal(0);
    expect(cardAttributes.number).to.equal("");
    expect(cardAttributes.suit).to.equal("");
    expect(cardAttributes.name).to.equal("Deck");

    ownerBalance = await houseContract.balanceOf(owner.address);
    expect(ownerBalance).to.equal(1);

  });
});

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
