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

import "./CollateralizedToken.sol";

contract CollateralizedErc20 is CollateralizedToken {

    constructor()
    CollateralizedToken(address(1))
    {
        
    }


    function mint(uint256 tokenAmount) external returns (bool)
    {
        IERC20 token = IERC20(underlying());
        require(
            token.transferFrom(msg.sender, address(this), tokenAmount),
                "CollateralizedErc20: token transferFrom failed");
        return mintInternal(tokenAmount);
    }

    function transferUnderlying(address to, uint256 amount)
    internal
    override
    virtual
    returns (bool)
    {
        return IERC20(underlying()).transfer(to, amount);
    }

    function isUnderlyingEther() public view override virtual returns (bool) {
        return false;
    }

    function totalReserve() public view  override virtual returns (uint256)
    {
        return IERC20(underlying()).balanceOf(address(this));
    }
}
