// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/presets/ERC20PresetMinterPauser.sol";

contract NAFTA is ERC20PresetMinterPauser {
    // Cap at 1 million
    uint256 internal _cap = 10000000 * 10**18;

    constructor() public ERC20PresetMinterPauser("NAFTA Token", "NAFTA") {}

    /**
     * @dev Returns the cap on the token's total supply.
     */
    function cap() public view returns (uint256) {
        return _cap;
    }

    // change cap in case of decided by the community
    function changeCap(uint256 _newCap) external {
        require(
            hasRole(MINTER_ROLE, _msgSender()),
            "ERC20PresetMinterPauser: must have minter role to change cap"
        );
        _cap = _newCap;
    }

    /**
     * Should not exceed cap when minting
     *
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC20PresetMinterPauser) {
        super._beforeTokenTransfer(from, to, amount);

        if (from == address(0)) {
            // When minting tokens
            require(
                totalSupply().add(amount) <= _cap,
                "NAFTACapped: cap exceeded"
            );
        }
    }
}