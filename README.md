# Test

cd guess-number

npm instal

npx hardhat test


<img width="1183" alt="截屏2022-07-13 15 22 28" src="https://user-images.githubusercontent.com/104058212/178675370-ab1e8707-41ba-4e24-a906-974a68103aad.png">


# Additional Tasks

## Customized Player Numbers: Allow the Host to specify the number of Players upon deployment.

 pls view code : /contracts/MultPlayerGuessnumber.sol

 ideas ：  
    1、定义一个Guess[],Guess是一个struct，包括 player address 、guessNumber、 diffNumber;  
    2、host reveal 时，计算数组里面的每个player的diffNumber，然后对Guess[]按diffNumber进行排序;  
    3、取出Guess[]的前2个player进行diffNumber大小比较，根据情况reward  


  MultPlayerGuessnumber
host Balance : 9994.989810238774077769
player1 address : 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
player2 address : 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC
contract address : 0x8A791620dd6260079BF849Dc5567aDC3F2FdC318
deploy contract after , contract balance :1.0 , host Balance :9993.988040558072556729
    ✔ Case1 : Player 2 wins the game and receives 5 Ether as rewards. (198ms)
host Balance : 9993.987945656327320193
player1 address : 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
player2 address : 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC
contract address : 0xB7f8BC63BbcaD18155201308C8f3540b07f84F5e
deploy contract after , contract balance :1.0 , host Balance :9992.986251284099859913
    ✔ Case1 : Player 1 and 2 both receive 2.5 Ether as rewards since their guessings have the same delta. (172ms)


## Explain the reason of having both nonceHash and nonceNumHash in the smart contract. Can any of these two be omitted and why?
不能去掉nonceHash，因为玩家可以暴力搜索数字 1 到 10 以找到正确的散列
## Try to find out any security loopholes in the above design and propose an improved solution.
        
### A loophole is a vulnerability that allows an attacker to ALWAY dishonestly win the game by having some specific actions, or any otheractions, that can break the game rules.