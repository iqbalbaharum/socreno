// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./Token.sol";

contract LiquidityPool is Ownable {
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    address public _routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool public swapAndLiquifyEnabled = true;

    // event
    event SwapAndLiquifyEnabledUpdated(bool enabled);

    // ERC20 token contract
    ERC20 private eRC20Token;

    constructor(ERC20 _token) {
        IUniswapV2Router02 _uniswapV2Router =
            IUniswapV2Router02(_routerAddress);
        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;

        eRC20Token = _token;
    }

    //to recieve ETH from uniswapV2Router when swapping
    receive() external payable {}

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function swapTokensForEth(uint256 tokenAmount) public {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        eRC20Token.approve(address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) public {
        eRC20Token.approve(address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(0),
            block.timestamp
        );
    }
}
