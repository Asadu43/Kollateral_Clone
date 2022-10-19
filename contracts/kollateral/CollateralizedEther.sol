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
import "./ExternalCaller.sol";

 contract CollateralizedEther is CollateralizedToken, ExternalCaller {
    constructor()  CollateralizedToken(address(1)){
    }

     receive () external payable { }

    function mint() external payable returns (bool)
    {
        return mintInternal(msg.value);
    }

    function transferUnderlying(address to, uint256 amount)
    internal
    override
    virtual
    returns (bool)
    {
        require(address(this).balance >= amount, "KEther: not enough ether balance");
        externalTransfer(to, amount);
        return true;
    }

    function isUnderlyingEther() public override pure virtual returns (bool) {
        return true;
    }

    function totalReserve() public view override virtual returns (uint256)
    {
        return address(this).balance;
    }

}
