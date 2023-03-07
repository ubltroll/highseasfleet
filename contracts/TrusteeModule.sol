// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

import "./common/Enum.sol";
import "@openzeppelin/contracts/governance/TimelockController.sol";

interface GnosisSafe {
    /// @dev Allows a Module to execute a Safe transaction without any further confirmations.
    /// @param to Destination address of module transaction.
    /// @param value Ether value of module transaction.
    /// @param data Data payload of module transaction.
    /// @param operation Operation type of module transaction.
    function execTransactionFromModule(address to, uint256 value, bytes calldata data, Enum.Operation operation)
        external
        returns (bool success);
}


contract TrusteeModule is TimelockController{
    string public constant NAME = "Trustee Module";
    string public constant VERSION = "0.1.0";

    GnosisSafe public SAFE;

    bytes32 public constant TRANSFER_TOKEN_TYPEHASH = 0x80b006280932094e7cc965863eb5118dc07e5d272c6670c4a7c87299e04fceeb;
    // keccak256(
    //     "transferToken(address token, address receiver, uint256 amount)"
    // );

    bytes32 public constant INVEST_AND_MINT_TYPEHASH = 0x80b006280932094e7cc965863eb5118dc07e5d272c6670c4a7c87299e04fceeb;
    // keccak256(
    //     "transferToken(address token, address receiver, uint256 amount)"
    // );

    bytes32 public constant WITHDRAW_AND_BURN_TYPEHASH = 0x80b006280932094e7cc965863eb5118dc07e5d272c6670c4a7c87299e04fceeb;
    // keccak256(
    //     "transferToken(address token, address receiver, uint256 amount)"
    // );


    /*
    constructor of TimelockController:
    uint256 minDelay, address[] memory proposers, address[] memory executors, address admin
    */
    constructor (
        address bindingSafe,
        address[] initialTrustee)
        TimelockController(1 days, initialTrustee, [bindingSafe], bindingSafe){
        SAFE = bindingSafe;
    }

    function investViaTrustee();

    function withdrawViaTrustee();

}
