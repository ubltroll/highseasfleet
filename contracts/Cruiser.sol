// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

import "./Safe.sol";
import "./external/SafeMath.sol";
import "./libraries/TransferHelper.sol"
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

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

  event Invest(address indexed account, uint256 amount, address investToken, uint256 investAmount);
  event Withdraw(address indexed account, uint256 amount);

  function investAndMint(
        address payer,
        address receiver,
        uint256 mintAmount,
        address investToken,
        uint256 investAmount) public payable authorized {
      if (investToken != address(0)){
          TransferHelper.safeTransferFrom(
              investToken, payer, address(this), investAmount);
          Invest(receiver, mintAmount, investToken, investAmount);
      } else {
          Invest(receiver, mintAmount, address(0), msg.value);
      }
      _mint(receiver, mintAmount);
  }

  function withdrawAndBurn(
        address account,
        address receiver,
        uint256 burnAmount,
        address[] withdrawTokens) public authorized{
     for (uint i; i < withdrawTokens.length; i++){
         if (withdrawTokens != address(0)){
             TransferHelper.safeTransfer(
                 withdrawTokens, receiver,
                 IERC20(withdrawTokens).balanceOf(address(this)).mul(burnAmount).div(totalSupply())
                 );
         } else {
             TransferHelper.safeTransferETH(
                 receiver, this.balance.mul(burnAmount).div(totalSupply())
                 );
         }
     }
     Withdraw(account, burnAmount);
     _burn(account, burnAmount);
  }
}
