const { expect } = require("chai");

let BankContract;
let bank;

let owner;
let addr1;
let addr2;
let addrs;

before(async () => {
  BankContract = await ethers.getContractFactory("Bank");
  [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

  bank = await BankContract.deploy();
});

it("should created a new account", async () => {
  await bank.connect(addr1).openAccount();

  expect(await bank.connect(addr1).viewAccountBalance()).to.equal(0);

  await expect(bank.connect(addr1).openAccount()).to.be.revertedWith(
    "You already have an account"
  );
});

it("should deposit ETHs", async () => {
  await bank.connect(addr1).deposit({ value: ethers.utils.parseEther("0.5") });

  expect(await bank.connect(addr1).viewAccountBalance()).to.equal(
    ethers.utils.parseEther("0.5")
  );
});

it("should withdraw ETHs", async () => {
  await bank.connect(addr1).withdraw(ethers.utils.parseEther("0.5"));

  expect(await bank.connect(addr1).viewAccountBalance()).to.equal(0);

  await expect(
    bank.connect(addr1).withdraw(ethers.utils.parseEther("0.5"))
  ).to.be.revertedWith("Insufficient balance");
});

it("should close an account", async () => {
  await bank.connect(addr1).closeAccount();

  await expect(bank.connect(addr1).closeAccount()).to.be.revertedWith(
    "You don't have an account"
  );
});
