// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";

import "./LiquidityPool.sol";

contract Token is Context, ERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    string public _name = "SafePenny.Finance";
    string public _symbol = "SPENNY";

    uint256 private _iCurrentSupply;

    // data
    mapping(address => uint256) private _rOwned;

    // tax
    uint256 public _iTaxFeeInPercent = 5;
    uint256 private _iPreviousTaxFee = 0;

    // treasury
    address public _treasuryWallet;

    // LPRouter
    LiquidityPool public _liquidityPool;

    constructor(uint256 initialSupply, address wallet) ERC20(_name, _symbol) {
        _treasuryWallet = wallet;
        _mint(_treasuryWallet, initialSupply);

        _liquidityPool = new LiquidityPool(this);
    }

    /**
     * @param receipent transfer token to this address
     * @param amount total token to be transfer
     */
    function transfer(address receipent, uint256 amount)
        public
        override
        returns (bool)
    {
        _chargeableTransfer(receipent, address(this), amount);
        return true;
    }

    /**
     * @param from token coming from
     * @param to transfer token to this address
     * @param amount total token to be transfer
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        require(amount > 0, "Transfer amount must be greater than zero");
    }

    function _chargeableTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        uint256 transferableAmount = calculateTaxFee(amount);
        emit Transfer(to, from, transferableAmount);
    }

    /**
     * Static calculation to retrieve fees
     * @param amount taxable amount
     */
    function calculateTaxFee(uint256 amount) private view returns (uint256) {
        return amount.mul(_iTaxFeeInPercent).div(100);
    }
}
