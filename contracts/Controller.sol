// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IUpgradeableContract.sol";

/// @title CREATE2 Controller
/// @author Chainvisions
/// @notice Main contract to handle CREATE2 creation & storing important modules.

contract Controller is Ownable {

    /// @notice Contract for handling storage of the contract.
    address public storageContract;

    /// @notice Address of the logic contract, should not change
    address public logicContract;

    /// @notice Salt recorded for further deployments to allow for upgrades.
    uint256 public deploymentSalt;

    /// @notice Emitted on creation of the contract.
    event Creation(address addr, uint256 salt);

    /// @notice Emitted on upgrade to the logic contract.
    event Upgrade(bytes newBytecode);

    /// @notice Deploys the logic contract.
    /// @param _bytecode Bytecode of the logic contract.
    /// @param _salt Salt used to determine the address of the logic contract.
    /// @return The address of the logic contract from deployment.
    function deploy(
        bytes memory _bytecode, 
        uint256 _salt
    ) public onlyOwner returns (address) {
        require(logicContract == address(0), "Controller: Logic already created");

        // Use CREATE2 to deploy the logic.
        address addr;
        assembly {
            addr := create2(0, add(_bytecode, 0x20), mload(_bytecode), _salt)
            if iszero(extcodesize(addr)) {
                revert(0, 0)
            }
        }

        // Store logic and salt for later use.
        logicContract = addr;
        deploymentSalt = _salt;

        emit Creation(addr, _salt);
        return addr;
    }

    /// @notice Performs an upgrade to the logic contract.
    /// @param _bytecode New bytecode for the logic contract.
    function upgrade( bytes memory _bytecode) public onlyOwner {
        require(logicContract != address(0), "Controller: There is no logic contract to upgrade");

        // Prepare logic for upgrade.
        IUpgradeableContract(logicContract).prepareUpgrade(); // Should `selfdestruct()` itself.

        // Redeploy the logic contract.
        uint256 salt = deploymentSalt; // Load to memory to use in CREATE2.
        address addr;
        assembly {
            addr := create2(0, add(_bytecode, 0x20), mload(_bytecode), salt)
            if iszero(extcodesize(addr)) {
                revert(0, 0)
            }
        }

        emit Upgrade(_bytecode);
    }
}