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

import "./KToken.sol";
import "./CollateralizedErc20.sol";

contract KErc20 is KToken, CollateralizedErc20 {
    constructor()
    CollateralizedErc20()
    { }

    function isUnderlyingEther() public view override(CollateralizedErc20,CollateralizedToken) returns (bool) {
        return CollateralizedErc20.isUnderlyingEther();
    }

     function totalReserve() public view  override(CollateralizedErc20,CollateralizedToken) returns (uint256)
    {
        return CollateralizedErc20.totalReserve();
    }

    function transferUnderlying(address to, uint256 amount)
    internal
    override(CollateralizedErc20,CollateralizedToken)
    returns (bool)
    {
        return CollateralizedErc20.transferUnderlying(to,amount);
    }

}
