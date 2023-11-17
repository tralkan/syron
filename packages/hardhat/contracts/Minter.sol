// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.21;

import { Context } from "@openzeppelin/contracts/utils/Context.sol";
import { IERC20Errors } from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";

interface Syron {
	function mint(address, uint256) external;
}

/// @custom:security-contact tyron@ssiprotocol.com
contract Minter is Context, IERC20Errors {
	Syron private immutable _address;

	uint256 private _totalSupply;
	mapping(address account => uint256) private _balances;

	uint256 private _vaultSupply;
	mapping(address account => uint256) private _vaults;

	/**
	 * @dev Emitted when `value` tokens are moved from one account (`from`) to
	 * another (`to`).
	 *
	 * Note that `value` may be zero.
	 */
	event Transfer(address indexed from, address indexed to, uint256 value);

	constructor(address address_) {
		_address = Syron(address_);
	}

	function stablecoinAddress() public view virtual returns (Syron) {
		return _address;
	}

	/**
	 * @dev See {IERC20-totalSupply}.
	 */
	function totalSupply() public view virtual returns (uint256) {
		return _totalSupply;
	}

	/**
	 * @dev See {IERC20-balanceOf}.
	 */
	function balanceOf(address account) public view virtual returns (uint256) {
		return _balances[account];
	}

	function vaultSupply() public view virtual returns (uint256) {
		return _vaultSupply;
	}

	function vaultOf(address account) public view virtual returns (uint256) {
		return _vaults[account];
	}

	function _update(address from, address to, uint256 value) internal virtual {
		if (from == address(0)) {
			// Overflow check required: The rest of the code assumes that totalSupply never overflows
			_totalSupply += value;
		} else {
			uint256 fromBalance = _balances[from];
			if (fromBalance < value) {
				revert ERC20InsufficientBalance(from, fromBalance, value);
			}
			unchecked {
				// Overflow not possible: value <= fromBalance <= totalSupply.
				_balances[from] = fromBalance - value;
			}
		}

		if (to == address(0)) {
			unchecked {
				// Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
				_totalSupply -= value;
			}
		} else {
			unchecked {
				// Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
				_balances[to] += value;
			}
		}

		emit Transfer(from, to, value);
	}

	function _updateVault(
		address from,
		address to,
		uint256 value
	) internal virtual {
		if (from == address(0)) {
			// Overflow check required: The rest of the code assumes that totalSupply never overflows
			_vaultSupply += value;
		} else {
			uint256 fromBalance = _vaults[from];
			if (fromBalance < value) {
				revert ERC20InsufficientBalance(from, fromBalance, value);
			}
			unchecked {
				// Overflow not possible: value <= fromBalance <= totalSupply.
				_vaults[from] = fromBalance - value;
			}
		}

		if (to == address(0)) {
			unchecked {
				// Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
				_vaultSupply -= value;
			}
		} else {
			unchecked {
				// Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
				_vaults[to] += value;
			}
		}

		emit Transfer(from, to, value);
	}

	function _mint(address account, uint256 value) internal {
		if (account == address(0)) {
			revert ERC20InvalidReceiver(address(0));
		}

		/**
		 * @review Compute real value_ based on the collateral.
		 * Collateral in msg.value
		 */
		uint256 value_ = value;

		_updateVault(address(0), account, msg.value);
		_update(address(0), account, value_);
		stablecoinAddress().mint(account, value_);
	}

	function mint(address to, uint256 amount) public payable {
		_mint(to, amount);
	}
}
