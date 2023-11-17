// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

/// @custom:security-contact tyron@ssiprotocol.com
contract Syron is ERC20, ERC20Burnable, AccessControl, ERC20Permit {
	bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

	constructor(
		address defaultAdmin,
		address minter
	) ERC20("Syron", "SYRON") ERC20Permit("Syron") {
		_grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
		_grantRole(MINTER_ROLE, minter);
	}

	function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
		_mint(to, amount);
	}
}
