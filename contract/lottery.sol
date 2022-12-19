pragma solidity ^0.4.17;

contract Lottery {
    address public manager;
    address[] public players;

    function Lottery() public {
        manager = msg.sender;
    }

    // Entering the player to the lottey
    function enter() public payable {
        require(msg.value > .01 ether);
        players.push(msg.sender);
    }

    // Random Winner Generation algorithm
    function random() private view returns (uint) {
        return uint(keccak256(block.difficulty, now, players));
    }

    function pickWinner() public restricted {
        uint index = random() % players.length;
        players[index].transfer(this.balance);
        players = new address[](0);
    }

    // Restricting  modifier added as sender only calling
    modifier restricted() {
        require(msg.sender == manager);
        _;
    }
}