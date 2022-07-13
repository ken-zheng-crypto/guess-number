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

## Explain the reason of having both nonceHash and nonceNumHash in the smart contract. Can any of these two be omitted and why?  
    不能去掉nonceHash，因为玩家可以暴力搜索数字 1 到 10 以找到正确的散列
## Try to find out any security loopholes in the above design and propose an improved solution.
        
### A loophole is a vulnerability that allows an attacker to ALWAY dishonestly win the game by having some specific actions, or any otheractions, that can break the game rules.