// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Import this file to use console.log
import "hardhat/console.sol";

contract MultPlayerGuessnumber {
    event guessEvent(address indexed player, uint16 number);

    event revealEvent(bytes32 indexed _nonce, uint16 _number);

    event playerDiffNumber(address indexed player, uint16 diffNumber);

    bytes32 nonceHash;

    bytes32 nonceNumHash;

    address public host;

    uint256 public bet;

    State public state;

    enum State {
        WAITING_GUESS,
        WAITING_REVEAL,
        GAME_OVER
    }

    struct Guess {
        address player;
        uint16 guessNumber;
        uint16 diffNumber;
    }

    uint256 totalPeople;

    Guess[] public guessPlayer;

    modifier onlyOwner() {
        require(msg.sender == host);
        _;
    }

    modifier sameBet() {
        require(
            msg.value == bet,
            "You has not attached the same Ether value as the Host deposited"
        );
        _;
    }

    constructor(
        uint256 _totalPeople,
        bytes32 _nonceHash,
        bytes32 _nonceNumHash
    ) public payable {
        require(msg.value > 0);
        host = msg.sender;
        bet = msg.value;
        nonceHash = _nonceHash;
        nonceNumHash = _nonceNumHash;
        totalPeople = _totalPeople;
        state = State.WAITING_GUESS;
    }

    function guess(uint16 _number) public payable sameBet {
        require(state != State.GAME_OVER, "The game has already concluded");
        require(
            state == State.WAITING_GUESS,
            "The game state must is waiting guess"
        );
        require(
            _number >= 0 && _number < 1000,
            "The Player inputs an invalid number"
        );
        require(
            guessPlayer.length >= 0 && guessPlayer.length < totalPeople,
            "This game only supports up to totalPeople players"
        );
        for (uint256 i = 0; i < guessPlayer.length; i++) {
            if (guessPlayer[i].guessNumber == _number) {
                revert("The number has been guessed by another Player");
            }
            if (guessPlayer[i].player == msg.sender) {
                revert("You has already submitted a guessing");
            }
        }
        Guess memory newGuess = Guess(msg.sender, _number, 0);
        guessPlayer.push(newGuess);
        if (guessPlayer.length == totalPeople) {
            state = State.WAITING_REVEAL;
        }

        emit guessEvent(msg.sender, _number);
    }

    function reveal(bytes32 _nonce, uint16 _number) public onlyOwner {
        require(
            state == State.WAITING_REVEAL,
            "The current game state does not support reveal"
        );
        require(keccak256(abi.encode(_nonce)) == nonceHash, "invalid nonce");
        require(
            keccak256(abi.encode(_nonce, _number)) == nonceNumHash,
            "invalid number"
        );

        if (_number >= 0 && _number < 1000) {

            setGuessPlayerDiffNumber(_number);
            sortByDiffNumber();

            emit playerDiffNumber(guessPlayer[0].player, guessPlayer[0].diffNumber);
            emit playerDiffNumber(guessPlayer[1].player, guessPlayer[1].diffNumber);

            if (guessPlayer[0].diffNumber == guessPlayer[1].diffNumber) {
                reward(2);
            } else {
                reward(1);
            }
        } else {
            reward(totalPeople);
        }

        emit revealEvent(_nonce, _number);
    }



    function setGuessPlayerDiffNumber(uint16 _number) internal  {
        for (uint256 i = 0; i < guessPlayer.length; i++) {
            guessPlayer[i].diffNumber = getDiffNumber(
                _number,
                guessPlayer[i].guessNumber
            );
        }
    }

    function sortByDiffNumber() internal {
        for (uint256 i = 1; i < guessPlayer.length; i++)
            for (uint256 j = 0; j < i; j++)
                if (guessPlayer[i].diffNumber < guessPlayer[j].diffNumber) {
                    Guess memory  x = guessPlayer[i];
                    guessPlayer[i] = guessPlayer[j];
                    guessPlayer[j] = x;
                }
    }



    function reward(uint winnePeopleNumber) internal {
        for (uint16 i = 0; i < winnePeopleNumber; i++) {
            payable(guessPlayer[i].player).transfer((bet * (totalPeople+1)) / winnePeopleNumber);
        }
    }

    function getDiffNumber(uint16 _number, uint16 guessNumber)
        internal
        pure
        returns (uint16)
    {
        return
            guessNumber >= _number
                ? guessNumber - _number
                : _number - guessNumber;
    }
}
