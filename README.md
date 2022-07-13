# Test

cd guess-number

npm instal

npx hardhat test


<img width="1183" alt="截屏2022-07-13 15 22 28" src="https://user-images.githubusercontent.com/104058212/178675370-ab1e8707-41ba-4e24-a906-974a68103aad.png">


# Additional Tasks

## Customized Player Numbers: Allow the Host to specify the number of Players upon deployment.

pls view code : /contracts/MultPlayerGuessnumber.sol  

pls view test code : /test/MultPlayerGuessnumber.js  

 ideas ：  
    1、定义一个Guess[],Guess是一个struct，包括 player address 、guessNumber、 diffNumber;  
    2、host reveal 时，计算数组里面的每个player的diffNumber，然后对Guess[]按diffNumber进行排序;  
    3、取出Guess[]的前2个player进行diffNumber大小比较，根据情况reward  

MultPlayerGuessnumber test : 
<img width="839" alt="截屏2022-07-13 17 32 15" src="https://user-images.githubusercontent.com/104058212/178701400-7c0be980-9109-44d1-af76-29a626ab0f2f.png">




## Explain the reason of having both nonceHash and nonceNumHash in the smart contract. Can any of these two be omitted and why?
不能去掉nonceHash，因为玩家可以暴力搜索数字 1 到 1000 以找到正确的numberhash
## Try to find out any security loopholes in the above design and propose an improved solution.
        
### A loophole is a vulnerability that allows an attacker to ALWAY dishonestly win the game by having some specific actions, or any otheractions, that can break the game rules.
设计存在的漏洞如下：  

1、在host进行reveal的时候，需要对多个player进行transfer，如果player address 是一个Contract address, 可能会出现失败抛出异常，则所有的player都无法得到奖励；建议提供withdraw()方法，让每个player去领取自己的奖励（参考https://www.bookstack.cn/read/ethereum_book-zh/spilt.8.272b82cb56a522db.md）

<img width="1722" alt="截屏2022-07-13 17 47 04" src="https://user-images.githubusercontent.com/104058212/178704835-50796b8e-74cc-4e67-bfd5-f18874588123.png">

2、目前的随机数字都是host事先生成好的，会存在作弊的风险，可以在竞猜结束后，reveal开奖的时候，随机生成。  

3、host进行reveal开奖的时候，如果player是多人的话，会存在gas费成本的问题，如果要player自己去withdraw，则这部分gas费是由player承担了。
