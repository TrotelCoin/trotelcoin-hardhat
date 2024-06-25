// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "forge-std/Test.sol";
import "../src/TrotelCoinCollectiveIntelligenceV1.sol";
import "../src/trotelcoin-contracts/token/implementation/TrotelCoinV2.sol";
import "../src/TrotelCoinStakingV2.sol";
import { Upgrades } from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract TestTrotelCoinCollectiveIntelligenceV1 is Test {
    TrotelCoinCollectiveIntelligenceV1 public collectiveIntelligence;
    TrotelCoinV2 public trotelcoin;
    TrotelCoinStakingV2 public trotelcoinstaking;

    address public owner = address(1);
    address public user = address(2);
    address public intermediate = address(3);
    address public expert = address(4);

    function setUp() public {
        // deploy contract
        trotelcoin = new TrotelCoinV2(owner, owner);
        trotelcoinstaking = new TrotelCoinStakingV2(owner, address(trotelcoin));
        collectiveIntelligence = new TrotelCoinCollectiveIntelligenceV1(address(trotelcoin), address(trotelcoinstaking), owner);

        // mint some tokens
        vm.startPrank(owner);
        trotelcoin.mint(user, 10000 ether);
        trotelcoin.mint(intermediate, 100000 ether);
        trotelcoin.mint(expert, 1000000 ether);
        vm.stopPrank();

        // approve tokens
        vm.startPrank(user);
        trotelcoin.approve(address(collectiveIntelligence), 10000 ether);
        vm.stopPrank();

        vm.startPrank(intermediate);
        trotelcoin.approve(address(collectiveIntelligence), 100000 ether);
        trotelcoin.approve(address(trotelcoinstaking), 100000 ether);
        vm.stopPrank();

        vm.startPrank(expert);
        trotelcoin.approve(address(collectiveIntelligence), 1000000 ether);
        trotelcoin.approve(address(trotelcoinstaking), 1000000 ether);
        vm.stopPrank();

        // stake
        vm.startPrank(intermediate);
        trotelcoinstaking.stake(10000 ether, 2592000);
        vm.stopPrank();

        vm.startPrank(expert);
        trotelcoinstaking.stake(50000 ether, 2592000);
        vm.stopPrank();
    }

    function test_CollectiveIntelligence() public {
        // check initial values
        assertEq(trotelcoin.balanceOf(address(collectiveIntelligence)), 0);
        assertEq(trotelcoin.balanceOf(address(this)), 100000000 ether);

        // feed user
        trotelcoin.transfer(user, 10000 ether);
        assertEq(trotelcoin.balanceOf(user), 10000 ether);

        // transfer tokens to collective intelligence
        vm.startPrank(user);
        trotelcoin.transfer(address(collectiveIntelligence), 1000 ether);
        assertEq(trotelcoin.balanceOf(address(collectiveIntelligence)), 1000 ether);
        vm.stopPrank();
    }
}