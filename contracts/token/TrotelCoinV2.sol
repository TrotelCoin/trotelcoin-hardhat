// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract TrotelCoinV2 is Initializable, ERC20Upgradeable, ERC20BurnableUpgradeable, AccessControlUpgradeable, ERC20PermitUpgradeable, UUPSUpgradeable {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    uint256 private _cap;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address defaultAdmin, address minter, address upgrader)
        initializer public
    {
        __ERC20_init("TrotelCoin", "TROTEL");
        __ERC20Burnable_init();
        __AccessControl_init();
        __ERC20Permit_init("TrotelCoin");
        __UUPSUpgradeable_init();
        
        uint8 decimals_ = decimals();
        _cap = 1000000000 * 10 ** decimals_;

        _mint(msg.sender, 100000000 * 10 ** decimals_);
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(MINTER_ROLE, minter);
        _grantRole(UPGRADER_ROLE, upgrader);
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        uint256 currentSupply = totalSupply();
        require(currentSupply + amount <= _cap, "Cap exceeded");
        _mint(to, amount);
    }

    function cap() external view returns(uint256) {
        return _cap;
    }

    function setCap(uint256 newCap) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _cap = newCap;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyRole(UPGRADER_ROLE)
        override
    {}
}