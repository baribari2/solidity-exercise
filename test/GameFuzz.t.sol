// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {Game, Boss} from "../src/Game.sol";

contract GameFuzz is Test {
    Game public game;

    address public gameOwner = address(0x1234);
    address public character1 = address(0x5678);
    address public character2 = address(0x9abc);
    address public character3 = address(0xdef0);

    function setUp() public {
        vm.prank(gameOwner, gameOwner);
        game = new Game();
    }

    function testNewBossFuzz(Boss memory boss) public {
        console.log(boss.name);
        vm.assume(bytes(boss.name).length > 0);
        vm.assume(boss.healthPoints > 0);
        vm.assume(boss.reward > 0);

        vm.prank(gameOwner, gameOwner);
        game.newBoss(boss);

        assertEq(game.getCurrentBoss().creator, gameOwner);
        assertEq(game.getCurrentBoss().name, boss.name);
        assertEq(game.getCurrentBoss().defeated, false);
    }

    function testNewCharacterFuzz(string memory name) public {
        vm.assume(bytes(name).length > 0);

        vm.prank(character1);
        game.newCharacter(name);

        assertEq(game.getCharacter(character1).name, name);
    }
}