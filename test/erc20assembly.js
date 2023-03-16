const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ERC20Assembly contract testing", () => {
    let deployer, Alice, Bob;
    let erc20AssemblyContract, erc20assembly;

    const name = "Example Token";
    const symbol = "ETK";
    const decimals = 18;

    beforeEach(async() => {
        [deployer, Alice, Bob] = await ethers.getSigners();

        erc20AssemblyContract = await ethers.getContractFactory("ERC20");
        erc20assembly = await erc20AssemblyContract.deploy();
    });

    describe("When deploying", () => {
        it("Total supply should equal the max uint", async() => {
            expect(await erc20assembly.totalSupply()).to.equal(ethers.constants.MaxUint256);
        });

        it("Deployer should hold the total supply", async() => {
            expect(await erc20assembly.balanceOf(deployer.address)).to.equal(ethers.constants.MaxUint256);
        });
    });

    describe("When calling the contract getters", () => {
        it("Should get the contract name", async() => {
            expect(await erc20assembly.name()).to.equal(name);
        });

        it("Should get the contract symbol", async() => {
            expect(await erc20assembly.symbol()).to.equal(symbol);
        });

        it("Should get the contract amount of decimals", async() => {
            expect(await erc20assembly.decimals()).to.equal(decimals);
        });
    });

    describe("When setting an approval", () => {
        it("User should be able to set approval", async() => {
            await erc20assembly.connect(deployer).approve(Alice.address, ethers.utils.parseEther("5"));

            expect(await erc20assembly.allowance(deployer.address, Alice.address))
                .to.equal(ethers.utils.parseEther("5"));
        });

        it("Allowance should not depend on owner balance", async() => {
            it("User should be able to set approval", async() => {
                await erc20assembly.connect(Alice).approve(Bob.address, ethers.utils.parseEther("5"));
    
                expect(await erc20assembly.allowance(Alice.address, Bob.address))
                    .to.equal(ethers.utils.parseEther("5"));
            });           
        });

        it("Allowance should reflect changes as expected", async() => {
            await erc20assembly.connect(deployer).approve(Alice.address, ethers.utils.parseEther("5"));
            await erc20assembly.connect(deployer).approve(Alice.address, ethers.utils.parseEther("8"));

            expect(await erc20assembly.allowance(deployer.address, Alice.address))
                .to.equal(ethers.utils.parseEther("8"));           
        });
    });

    describe("When transferring balance", () => {
        it("Should revert if balance is not enough", async() => {
            await expect(erc20assembly.connect(Alice).transfer(Bob.address, ethers.utils.parseEther("10"))).to.be.reverted;
        });

        it("Should modify balances when called succesfully", async() => {
            await erc20assembly.connect(deployer).transfer(Bob.address, ethers.utils.parseEther("10"));

            expect(await erc20assembly.balanceOf(deployer.address))
                .to.equal(ethers.constants.MaxUint256.sub(ethers.utils.parseEther("10")));

            expect(await erc20assembly.balanceOf(Bob.address))
                .to.equal(ethers.utils.parseEther("10"));            
        });     
        
        it("TransferFrom should revert if approval was not set", async() => {
            await expect(erc20assembly.connect(Alice).transferFrom(deployer.address, Bob.address, ethers.utils.parseEther("10")))
                .to.be.reverted;
        });

        it("TransferFrom should modify balances after approval", async() => {
            await erc20assembly.connect(deployer).approve(Alice.address, ethers.utils.parseEther("10"));
            await erc20assembly.connect(Alice).transferFrom(deployer.address, Bob.address, ethers.utils.parseEther("10"));

            expect(await erc20assembly.balanceOf(deployer.address))
                .to.equal(ethers.constants.MaxUint256.sub(ethers.utils.parseEther("10")));

            expect(await erc20assembly.balanceOf(Bob.address))
                .to.equal(ethers.utils.parseEther("10"));            
        });

        it("TransferFrom should modify allowance", async() => {
            await erc20assembly.connect(deployer).approve(Alice.address, ethers.utils.parseEther("10"));
            await erc20assembly.connect(Alice).transferFrom(deployer.address, Bob.address, ethers.utils.parseEther("10"));

            expect(await erc20assembly.allowance(deployer.address, Alice.address)).to.equal(0);
        });
    });


});