// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/vesting/TrotelCoinVestingBim.sol";
import "../src/trotelcoin-contracts/token/implementation/TrotelCoinV2.sol";

contract TrotelCoinVestingBimTest is Test {
    TrotelCoinVestingBim vesting;
    address beneficiary;
    address trotelCoinDAO;
    TrotelCoinV2 trotelcoin;

    function setUp() public {
        beneficiary = address(0x123);
        trotelCoinDAO = address(0x456);
        trotelcoin = new TrotelCoinV2(trotelCoinDAO, trotelCoinDAO);
        vesting = new TrotelCoinVestingBim(beneficiary, address(trotelcoin), trotelCoinDAO);

        vm.startPrank(trotelCoinDAO);
        trotelcoin.mint(address(vesting), 5000000 * 10 ** trotelcoin.decimals());
        vm.stopPrank();
        assertEq(trotelcoin.balanceOf(address(vesting)), 5000000 * 10 ** trotelcoin.decimals(), "Incorrect balance");
    }

    function testRelease() public {
        vm.warp(block.timestamp + 3 * 30 days + 1);

        uint256 initialBalance = trotelcoin.balanceOf(beneficiary);
        uint256 initialContractBalance = trotelcoin.balanceOf(address(vesting));

        vm.startPrank(beneficiary);
        vesting.release();
        vm.stopPrank();

        uint256 finalBalance = trotelcoin.balanceOf(beneficiary);
        uint256 finalContractBalance = trotelcoin.balanceOf(address(vesting));

        assertEq(finalBalance, initialBalance + vesting.MONTHLY_RELEASE_AMOUNT(), "Incorrect amount released");
        assertEq(finalContractBalance, initialContractBalance - vesting.MONTHLY_RELEASE_AMOUNT(), "Incorrect contract balance after release");
    }

    function testChangeBeneficiary() public {
        address newBeneficiary = address(0xabc);
        vm.startPrank(trotelCoinDAO);
        vesting.changeBeneficiary(newBeneficiary);
        vm.stopPrank();
        assertEq(vesting.beneficiary(), newBeneficiary, "Beneficiary not changed correctly");
    }

    function testGetTimeUntilNextClaim() public {
        assertEq(vesting.getTimeUntilNextClaim(), 3 * 30 days, "Incorrect time until next claim");

        vm.warp(block.timestamp + 3 * 30 days);
        assertEq(vesting.getTimeUntilNextClaim(), 0, "Incorrect time until next claim");

        vm.warp(block.timestamp + 3 * 30 days + 1);
        assertEq(vesting.getTimeUntilNextClaim(), 30 days - 1, "Incorrect time until next claim");
    }
}