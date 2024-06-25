// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "forge-std/Test.sol";
import "../src/TrotelCoinStakingV2.sol";
import "../src/trotelcoin-contracts/token/implementation/TrotelCoinV2.sol";

contract TrotelCoinStakingV2Test is Test {
    TrotelCoinStakingV2 public staking;
    TrotelCoinV2 public trotelCoinV2;

    uint256 public totalSupply;
    uint256 public amount;
    uint256 public bigAmount;

    uint32[] public durations;

    function setUp() public {
        trotelCoinV2 = new TrotelCoinV2(address(this), address(this));
        staking = new TrotelCoinStakingV2(address(this), address(trotelCoinV2));

        trotelCoinV2.grantRole(trotelCoinV2.MINTER_ROLE(), address(staking));

        totalSupply = 100000000 * 10 ** trotelCoinV2.decimals();
        amount = 100 * 10 ** trotelCoinV2.decimals();
        bigAmount = 1000000 * 10 ** trotelCoinV2.decimals();
    }

    function test_TrotelCoin() public view {
        assertEq(trotelCoinV2.totalSupply(), totalSupply);
        assertEq(trotelCoinV2.balanceOf(address(this)), totalSupply);
    }

    function test_Stake() public {
        trotelCoinV2.approve(address(staking), amount);
        staking.stake(amount, 30 days);

        assertEq(trotelCoinV2.balanceOf(address(this)), totalSupply - amount);

        TrotelCoinStakingV2.UserStaking memory userStaking = staking.getStakings(address(this));

        assertEq(userStaking.totalAmount, amount);
        assertEq(userStaking.startTime, block.timestamp);
        assertEq(userStaking.duration, 30 days);
        assertEq(userStaking.endTime, block.timestamp + 30 days);
        assertEq(userStaking.apr, 3);
        assertEq(userStaking.amounts.length, 1);
        assertEq(userStaking.times.length, 1);
        assertEq(userStaking.amounts[0], amount);
        assertEq(userStaking.times[0], block.timestamp);

        assertEq(trotelCoinV2.balanceOf(address(staking)), amount);
        assertEq(trotelCoinV2.totalSupply(), totalSupply);        
    }

    function test_AlreadyStaked() public {
        trotelCoinV2.approve(address(staking), amount);
        staking.stake(amount, 30 days);

        assertEq(trotelCoinV2.balanceOf(address(this)), totalSupply - amount);

        vm.expectRevert("Already staked");
        staking.stake(amount, 30 days);
    }

    function test_Stake30Days() public {
        trotelCoinV2.approve(address(staking), amount);
        staking.stake(amount, 30 days);

        assertEq(trotelCoinV2.balanceOf(address(this)), totalSupply - amount);

        TrotelCoinStakingV2.UserStaking memory userStaking = staking.getStakings(address(this));

        assertEq(userStaking.totalAmount, amount);
        assertEq(userStaking.startTime, block.timestamp);
        assertEq(userStaking.duration, 30 days);
        assertEq(userStaking.endTime, block.timestamp + 30 days);
        assertEq(userStaking.apr, 3);
        assertEq(userStaking.amounts.length, 1);
        assertEq(userStaking.times.length, 1);
        assertEq(userStaking.amounts[0], amount);
        assertEq(userStaking.times[0], block.timestamp);

        assertEq(trotelCoinV2.balanceOf(address(staking)), amount);
        assertEq(trotelCoinV2.totalSupply(), totalSupply);
    }

    function test_Stake91Days() public {
        trotelCoinV2.approve(address(staking), amount);
        staking.stake(amount, 91 days);

        assertEq(trotelCoinV2.balanceOf(address(this)), totalSupply - amount);

        TrotelCoinStakingV2.UserStaking memory userStaking = staking.getStakings(address(this));

        assertEq(userStaking.totalAmount, amount);
        assertEq(userStaking.startTime, block.timestamp);
        assertEq(userStaking.duration, 91 days);
        assertEq(userStaking.endTime, block.timestamp + 91 days);
        assertEq(userStaking.apr, 6);
        assertEq(userStaking.amounts.length, 1);
        assertEq(userStaking.times.length, 1);
        assertEq(userStaking.amounts[0], amount);
        assertEq(userStaking.times[0], block.timestamp);

        assertEq(trotelCoinV2.balanceOf(address(staking)), amount);
        assertEq(trotelCoinV2.totalSupply(), totalSupply);
    }

    function test_Stake182Days() public {
        trotelCoinV2.approve(address(staking), amount);
        staking.stake(amount, 182 days);

        assertEq(trotelCoinV2.balanceOf(address(this)), totalSupply - amount);

        TrotelCoinStakingV2.UserStaking memory userStaking = staking.getStakings(address(this));

        assertEq(userStaking.totalAmount, amount);
        assertEq(userStaking.startTime, block.timestamp);
        assertEq(userStaking.duration, 182 days);
        assertEq(userStaking.endTime, block.timestamp + 182 days);
        assertEq(userStaking.apr, 10);
        assertEq(userStaking.amounts.length, 1);
        assertEq(userStaking.times.length, 1);
        assertEq(userStaking.amounts[0], amount);
        assertEq(userStaking.times[0], block.timestamp);

        assertEq(trotelCoinV2.balanceOf(address(staking)), amount);
        assertEq(trotelCoinV2.totalSupply(), totalSupply);
    }

    function test_Stake365Days() public {
        trotelCoinV2.approve(address(staking), amount);
        staking.stake(amount, 365 days);

        assertEq(trotelCoinV2.balanceOf(address(this)), totalSupply - amount);

        TrotelCoinStakingV2.UserStaking memory userStaking = staking.getStakings(address(this));

        assertEq(userStaking.totalAmount, amount);
        assertEq(userStaking.startTime, block.timestamp);
        assertEq(userStaking.duration, 365 days);
        assertEq(userStaking.endTime, block.timestamp + 365 days);
        assertEq(userStaking.apr, 15);
        assertEq(userStaking.amounts.length, 1);
        assertEq(userStaking.times.length, 1);
        assertEq(userStaking.amounts[0], amount);
        assertEq(userStaking.times[0], block.timestamp);

        assertEq(trotelCoinV2.balanceOf(address(staking)), amount);
        assertEq(trotelCoinV2.totalSupply(), totalSupply);
    }

    function test_Stake730Days() public {
        trotelCoinV2.approve(address(staking), amount);
        staking.stake(amount, 730 days);

        assertEq(trotelCoinV2.balanceOf(address(this)), totalSupply - amount);

        TrotelCoinStakingV2.UserStaking memory userStaking = staking.getStakings(address(this));

        assertEq(userStaking.totalAmount, amount);
        assertEq(userStaking.startTime, block.timestamp);
        assertEq(userStaking.duration, 730 days);
        assertEq(userStaking.endTime, block.timestamp + 730 days);
        assertEq(userStaking.apr, 20);
        assertEq(userStaking.amounts.length, 1);
        assertEq(userStaking.times.length, 1);
        assertEq(userStaking.amounts[0], amount);
        assertEq(userStaking.times[0], block.timestamp);

        assertEq(trotelCoinV2.balanceOf(address(staking)), amount);
        assertEq(trotelCoinV2.totalSupply(), totalSupply);
    }

    function test_Stake1460Days() public {
        trotelCoinV2.approve(address(staking), amount);
        staking.stake(amount, 1460 days);

        assertEq(trotelCoinV2.balanceOf(address(this)), totalSupply - amount);

        TrotelCoinStakingV2.UserStaking memory userStaking = staking.getStakings(address(this));

        assertEq(userStaking.totalAmount, amount);
        assertEq(userStaking.startTime, block.timestamp);
        assertEq(userStaking.duration, 1460 days);
        assertEq(userStaking.endTime, block.timestamp + 1460 days);
        assertEq(userStaking.apr, 30);
        assertEq(userStaking.amounts.length, 1);
        assertEq(userStaking.times.length, 1);
        assertEq(userStaking.amounts[0], amount);
        assertEq(userStaking.times[0], block.timestamp);

        assertEq(trotelCoinV2.balanceOf(address(staking)), amount);
        assertEq(trotelCoinV2.totalSupply(), totalSupply);
    }

    function test_IncreaseStaking() public {
        trotelCoinV2.approve(address(staking), amount);
        staking.stake(amount, 30 days);

        assertEq(trotelCoinV2.balanceOf(address(this)), totalSupply - amount);

        TrotelCoinStakingV2.UserStaking memory userStaking = staking.getStakings(address(this));

        assertEq(userStaking.totalAmount, amount);
        assertEq(userStaking.startTime, block.timestamp);
        assertEq(userStaking.duration, 30 days);
        assertEq(userStaking.endTime, block.timestamp + 30 days);
        assertEq(userStaking.apr, 3);
        assertEq(userStaking.amounts.length, 1);
        assertEq(userStaking.times.length, 1);
        assertEq(userStaking.amounts[0], amount);
        assertEq(userStaking.times[0], block.timestamp);

        assertEq(trotelCoinV2.balanceOf(address(staking)), amount);
        assertEq(trotelCoinV2.totalSupply(), totalSupply);

        trotelCoinV2.approve(address(staking), amount);
        staking.increaseStaking(amount);

        userStaking = staking.getStakings(address(this));

        assertEq(userStaking.totalAmount, amount * 2);
        assertEq(userStaking.startTime, block.timestamp);
        assertEq(userStaking.duration, 30 days);
        assertEq(userStaking.endTime, block.timestamp + 30 days);
        assertEq(userStaking.apr, 3);
        assertEq(userStaking.amounts.length, 2);
        assertEq(userStaking.times.length, 2);
        assertEq(userStaking.amounts[0], amount);
        assertEq(userStaking.times[0], block.timestamp);
        assertEq(userStaking.amounts[1], amount);
        assertEq(userStaking.times[1], block.timestamp);

        assertEq(trotelCoinV2.balanceOf(address(staking)), amount * 2);
        assertEq(trotelCoinV2.totalSupply(), totalSupply);
    }

    function test_NoStakingFound() public {
        vm.expectRevert("No staking found");
        staking.increaseStaking(amount);
    }

    function test_StakingDurationExpired() public {
        trotelCoinV2.approve(address(staking), amount);
        staking.stake(amount, 30 days);

        assertEq(trotelCoinV2.balanceOf(address(this)), totalSupply - amount);

        TrotelCoinStakingV2.UserStaking memory userStaking = staking.getStakings(address(this));

        assertEq(userStaking.totalAmount, amount);
        assertEq(userStaking.startTime, block.timestamp);
        assertEq(userStaking.duration, 30 days);
        assertEq(userStaking.endTime, block.timestamp + 30 days);
        assertEq(userStaking.apr, 3);
        assertEq(userStaking.amounts.length, 1);
        assertEq(userStaking.times.length, 1);
        assertEq(userStaking.amounts[0], amount);
        assertEq(userStaking.times[0], block.timestamp);

        assertEq(trotelCoinV2.balanceOf(address(staking)), amount);
        assertEq(trotelCoinV2.totalSupply(), totalSupply);


        vm.warp(userStaking.endTime + 1 days);

        trotelCoinV2.approve(address(staking), amount);
        vm.expectRevert("Staking duration is expired");
        staking.increaseStaking(amount);
    }

    function test_StakingAmountMustBeGreaterThan0() public {
        vm.expectRevert("Staking amount must be greater than 0");
        staking.stake(0, 30 days);
    }

    function test_IncreaseStakingAmountMustBeGreaterThan0() public {
        vm.expectRevert("Staking amount must be greater than 0");
        staking.increaseStaking(0);
    }

    function test_CapExceeded() public {
        uint256 cap = trotelCoinV2.cap();
        uint256 capAmount = cap + 1;

        trotelCoinV2.mint(msg.sender, cap - totalSupply);

        trotelCoinV2.approve(address(staking), capAmount);
        vm.expectRevert("Cap exceeded");
        staking.stake(capAmount, 30 days);
    }

    function test_CalculateReward() public view {
        uint256 reward;

        reward = staking.calculateReward(amount, 30 days, 3);
        uint256 expectedReward = (amount * 3 / 100) * (30 days) / 365 days;
        assertEq(reward, expectedReward);

        reward = staking.calculateReward(amount, 91 days, 6);
        expectedReward = (amount * 6 / 100) * (91 days) / 365 days;
        assertEq(reward, expectedReward);

        reward = staking.calculateReward(amount, 182 days, 10);
        expectedReward = (amount * 10 / 100) * (182 days) / 365 days;
        assertEq(reward, expectedReward);

        reward = staking.calculateReward(amount, 365 days, 15);
        expectedReward = (amount * 15 / 100) * (365 days) / 365 days;
        assertEq(reward, expectedReward);

        reward = staking.calculateReward(amount, 730 days, 20);
        expectedReward = (amount * 20 / 100) * (730 days) / 365 days;
        assertEq(reward, expectedReward);

        reward = staking.calculateReward(amount, 1460 days, 30);
        expectedReward = (amount * 30 / 100) * (1460 days) / 365 days;
        assertEq(reward, expectedReward);
    }

    function test_GetUserTimeLeft() public {
        uint256 timeLeft;

        trotelCoinV2.approve(address(staking), amount);
        staking.stake(amount, 30 days);

        timeLeft = staking.getUserTimeLeft(address(this));
        assertEq(timeLeft, 30 days);

        vm.warp(block.timestamp + 15 days);

        timeLeft = staking.getUserTimeLeft(address(this));
        assertEq(timeLeft, 15 days);

        vm.warp(block.timestamp + 30 days);

        timeLeft = staking.getUserTimeLeft(address(this));
        assertEq(timeLeft, 0);

        vm.warp(block.timestamp + 31 days);
        assertEq(timeLeft, 0);
    }

    function test_GetUserReward() public {
        uint256 reward;

        trotelCoinV2.approve(address(staking), amount);
        staking.stake(amount, 30 days);

        reward = staking.getUserReward(address(this));
        uint256 expectedReward = (amount * 3 / 100) * (30 days) / 365 days;
        assertEq(reward, expectedReward);
    }

    function test_Unstake() public {
        uint256 reward;

        trotelCoinV2.approve(address(staking), amount);
        staking.stake(amount, 30 days);

        reward = staking.getUserReward(address(this));
        uint256 expectedReward = (amount * 3 / 100) * (30 days) / 365 days;
        assertEq(reward, expectedReward);

        assertEq(trotelCoinV2.balanceOf(address(this)), totalSupply - amount);

        vm.warp(block.timestamp + 31 days);

        staking.unstake();

        assertEq(trotelCoinV2.balanceOf(address(this)), totalSupply + reward);
        assertEq(trotelCoinV2.totalSupply(), totalSupply + reward);

        TrotelCoinStakingV2.UserStaking memory userStaking = staking.getStakings(address(this));

        assertEq(userStaking.totalAmount, 0);
        assertEq(userStaking.startTime, 0);
        assertEq(userStaking.duration, 0);
        assertEq(userStaking.endTime, 0);
        assertEq(userStaking.apr, 0);
        assertEq(userStaking.amounts.length, 0);
        assertEq(userStaking.times.length, 0);

        assertEq(trotelCoinV2.balanceOf(address(staking)), 0);
    }

    function test_RewardsWithIncreaseStaking() public {
        // TO DO
        // we want to make sure that rewards are calculated correctly when user increases staking multiple times (not just once)

        uint256 reward;

        trotelCoinV2.burn(totalSupply - amount);

        assertEq(trotelCoinV2.totalSupply(), amount);

        trotelCoinV2.approve(address(staking), amount / 2);
        staking.stake(amount / 2, 30 days);

        reward = staking.getUserReward(address(this));

        assertEq(trotelCoinV2.balanceOf(address(this)), amount / 2);

        vm.warp(block.timestamp + 15 days);

        trotelCoinV2.approve(address(staking), amount / 2);

        staking.increaseStaking(amount / 2);

        reward = staking.getUserReward(address(this));

        vm.warp(block.timestamp + 15 days);

        staking.unstake();

        assertEq(trotelCoinV2.balanceOf(address(this)), amount + reward);
    }

    function test_TwoUsersCapExceeded() public {
        address bob = makeAddr("bob");
        address alice = makeAddr("alice");

        trotelCoinV2.burn(totalSupply);

        uint256 cap = trotelCoinV2.cap();

        trotelCoinV2.mint(bob, amount);

        uint256 bobBalance = trotelCoinV2.balanceOf(bob);

        vm.prank(bob);
        trotelCoinV2.approve(address(staking), bobBalance);
        vm.prank(bob);
        staking.stake(bobBalance, 30 days);

        assertEq(trotelCoinV2.balanceOf(bob), 0);

        trotelCoinV2.mint(alice, cap - totalSupply);

        uint256 aliceBalance = trotelCoinV2.balanceOf(alice);

        vm.prank(alice);
        trotelCoinV2.approve(address(staking), aliceBalance);
        vm.prank(alice);
        vm.expectRevert("Cap exceeded");
        staking.stake(aliceBalance, 1460 days);
    }

    function test_StakeScenario() public {
        address bob = makeAddr("bob");
        address alice = makeAddr("alice");
        address charlie = makeAddr("charlie");

        trotelCoinV2.burn(totalSupply);

        trotelCoinV2.mint(bob, amount);
        trotelCoinV2.mint(alice, amount);
        trotelCoinV2.mint(charlie, bigAmount);

        uint256 bobBalance = trotelCoinV2.balanceOf(bob);
        uint256 aliceBalance = trotelCoinV2.balanceOf(alice);
        uint256 charlieBalance = trotelCoinV2.balanceOf(charlie);

        uint256 totalSupplyBeforeStaking = bobBalance + aliceBalance + charlieBalance;
        emit log_named_uint("total supply", totalSupplyBeforeStaking);

        assertEq(trotelCoinV2.totalSupply(), totalSupplyBeforeStaking);

        uint256 bobAmount = bobBalance / 2;

        vm.prank(bob);
        trotelCoinV2.approve(address(staking), bobAmount);
        vm.prank(bob);
        staking.stake(bobAmount, 30 days);

        vm.prank(alice);
        trotelCoinV2.approve(address(staking), aliceBalance);
        vm.prank(alice);
        staking.stake(aliceBalance, 91 days);

        TrotelCoinStakingV2.UserStaking memory bobStaking = staking.getStakings(bob);

        assertEq(bobStaking.totalAmount, bobAmount);
        assertEq(bobStaking.startTime, block.timestamp);
        assertEq(bobStaking.duration, 30 days);
        assertEq(bobStaking.endTime, block.timestamp + 30 days);
        assertEq(bobStaking.apr, 3);
        assertEq(bobStaking.amounts.length, 1);
        assertEq(bobStaking.times.length, 1);
        assertEq(bobStaking.amounts[0], bobAmount);
        assertEq(bobStaking.times[0], block.timestamp);

        TrotelCoinStakingV2.UserStaking memory aliceStaking = staking.getStakings(alice);

        assertEq(aliceStaking.totalAmount, aliceBalance);
        assertEq(aliceStaking.startTime, block.timestamp);
        assertEq(aliceStaking.duration, 91 days);
        assertEq(aliceStaking.endTime, block.timestamp + 91 days);
        assertEq(aliceStaking.apr, 6);
        assertEq(aliceStaking.amounts.length, 1);
        assertEq(aliceStaking.times.length, 1);
        assertEq(aliceStaking.amounts[0], aliceBalance);
        assertEq(aliceStaking.times[0], block.timestamp);

        vm.warp(block.timestamp + 10 days);

        vm.prank(bob);
        trotelCoinV2.approve(address(staking), bobAmount);
        vm.prank(bob);
        staking.increaseStaking(bobAmount);

        vm.warp(block.timestamp + 31 days);

        uint256 bobReward = staking.getUserReward(bob);
        emit log_named_uint("bob reward", bobReward);

        vm.prank(bob);
        staking.unstake();

        vm.prank(charlie);
        trotelCoinV2.approve(address(staking), charlieBalance);
        vm.prank(charlie);
        staking.stake(charlieBalance, 182 days);

        TrotelCoinStakingV2.UserStaking memory charlieStaking = staking.getStakings(charlie);

        assertEq(charlieStaking.totalAmount, charlieBalance);
        assertEq(charlieStaking.startTime, block.timestamp);
        assertEq(charlieStaking.duration, 182 days);
        assertEq(charlieStaking.endTime, block.timestamp + 182 days);
        assertEq(charlieStaking.apr, 10);
        assertEq(charlieStaking.amounts.length, 1);
        assertEq(charlieStaking.times.length, 1);
        assertEq(charlieStaking.amounts[0], charlieBalance);
        assertEq(charlieStaking.times[0], block.timestamp);

        vm.warp(block.timestamp + 91 days);

        uint256 aliceReward = staking.getUserReward(alice);
        emit log_named_uint("alice reward", aliceReward);

        vm.prank(alice);
        staking.unstake();

        vm.warp(block.timestamp + 182 days);

        uint256 charlieReward = staking.getUserReward(charlie);
        emit log_named_uint("charlie reward", charlieReward);

        vm.prank(charlie);
        staking.unstake();

        uint256 totalSupplyAfterStaking = totalSupplyBeforeStaking + bobReward + aliceReward + charlieReward;
        emit log_named_uint("total supply", totalSupplyAfterStaking);

        assertEq(trotelCoinV2.totalSupply(), totalSupplyAfterStaking);
    }
}