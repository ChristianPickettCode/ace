const { expect } = require("chai");
const { ethers } = require("hardhat");

const { vrfCoordinatorRinkeby, linkTokenRinkeby, keyHashRinkeby, linkFee, names, cardImages, numbers, suits, setImages } = require("../scripts/constants")

describe("House", function () {
  it("successfully deployed house", async function () {
    const House = await ethers.getContractFactory("House");
    console.log("deploying...")
    const house = await House.deploy(vrfCoordinatorRinkeby, linkTokenRinkeby, keyHashRinkeby, names, cardImages, numbers, suits, setImages);
    console.log("....")
    console.log(house.deployTransaction.hash)
    await house.deployed();
    console.log("Contract deployed to:", house.address);

  });
});
