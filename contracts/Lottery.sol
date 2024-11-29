// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Lottery {
    address public manager;

    struct Player {
        address playerAddress;
        uint8[4] chosenNumbers; // Player's chosen numbers (4 numbers between 1 and 30)
    }

    Player[] public players;

    // Default Constructor
    constructor() {
        manager = msg.sender;
    }

    // Entering the player to the lottery with 4 chosen numbers
    function enter(uint8[4] memory numbers) public payable {
        require(msg.value > .01 ether, "Minimum 0.01 ether required to enter.");
        require(numbers.length == 4, "You must pick exactly 4 numbers.");
        
        // Ensure all numbers are between 1 and 30
        for (uint8 i = 0; i < 4; i++) {
            require(numbers[i] >= 1 && numbers[i] <= 30, "Numbers must be between 1 and 30.");
        }

        // Add the player to the list
        players.push(Player({
            playerAddress: msg.sender,
            chosenNumbers: numbers
        }));
    }

    // Random Winner Generation algorithm
    function random() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.prevrandao, block.timestamp, msg.sender)));
    }

    // Picking the winner
    function pickWinner() public restricted {
        require(players.length > 0, "No players have entered the lottery.");
        
        uint index = random() % players.length;
        address winner = players[index].playerAddress;

        // Transfer the balance to the winner
        payable(winner).transfer(address(this).balance);

        // Reset the players array
        delete players;
    }

    // Restricting modifier added as sender only calling
    modifier restricted() {
        require(msg.sender == manager, "Only the manager can call this function.");
        _;
    }

    // Return all players' addresses
    function getPlayers() public view returns (address[] memory) {
        address[] memory playerAddresses = new address[](players.length);
        for (uint i = 0; i < players.length; i++) {
            playerAddresses[i] = players[i].playerAddress;
        }
        return playerAddresses;
    }

    // Get a specific player's chosen numbers
    function getPlayerNumbers(uint index) public view returns (uint8[4] memory) {
        require(index < players.length, "Invalid player index.");
        return players[index].chosenNumbers;
    }
}
