// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IKiln {
    function vrfCallback(bytes32 randomNumber) external;
}
