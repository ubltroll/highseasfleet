// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

import "./safe/Safe.sol";
import "./safe/external/SafeMath.sol";
import "./libraries/TransferHelper.sol";
import "./openzeppelin/token/ERC20/ERC20.sol";


/**
 * @title Cruiser - A de-fund based on Gnosis Safe.
 * @dev Cruiser = Safe + ERC20 + {Module}.
 *  Share of fund is calculated by amount of ERC20 tokens.
 *  Investors can join and exit the fund in many ways.
 *  Concepts:
 *  - Join: Invest tokens to join the fund. This action will mint more shares.
 *  - Exit: Withdraw tokens and exit the fund. This action will burn shares accordingly.

 * @author Troll Meyer 
 */

contract Cruiser is Safe, ERC20 {
  using SafeMath for uint256;
  address public owner = msg.sender;
  uint public last_completed_migration;

  constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {
        /**
        * By setting the threshold it is not possible to call setup anymore,
        * so we create a Safe with 0 owners and threshold 1.
        * This is an unusable Safe, perfect for the singleton
        */
        threshold = 1;
    }

  event Join(address indexed account, uint256 amount, address investToken, uint256 investAmount);
  event Exit(address indexed account, uint256 amount);

  function joinAndMint(
        address payer,
        address receiver,
        uint256 mintAmount,
        address investToken,
        uint256 investAmount
    ) public payable authorized {
        if (investToken != address(0)){
            TransferHelper.safeTransferFrom(
                investToken, payer, address(this), investAmount);
            emit Join(receiver, mintAmount, investToken, investAmount);
        } else {
            emit Join(receiver, mintAmount, address(0), msg.value);
        }
        _mint(receiver, mintAmount);
  }

  function burnAndExit(
        address account,
        address receiver,
        uint256 burnAmount,
        address[] calldata exitTokens
    ) public authorized{
        //TODO: remove duplicates in exitTokens

        for (uint i; i < exitTokens.length; i++){
            if (exitTokens[i] != address(0)){
                TransferHelper.safeTransfer(
                    exitTokens[i], receiver,
                    IERC20(exitTokens[i]).balanceOf(address(this)).mul(burnAmount)/(totalSupply())
                    );
            } else {
                TransferHelper.safeTransferETH(
                    receiver, address(this).balance.mul(burnAmount)/(totalSupply())
                    );
            }
        }
        emit Exit(account, burnAmount);
        _burn(account, burnAmount);
  }
}
