const { expect } = require("chai");
const { ethers } = require("hardhat");

const utils = ethers.utils;

describe("Guessnumber", function () {


    async function deployContract(nonce, number) {
        const [host, player1, player2] = await ethers.getSigners();
        console.log("host Balance :", utils.formatEther(await host.getBalance()));
        console.log("player1 address :", player1.address);
        console.log("player2 address :", player2.address);

        const nonceHash = utils.keccak256(utils.defaultAbiCoder.encode(["bytes32"], [utils.formatBytes32String(nonce)]));
        const nonceNumberHash = utils.keccak256(utils.defaultAbiCoder.encode(["bytes32", "uint"], [utils.formatBytes32String(nonce), number]));
        const betAmount = utils.parseEther("1");
        const Guessnumber = await ethers.getContractFactory("Guessnumber");
        const guessnumber = await Guessnumber.deploy(nonceHash, nonceNumberHash, { value: betAmount });
        await guessnumber.deployed();
        const contractAddress = guessnumber.address;
        console.log("contract address :", contractAddress);
        const contractBalance = await ethers.provider.getBalance(contractAddress);
        console.log("deploy contract after , contract balance :%s , host Balance :%s", utils.formatEther(contractBalance), utils.formatEther(await host.getBalance()));
        return { guessnumber, contractAddress, host, player1, player2,betAmount};
    }

   

    //case 1
    it("Case1 : Player 2 wins the game and receives 3 Ether as rewards.", async function () {
        const nonce = "HELLO";
        const number = 999;
        const { guessnumber, contractAddress, host, player1, player2,betAmount } = await deployContract(nonce, number);

        // player1 guess number
        const guessNumber1 = 800;
        await guessnumber.connect(player1).guess(guessNumber1, { value: betAmount });


        // player2 guess number
        const guessNumber2 = 900;
        await guessnumber.connect(player2).guess(guessNumber2, { value: betAmount });

        //host reveal
        await expect( guessnumber.reveal(utils.formatBytes32String(nonce), number))
        .to.changeEtherBalances([guessnumber,player2], [utils.parseEther("-3"), utils.parseEther("3")]);

    });


    //case 2
    it("Case2 : Player 1 input is reverted since he does not attach 1 Ether as the deposit value.", async function () {
        const nonce = "HELLO";
        const number = 999;
        const { guessnumber, contractAddress, host, player1, player2,betAmount } = await deployContract(nonce, number);

        // player1 guess number with not equal the deposit value
        const guessNumber1 = 800;
        await expect(guessnumber.connect(player1).guess(guessNumber1, { value: 2 }))
        .to.be.revertedWith('You has not attached the same Ether value as the Host deposited');


    });



    //case 3 
    it("Case3 : Player 1 and 2 both receive 1.5 Ether as rewards since their guessings have the same delta.", async function () {
        const nonce = "HELLO";
        const number = 500;
        const { guessnumber, contractAddress, host, player1, player2,betAmount } = await deployContract(nonce, number);

        // player1 guess number
        const guessNumber1 = 450;
        guessnumber.connect(player1).guess(guessNumber1, { value: betAmount });

        // player2 guess number
        const guessNumber2 = 550;
        await guessnumber.connect(player2).guess(guessNumber2, { value: betAmount });
        
        console.log("luncky number: %s, player1 guess: %s , player2 guess : %s", number,guessNumber1,guessNumber2);
        
        //host reveal
        await expect( guessnumber.reveal(utils.formatBytes32String(nonce), number))
        .to.changeEtherBalances([guessnumber,player1,player2], [utils.parseEther("-3"), utils.parseEther("1.5"),utils.parseEther("1.5")]);

    });


     //case 4
     it("Case4 : Player 1 and 2 both receive 1.5 Ether as rewards since the host does not follow the rule (0<=n<1000)", async function () {
        const nonce = "HELLO";
        const number = 1415;
        const { guessnumber, contractAddress, host, player1, player2,betAmount } = await deployContract(nonce, number);

        // player1 guess number
        const guessNumber1 = 700;
        guessnumber.connect(player1).guess(guessNumber1, { value: betAmount });


        // player2 guess number
        const guessNumber2 = 350;
        await guessnumber.connect(player2).guess(guessNumber2, { value: betAmount });
        
        console.log("luncky number: %s, player1 guess: %s , player2 guess : %s", number,guessNumber1,guessNumber2);
        
        //host reveal
        await expect( guessnumber.reveal(utils.formatBytes32String(nonce), number))
        .to.changeEtherBalances([guessnumber,player1,player2], [utils.parseEther("-3"), utils.parseEther("1.5"),utils.parseEther("1.5")]);

    });



    it("Random Guess number", async function () {
        const nonce = randomString(6);
        const number = Math.floor(Math.random() * 1000);
        const { guessnumber, contractAddress, host, player1, player2,betAmount } = await deployContract(nonce, number);

        // player1 guess number
        const guessNumber1 = Math.floor(Math.random() * 1000);
        await guessnumber.connect(player1).guess(guessNumber1, { value: betAmount });
        console.log("after player1 guess number : %s ,  contract balance : %s , player1 balance : %s", guessNumber1, utils.formatEther(await ethers.provider.getBalance(contractAddress)), utils.formatEther(await player1.getBalance()));


        // player2 guess number
        const guessNumber2 = Math.floor(Math.random() * 1000);
        await guessnumber.connect(player2).guess(guessNumber2, { value: betAmount });
        console.log("after player2 guess number : %s ,  contract balance : %s , player1 balance : %s", guessNumber2, utils.formatEther(await ethers.provider.getBalance(contractAddress)), utils.formatEther(await player2.getBalance()));


        //host reveal
        await guessnumber.reveal(utils.formatBytes32String(nonce), number);
        console.log("host reveal after contract address : %s , player1 balance :%s , player2 balance : %s", utils.formatEther(await ethers.provider.getBalance(contractAddress)), utils.formatEther(await player1.getBalance()), utils.formatEther(await player2.getBalance()));


    });

    function randomString(e) {
        e = e || 32;
        let t = "ABCDEFGHJKMNPQRSTWXYZabcdefhijkmnprstwxyz";
        let str = "";
        for (i = 0; i < e; i++) {
            str += t.charAt(Math.floor(Math.random() * t.length))
        };
        return str;
    }




    


});