//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public {
        console.log("current USER balance %s", USER.balance);
        // uint256 preUserBalance = USER.balance;
        uint256 preOwnerBalance = fundMe.getOwner().balance;
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
        assertEq(address(fundMe).balance, SEND_VALUE);
        assertEq(USER.balance, STARTING_BALANCE - SEND_VALUE);

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assertEq(fundMe.getOwner().balance, preOwnerBalance + SEND_VALUE);
        assertEq(address(fundMe).balance, 0);
    }

    function testOwnerCanWithdrawInteractions() public {
        console.log(
            "contract balance before funding %s",
            address(fundMe).balance
        );
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        uint256 contractBalanceAfterFunding = address(fundMe).balance;

        uint256 ownerBalanceBeforeWithdrawal = fundMe.getOwner().balance;

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assertEq(
            fundMe.getOwner().balance,
            ownerBalanceBeforeWithdrawal + contractBalanceAfterFunding
        );
    }
}
