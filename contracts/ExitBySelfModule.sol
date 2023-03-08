// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

import "./safe/common/Enum.sol";
import "./interface/GnosisSafe.sol";
import "./Cruiser.sol";


/**
 * @title Exit By Self Module - A module for customer to exit the fund by himself
 * @dev Customer can interact with exitAndBurn function in the Cruiser.
 * Note: In the near future, this module will be updated in the following ways:
 *  - Withdraw as single token: integrated with AMM to auto-switch exit tokens to one token.
 *  - Smart fees: Exit procedure may face flexible fees to avoid malicious exit requests.

 * @author Troll Meyer 
 */
contract ExitBySelfModule {
    string public constant NAME = "Exit By Self Module";
    string public constant VERSION = "0.1.0";

    GnosisSafe public SAFE;

    constructor (address bindingSafe){
        SAFE = GnosisSafe(bindingSafe);
    }

    function burnAndExit(
        address receiver,
        uint256 burnAmount,
        address[] calldata exitTokens
    ) external returns(bool success){
        //execTransactionFromModule(address to, uint256 value, bytes calldata data, Enum.Operation operation)
        success = SAFE.execTransactionFromModule(
            address(SAFE),
            0,
            abi.encodeWithSelector(Cruiser.burnAndExit.selector, msg.sender, receiver, burnAmount, exitTokens),
            Enum.Operation.Call
        );
        require(success, "transaction failed");
  }

}
