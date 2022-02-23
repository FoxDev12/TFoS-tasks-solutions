const { expect } = require("chai");

let ExtendedBankContract;
let extendedBank;

let TokenContract;
let token;

let owner;
let addr1;
let addr2;
let addrs;

before(async function () {
  ExtendedBankContract = await ethers.getContractFactory("ExtendedBank");
  TokenContract = await ethers.getContractFactory("TestToken");

  [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

  extendedBank = await ExtendedBankContract.deploy();
  token = await TokenContract.deploy();

  await token.transfer(addr1.address, 1000);
  await token.connect(addr1).approve(extendedBank.address, 1000);
});

it("should created a new account", async () => {
  await extendedBank.connect(addr1).openAccount();

  await expect(extendedBank.connect(addr1).openAccount()).to.be.revertedWith(
    "You already have an account"
  );
});

it("should deposit an ERC20 token", async () => {
  await extendedBank.connect(addr1).deposit(token.address, 100);

  expect(
    await token.allowance(addr1.address, extendedBank.address)
  ).to.be.equal(900);

  expect(
    await extendedBank.connect(addr1).getBalance(token.address)
  ).to.be.equal(100);
});

it("should withdraw an ERC20 token", async () => {
  await expect(
    extendedBank.connect(addr1).withdraw(token.address, 101)
  ).to.be.revertedWith("Not enough tokens");

  await extendedBank.connect(addr1).withdraw(token.address, 100);

  expect(
    await extendedBank.connect(addr1).getBalance(token.address)
  ).to.be.equal(0);
});

it("should close account", async () => {
  await extendedBank.connect(addr1).deposit(token.address, 100);

  await expect(extendedBank.connect(addr1).closeAccount()).to.be.revertedWith(
    "Account should be empty"
  );

  await extendedBank.connect(addr1).withdraw(token.address, 100);

  await extendedBank.connect(addr1).closeAccount();

  await expect(extendedBank.connect(addr1).closeAccount()).to.be.revertedWith(
    "You don't have an account"
  );
});
