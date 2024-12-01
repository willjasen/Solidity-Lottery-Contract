// SPDX-License-Identifier: GPLv3
pragma solidity ^0.8.19;

contract Lottery {
    address public manager;

    struct Player {
        address playerAddress;
        uint8[4] chosenNumbers;
    }

    struct Round {
        uint256 roundNumber;
        uint256 nextDrawTime; // The next allowed time to pick numbers
        Player[] players;     // Players in the current round
        uint8[4] winningNumbers; // Winning numbers for this round
        bool isCompleted;     // Indicates if the round is completed
    }

    mapping(uint256 => Round) public rounds; // Maps round number to a Round struct
    uint256 public currentRoundNumber;       // Tracks the current round number
    uint256 public constant drawInterval = 3 days; // Interval between lotteries

    constructor() {
        manager = msg.sender;
        currentRoundNumber = 1;

        // Access the storage reference for the first round
        Round storage round = rounds[currentRoundNumber];
        round.roundNumber = currentRoundNumber;
        round.nextDrawTime = block.timestamp + drawInterval;
        round.isCompleted = false;

    }

    function reset() private {
        currentRoundNumber = ++currentRoundNumber;

        Round storage round = rounds[currentRoundNumber];
        round.roundNumber = currentRoundNumber;
        round.nextDrawTime = block.timestamp + drawInterval;
        round.isCompleted = false;
    }

    // Allow someone to enter into the lottery
    function enter(uint8[4] memory numbers) public payable {
        require(msg.value >= 0.001 ether, "Minimum 0.001 ether required to enter.");
        require(numbers.length == 4, "You must pick exactly 4 numbers.");

        Round storage currentRound = rounds[currentRoundNumber];

        // Ensure numbers are valid and unique
        bool[31] memory numberPicked;
        for (uint8 i = 0; i < 4; i++) {
            require(numbers[i] >= 1 && numbers[i] <= 30, "Numbers must be between 1 and 30.");
            require(!numberPicked[numbers[i]], "Duplicate numbers are not allowed.");
            numberPicked[numbers[i]] = true;
        }

        // If the timestamp allows and the winning numbers are not yet picked, draw the previous round
        if (block.timestamp >= currentRound.nextDrawTime && !currentRound.isCompleted) {
            draw();
        }

        // Add the player to the current round
        currentRound.players.push(Player({
            playerAddress: msg.sender,
            chosenNumbers: numbers
        }));
    }

    // Allow the manager to draw the lottery, pay it out, and set up a new lottery
    function draw() public restricted {
        Round storage currentRound = rounds[currentRoundNumber];

        require(block.timestamp >= currentRound.nextDrawTime, "Draw not allowed before deadline.");
        require(currentRound.players.length > 0, "No players entered.");
        require(!currentRound.isCompleted, "Winning numbers already drawn.");

        currentRound.winningNumbers = pickWinningNumbers();
        distributePrizes(currentRound);
        reset();
    }

    

    // Returns randomly generated winning numbers
    function pickWinningNumbers() private view returns (uint8[4] memory) {
        uint256 seed = uint256(
            keccak256(
                abi.encodePacked(
                    address(this).balance,
                    block.timestamp,
                    block.prevrandao,
                    block.number
                )
            )
        );

        uint8[4] memory winningNumbers;
        uint8 remaining = 30;

        for (uint8 i = 0; i < 4; i++) {
            uint256 randIndex = random(seed) % remaining;
            winningNumbers[i] = uint8(randIndex + 1); // Pick a random number
            seed++;
            remaining--;
        }

        return winningNumbers;
    }

    function distributePrizes(Round storage round) private {
        address winner;
        for (uint i = 0; i < round.players.length; i++) {
            if (compareNumbers(round.players[i].chosenNumbers, round.winningNumbers)) {
                winner = round.players[i].playerAddress;
                break;
            }
        }

        uint256 prizeAmount = address(this).balance;

        if (winner != address(0)) {
            // Ensure no reentrancy by updating state before the external call
            emit PrizeDistributed(winner, prizeAmount);

            (bool success, ) = payable(winner).call{value: prizeAmount}("");
            require(success, "Transfer to winner failed.");
        } else {
            emit PrizeDistributed(address(0), prizeAmount); // Log rollover
        }
    }

    function random(uint256 seed) private view returns (uint256) {
        return uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    block.prevrandao,
                    block.number,
                    block.gaslimit,
                    block.coinbase,
                    seed
                )
            )
        );
    }

    function compareNumbers(uint8[4] memory playerNums, uint8[4] memory winNums) private pure returns (bool) {
        uint8[4] memory sortedPlayerNums = sortNumbers(playerNums);
        uint8[4] memory sortedWinNums = sortNumbers(winNums);

        for (uint8 i = 0; i < 4; i++) {
            if (sortedPlayerNums[i] != sortedWinNums[i]) {
                return false;
            }
        }
        return true;
    }

    function sortNumbers(uint8[4] memory nums) private pure returns (uint8[4] memory) {
        uint8 temp;
        for (uint8 i = 0; i < 3; i++) {
            for (uint8 j = i + 1; j < 4; j++) {
                if (nums[i] > nums[j]) {
                    temp = nums[i];
                    nums[i] = nums[j];
                    nums[j] = temp;
                }
            }
        }
        return nums;
    }

    modifier restricted() {
        require(msg.sender == manager, "Only the manager can call this function.");
        _;
    }

    function getCurrentRoundPlayers() public view returns (Player[] memory) {
        return rounds[currentRoundNumber].players;
    }

    function getWinningNumbersByRound(uint256 roundNumber) public view returns (uint8[4] memory) {
        require(roundNumber <= currentRoundNumber, "Round number is invalid.");
        return rounds[roundNumber].winningNumbers;
    }

    event PrizeDistributed(address winner, uint256 amount);
}
