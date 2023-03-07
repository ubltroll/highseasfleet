// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

import "./safe/common/Enum.sol";
import "./safe/common/SelfAuthorized.sol";
import "./libraries/TransferHelper.sol";
import "./interface/GnosisSafe.sol";
import "./openzeppelin/governance/TimelockController.sol";

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
        address[] initialTrustee)
        TimelockController(1 days, initialTrustee, [bindingSafe], bindingSafe){
        SAFE = bindingSafe;
    }

    function _joinViaTrustee(address payer,
        address receiver,
        uint256 mintAmount,
        address investToken,
        uint256 investAmount
    ) public payable authorized {

    }

    function joinViaTrustee(address payer,
        address receiver,
        uint256 mintAmount,
        address investToken,
        uint256 investAmount
    ) public payable {

    }

    function joinViaTrusteeBatch();

    function _exitViaTrustee();

    function exitViaTrustee();

    function exitViaTrusteeBatch();

}
