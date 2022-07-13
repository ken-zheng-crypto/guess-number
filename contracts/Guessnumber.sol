// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Import this file to use console.log
import "hardhat/console.sol";

contract Guessnumber {
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
    }

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

    constructor(bytes32 _nonceHash, bytes32 _nonceNumHash) public payable {
        require(msg.value > 0);
        host = msg.sender;
        bet = msg.value;
        nonceHash = _nonceHash;
        nonceNumHash = _nonceNumHash;
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
            guessPlayer.length >= 0 && guessPlayer.length < 2,
            "This game only supports up to 2 players"
        );
        for (uint256 i = 0; i < guessPlayer.length; i++) {
            if (guessPlayer[i].guessNumber == _number) {
                revert("The number has been guessed by another Player");
            }
            if (guessPlayer[i].player == msg.sender) {
                revert("You has already submitted a guessing");
            }
        }
        Guess memory newGuess = Guess(msg.sender, _number);
        guessPlayer.push(newGuess);
        if (guessPlayer.length == 2) {
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
            uint16 player1DiffNumber = getDiffNumber(
                _number,
                guessPlayer[0].guessNumber
            );
            uint16 player2DiffNumber = getDiffNumber(
                _number,
                guessPlayer[1].guessNumber
            );

            emit playerDiffNumber(guessPlayer[0].player, player1DiffNumber);
            emit playerDiffNumber(guessPlayer[1].player, player1DiffNumber);

            if (player1DiffNumber == player2DiffNumber) {
                reaward();
            } else {
                uint8 winnerIndex = 0;
                if (player1DiffNumber > player2DiffNumber) {
                    winnerIndex = 1;
                }
                payable(guessPlayer[winnerIndex].player).transfer(bet * 3);
            }
        } else {
            reaward();
        }

        emit revealEvent(_nonce, _number);
    }

    function reaward() internal {
        for (uint16 i = 0; i < guessPlayer.length; i++) {
            payable(guessPlayer[i].player).transfer((bet * 3) / 2);
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
