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

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./KToken.sol";
import "./CollateralizedEther.sol";

contract KEther is KToken, CollateralizedEther {
    constructor ()
    CollateralizedEther()
    { }

    function payableReserveAdjustment() internal override returns (uint256) {
        return msg.value;
    }

    function isUnderlyingEther() public pure override(CollateralizedEther,CollateralizedToken) returns (bool) {
        return CollateralizedEther.isUnderlyingEther();
    }

     function totalReserve() public view  override(CollateralizedEther,CollateralizedToken) returns (uint256)
    {
        return CollateralizedEther.totalReserve();
    }

    function transferUnderlying(address to, uint256 amount)
    internal
    override(CollateralizedEther,CollateralizedToken)
    returns (bool)
    {
      return CollateralizedEther.transferUnderlying(to,amount);
}

}
