// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

import "./safe/Safe.sol";
import "./safe/external/SafeMath.sol";
import "./libraries/TransferHelper.sol";
import "./openzeppelin/token/ERC20/ERC20.sol";
import "./openzeppelin/token/ERC20/IERC20.sol";

contract Cruiser is Safe {
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
            Join(receiver, mintAmount, investToken, investAmount);
        } else {
            Join(receiver, mintAmount, address(0), msg.value);
        }
        _mint(receiver, mintAmount);
  }

  function exitAndBurn(
        address account,
        address receiver,
        uint256 burnAmount,
        address[] exitTokens
    ) public authorized{
        for (uint i; i < withdrawTokens.length; i++){
            if (exitTokens != address(0)){
                TransferHelper.safeTransfer(
                    exitTokens, receiver,
                    IERC20(exitTokens).balanceOf(address(this)).mul(burnAmount).div(totalSupply())
                    );
            } else {
                TransferHelper.safeTransferETH(
                    receiver, this.balance.mul(burnAmount).div(totalSupply())
                    );
            }
        }
        Exit(account, burnAmount);
        _burn(account, burnAmount);
  }
}
