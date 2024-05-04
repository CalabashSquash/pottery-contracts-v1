# Pottery Keeper Bot

This is a bot that is used to upkeep the Kiln at the end of the period to generate a random number and draw the winner of the lottery


## Chainlink VRF Keeper
requires only one transaction, requests a random number from the Chainlink VRF and then uses that number to draw the winner of the lottery

## BlockHash Random Keeper
requires two transactions, the first transaction requests the blockhash of the block that the keeper is in, and the second transaction uses that blockhash to draw the winner of the lottery
