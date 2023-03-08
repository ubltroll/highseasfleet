// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

import "./Cruiser.sol";
import "./libraries/TransferHelper.sol";
import "./interface/GnosisSafe.sol";
import "./openzeppelin/governance/TimelockController.sol";
import "./safe/common/SecuredTokenTransfer.sol";


/**
 * @title Trustee Module - A module for trustee to join and exit the fund by interacting with the Cruiser (fund based on gnosis safe)
 * @dev White-listed trustees can propose for customers to join or exit the fund at certain price level.
 *      This is done by the following procedure:
 *      - White-listing trustees: Trustees are proposers in the AccessControl contract.
 *      - Proposing Offers: Trustees can propose an offer to join by investing a certain amount of tokens or exit by withdrawing  a certain amount of tokens.
 *      - Time locking: Proposes are time-locked for a while, let's say one day.
 *      - Accepting Offers: The offer is accepted by the gnosis safe, which is the executor in the AccessControl contract.
 *    

 * @author Troll Meyer 
 */
contract TrusteeModule is TimelockController, SelfAuthorized{
    string public constant NAME = "Trustee Module";
    string public constant VERSION = "0.1.0";

    GnosisSafe public SAFE;

    /*
    constructor of TimelockController:
        uint256 minDelay, address[] memory proposers, address[] memory executors, address admin
        minDelay -> 1 days
        proposers -> initialTrustee
        executors -> only by gnosis safe
    */
    constructor (
        address bindingSafe,
        address[] memory initialTrustee)
        TimelockController(1 days, initialTrustee, new address[](0), bindingSafe){

        SAFE = GnosisSafe(bindingSafe);

        _setupRole(EXECUTOR_ROLE, bindingSafe);
    }

    function joinViaTrustee(
        address payer,
        address receiver,
        uint256 mintAmount,
        address investToken,
        uint256 investAmount
    ) public authorized {
        //ETH investment not supported: investToken should not be address(0)
        SAFE.execTransactionFromModule(
            address(SAFE),
            0,
            abi.encodeWithSelector(
                Cruiser.joinAndMint.selector,
                payer, 
                receiver, 
                mintAmount, 
                investToken,
                investAmount
                ),
            Enum.Operation.Call
        );
    }

    function exitViaTrustee(
        address account,
        address receiver,
        uint256 burnAmount,
        address exitToken,
        uint256 exitAmount
    ) public authorized{
        //ETH withdraws not supported: investToken should not be address(0)
        SAFE.execTransactionFromModule(
            address(SAFE),
            0,
            abi.encodeWithSelector(
                Cruiser.burnAndExit.selector,
                account, 
                receiver, 
                burnAmount
                ),
            Enum.Operation.Call
        );
        //call to transfer token
        SAFE.execTransactionFromModule(
            exitToken,
            0,
            abi.encodeWithSelector(0xa9059cbb, receiver, exitAmount), //0xa9059cbb - keccack("transfer(address,uint256)")
            Enum.Operation.Call
        );
    }

    function assembleJoinViaTrustee(
        address payer,
        address receiver,
        uint256 mintAmount,
        address investToken,
        uint256 investAmount
    ) public pure returns(bytes memory data){
        require(investToken != address(0), "ETH not supported yet");

        data = abi.encodeWithSelector(
            0xf35a84fc,  //0xf35a84fc - keccack("joinViaTrustee(address,address,uint256,address,uint256)")
            payer,
            receiver,
            mintAmount,
            investToken,
            investAmount);
    }

    function assembleExitViaTrustee(
        address account,
        address receiver,
        uint256 burnAmount,
        address exitToken,
        uint256 exitAmount
    ) public pure returns(bytes memory data){
        require(exitToken != address(0), "ETH not supported yet");

        data = abi.encodeWithSelector(
            0x3adbbc5c, //0x3adbbc5c - keccack("exitViaTrustee(address,address,uint256,address,uint256)")
            account,
            receiver,
            burnAmount,
            exitToken,
            exitAmount);
    }
}
