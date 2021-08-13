// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IUpgradeableContract {
    /// @notice Prepares for an upgrade to the contract. (Performs `selfdestruct()`)
    function prepareUpgrade() external;
}