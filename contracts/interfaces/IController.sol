// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IController {
    function owner() external view returns (address);
    function storageContract() external view returns (address);
    function dynamicStorage() external view returns (address);
}