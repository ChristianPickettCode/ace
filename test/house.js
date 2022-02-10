const { expect } = require("chai");
const { ethers } = require("hardhat");

const { vrfCoordinator, linkToken, keyHash, linkFee, names, cardImages, numbers, suits, setImages } = require("../scripts/constants")

describe("House", function () {
  it("successfully deployed house", async function () {
    const House = await ethers.getContractFactory("House");

    const house = await House.deploy(vrfCoordinator, linkToken, keyHash, names, cardImages, numbers, suits);
    await house.deployed();
    console.log("Contract deployed to:", house.address);

  });
});
