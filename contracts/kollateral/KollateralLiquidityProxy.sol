/*

    Copyright 2020 Kollateral LLC.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

*/

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./ILiquidityProxy.sol";
import "./CollateralizedToken.sol";
import "./KToken.sol";
import "./BalanceCarrier.sol";
import "./IInvoker.sol";


contract KollateralLiquidityProxy is Ownable, BalanceCarrier {
    mapping(address => address) _tokenAddressToKTokenAddress;

    address payable internal _scheduleInvokerAddress;
    address internal _scheduleTokenAddress;
    uint256 internal _scheduleTokenAmount;

    constructor () BalanceCarrier(address(1)) public { }

     receive() external payable { }

    function registerPool(address tokenAddress, address kTokenAddress) external onlyOwner {
        _tokenAddressToKTokenAddress[tokenAddress] = kTokenAddress;
    }

    function deregisterPool(address tokenAddress) external onlyOwner {
        _tokenAddressToKTokenAddress[tokenAddress] = address(0);
    }

    function getRepaymentAddress(address tokenAddress) external view returns (address) {
        return poolAddress(tokenAddress);
    }

    function getTotalReserve(address tokenAddress) external view returns (uint256) {
        if (isRegistered(tokenAddress) && !isPaused(tokenAddress)) {
            CollateralizedToken pool = CollateralizedToken(poolAddress(tokenAddress));
            return pool.totalReserve();
        }
        return 0;
    }

    function getRepaymentAmount(address tokenAddress, uint256 tokenAmount) external view returns (uint256) {
        KToken pool = KToken(poolAddress(tokenAddress));
        return pool.calculateRepaymentAmount(tokenAmount);
    }

    function borrow(address tokenAddress, uint256 tokenAmount) external {
        _scheduleInvokerAddress =payable( msg.sender);
        _scheduleTokenAddress = tokenAddress;
        _scheduleTokenAmount = tokenAmount;

        KToken pool = KToken(poolAddress(tokenAddress));
        pool.invoke(address(this), "", tokenAmount);

        _scheduleInvokerAddress = payable(address(0));
        _scheduleTokenAddress = address(0);
        _scheduleTokenAmount = 0;
    }

    function execute(bytes calldata data) external payable {
        require(_scheduleInvokerAddress != address(0), "KollateralLiquidityProxy: not scheduled");

        require(
            transfer(_scheduleTokenAddress, _scheduleInvokerAddress, _scheduleTokenAmount),
            "KollateralLiquidityProxy: transfer to invoker failed");

        IInvoker invoker = IInvoker(_scheduleInvokerAddress);
        invoker.invokeCallback();
    }

    function poolAddress(address tokenAddress) internal view returns (address) {
        return _tokenAddressToKTokenAddress[tokenAddress];
    }

    function isRegistered(address tokenAddress) internal view returns (bool) {
        return poolAddress(tokenAddress) != address(0);
    }

    function isPaused(address tokenAddress) internal view returns (bool) {
        return Pausable(poolAddress(tokenAddress)).paused();
    }
}
